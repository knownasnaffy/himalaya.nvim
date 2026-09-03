# Himalaya CLI: flag operations

## Commands

```bash
# Add flag(s)
himalaya flag add -m <MAILBOX> -f <FLAG> [MESSAGE-IDS]...

# Set flag(s) (replace existing)
himalaya flag set -m <MAILBOX> -f <FLAG> [MESSAGE-IDS]...

# Remove flag(s)
himalaya flag remove -m <MAILBOX> -f <FLAG> [MESSAGE-IDS]...
```

## Standard Flags

- `seen`
- `answered`
- `flagged`
- `draft`
