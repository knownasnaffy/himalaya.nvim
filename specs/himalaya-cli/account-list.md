# Himalaya CLI: account list

## Command

```bash
himalaya account list --output json
```

## Output Format

```json
[
  {
    "name": "main",
    "backend": "IMAP, SMTP",
    "default": true
  },
  {
    "name": "pro",
    "backend": "IMAP, SMTP",
    "default": false
  }
]
```

## Fields

- `name` (string): Account identifier
- `backend` (string): Backend type(s) used
- `default` (boolean): Whether this is the default account

## Usage

- Get list of all configured accounts
- Identify default account by `"default": true`
- Use account name for `--account` flag in other commands
