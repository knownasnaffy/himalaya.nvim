# Himalaya CLI: mailbox list

## Command

```bash
himalaya mailbox list --json [OPTIONS]
```

## Options

- `-a, --account <NAME>`: Target account
- `-c, --config <PATH>`: Custom config file path
- `--log-level <LEVEL>`: e.g. `off`

## Output Schema (CLI v2.1.0+)

```json
{
  "mailboxes": [
    {
      "id": "Inbox",
      "name": "Inbox",
      "total": 120,
      "unread": 4
    },
    {
      "id": "[Gmail]/Drafts",
      "name": "[Gmail]/Drafts",
      "total": null,
      "unread": null
    }
  ]
}
```

## Fields

- `id` (string): Backend-specific unique mailbox identifier (used in follow-up commands like `-m, --mailbox <ID>`)
- `name` (string): Human-readable mailbox name (e.g. `INBOX`, `[Gmail]/Sent Mail`)
- `total` (integer | null): Total message count (null if unsupported or not requested)
- `unread` (integer | null): Unread message count (null if unsupported or not requested)
