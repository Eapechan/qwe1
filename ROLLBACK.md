# Rollback Mechanism

All development happens on `version-2.1.1`. `main` stays stable.

## Quick Reference

```bash
# Save current state before making changes
tools/rollback.sh save

# See all saved rollback points
tools/rollback.sh list

# Go back to the last saved point
tools/rollback.sh restore

# Go back to a specific point
tools/rollback.sh restore rollback/20260806-172849

# Remove a tag
tools/rollback.sh drop rollback/20260806-172849
```

## Workflow

1. **Before making changes** — `tools/rollback.sh save` to tag current commit
2. **Make changes** — edit code, build, test on device
3. **If something breaks** — `tools/rollback.sh restore` to go back
4. **If it works** — commit, push, and optionally save a new rollback point

## Current Rollback Point

| Tag | Commit | Message |
|-----|--------|---------|
| `rollback/20260806-172849` | `1b91e76` | fix: resolve all compilation errors for v2.1.1 build |
