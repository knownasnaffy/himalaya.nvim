# Himalaya CLI: envelope list

## Command

```bash
RUST_LOG=off himalaya envelope list --output json [OPTIONS]
```

## Options

- `--folder <name>`: Folder to list from (default: INBOX)
- `--account <name>`: Account to use (default: default account)
- `--page-size <n>`: Number of envelopes per page
- `--page <n>`: Page number (1-indexed)

## Output Format

```json
[
  {
    "id": "13230",
    "flags": ["Seen"],
    "subject": "Email subject",
    "from": {
      "name": "Sender Name",
      "addr": "sender@example.com"
    },
    "to": {
      "name": "Recipient Name",
      "addr": "recipient@example.com"
    },
    "date": "2026-02-20 16:30+00:00",
    "has_attachment": false
  }
]
```

## Fields

- `id` (string): Unique envelope identifier
- `flags` (array): Email flags (Seen, Flagged, etc.)
- `subject` (string): Email subject
- `from` (object): Sender with name and address
- `to` (object): Recipient with name and address
- `date` (string): Date with timezone
- `has_attachment` (boolean): Whether email has attachments

## Usage

```bash
# List from default folder (INBOX)
himalaya envelope list --output json --page-size 20

# List from specific folder
himalaya envelope list --output json --folder Sent --page-size 20

# With pagination
himalaya envelope list --output json --page 2 --page-size 20
```

## Notes

- Use `RUST_LOG=off` to suppress log output
- Returns array of envelopes, newest first by default
