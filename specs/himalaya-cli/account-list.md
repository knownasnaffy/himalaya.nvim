# Himalaya CLI: account list

## Command

```bash
himalaya account list --json [OPTIONS]
```

## Output Format (CLI v2.1.0+)

```json
{
  "accounts": [
    {
      "name": "gmail",
      "default": true,
      "backends": [
        "imap",
        "smtp"
      ]
    }
  ]
}
```

## Fields

- `name` (string): Account identifier
- `default` (boolean): Whether this is the default account
- `backends` (array of strings): Backend protocol names (e.g. `["imap", "smtp"]`)
