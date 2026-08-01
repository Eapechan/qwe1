package server

import (
	"context"
	"encoding/json"
	"log/slog"
	"net/http"
	"sync"
	"time"

	"nhooyr.io/websocket"
)

type WSHub struct {
	clients    map[*WSClient]bool
	broadcast  chan *WSMessage
	register   chan *WSClient
	unregister chan *WSClient
	mu         sync.RWMutex
}

type WSClient struct {
	hub      *WSHub
	conn     *websocket.Conn
	send     chan []byte
	channels map[string]bool
	mu       sync.RWMutex
}

type WSMessage struct {
	Channel string      `json:"ch"`
	Type    string      `json:"type"`
	Data    interface{} `json:"data"`
}

func NewWSHub() *WSHub {
	return &WSHub{
		clients:    make(map[*WSClient]bool),
		broadcast:  make(chan *WSMessage, 256),
		register:   make(chan *WSClient),
		unregister: make(chan *WSClient),
	}
}

func (h *WSHub) Run(ctx context.Context) {
	for {
		select {
		case <-ctx.Done():
			h.mu.Lock()
			for client := range h.clients {
				close(client.send)
			}
			h.mu.Unlock()
			return

		case client := <-h.register:
			h.mu.Lock()
			h.clients[client] = true
			h.mu.Unlock()

		case client := <-h.unregister:
			h.mu.Lock()
			if _, ok := h.clients[client]; ok {
				delete(h.clients, client)
				close(client.send)
			}
			h.mu.Unlock()

		case msg := <-h.broadcast:
			h.mu.RLock()
			for client := range h.clients {
				if client.subscribedTo(msg.Channel) {
					select {
					case client.send <- marshalMessage(msg):
					default:
						close(client.send)
						delete(h.clients, client)
					}
				}
			}
			h.mu.RUnlock()
		}
	}
}

func (h *WSHub) Broadcast(channel string, data interface{}) {
	msg := &WSMessage{
		Channel: channel,
		Type:    "data",
		Data:    data,
	}
	select {
	case h.broadcast <- msg:
	default:
		slog.Warn("broadcast channel full, dropping message")
	}
}

func (h *WSHub) HandleWebSocket(w http.ResponseWriter, r *http.Request) {
	conn, err := websocket.Accept(w, r, &websocket.AcceptOptions{
		InsecureSkipVerify: true, // We handle TLS at the server level
	})
	if err != nil {
		slog.Error("websocket accept failed", "error", err)
		return
	}

	// Parse channels from query
	channels := make(map[string]bool)
	channelStr := r.URL.Query().Get("channels")
	if channelStr != "" {
		for _, ch := range splitChannels(channelStr) {
			channels[ch] = true
		}
	}

	client := &WSClient{
		hub:      h,
		conn:     conn,
		send:     make(chan []byte, 256),
		channels: channels,
	}

	h.register <- client

	go client.writePump()
	go client.readPump()
}

func (c *WSClient) subscribedTo(channel string) bool {
	c.mu.RLock()
	defer c.mu.RUnlock()
	return c.channels[channel]
}

func (c *WSClient) readPump() {
	defer func() {
		c.hub.unregister <- c
		c.conn.Close(websocket.StatusNormalClosure, "closed")
	}()

	c.conn.SetReadLimit(4096)

	for {
		ctx, cancel := context.WithTimeout(context.Background(), 60*time.Second)
		_, message, err := c.conn.Read(ctx)
		cancel()
		if err != nil {
			if websocket.CloseStatus(err) == websocket.StatusNormalClosure {
				return
			}
			slog.Error("websocket read error", "error", err)
			return
		}

		// Handle control messages
		var msg map[string]interface{}
		if json.Unmarshal(message, &msg) == nil {
			if op, ok := msg["op"].(string); ok {
				switch op {
				case "ping":
					c.send <- []byte(`{"op":"pong"}`)
				case "subscribe":
					if ch, ok := msg["channel"].(string); ok {
						c.mu.Lock()
						c.channels[ch] = true
						c.mu.Unlock()
					}
				case "unsubscribe":
					if ch, ok := msg["channel"].(string); ok {
						c.mu.Lock()
						delete(c.channels, ch)
						c.mu.Unlock()
					}
				}
			}
		}
	}
}

func (c *WSClient) writePump() {
	ticker := time.NewTicker(30 * time.Second)
	defer func() {
		ticker.Stop()
		c.conn.Close(websocket.StatusNormalClosure, "closed")
	}()

	for {
		select {
		case message, ok := <-c.send:
			if !ok {
				c.conn.Write(context.Background(), websocket.MessageText, []byte(`{"op":"closed"}`))
				return
			}

			w, err := c.conn.Writer(context.Background(), websocket.MessageText)
			if err != nil {
				return
			}
			w.Write(message)

			// Drain queued messages
			n := len(c.send)
			for i := 0; i < n; i++ {
				w.Write([]byte("\n"))
				w.Write(<-c.send)
			}

			if err := w.Close(); err != nil {
				return
			}

		case <-ticker.C:
			if err := c.conn.Ping(context.Background()); err != nil {
				return
			}
		}
	}
}

func marshalMessage(msg *WSMessage) []byte {
	data, _ := json.Marshal(msg)
	return data
}

func splitChannels(s string) []string {
	var result []string
	for _, ch := range splitString(s, ",") {
		ch = trimSpace(ch)
		if ch != "" {
			result = append(result, ch)
		}
	}
	return result
}

func splitString(s, sep string) []string {
	var result []string
	start := 0
	for i := 0; i <= len(s)-len(sep); i++ {
		if s[i:i+len(sep)] == sep {
			result = append(result, s[start:i])
			start = i + len(sep)
		}
	}
	result = append(result, s[start:])
	return result
}

func trimSpace(s string) string {
	start := 0
	end := len(s)
	for start < end && s[start] == ' ' {
		start++
	}
	for end > start && s[end-1] == ' ' {
		end--
	}
	return s[start:end]
}
