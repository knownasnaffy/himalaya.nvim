# Himalaya CLI: envelope list

## Command

```bash
himalaya envelope list --json [OPTIONS]
```

## Options

- `-m, --mailbox <NAME>`: Target mailbox (default: inbox)
- `-a, --account <NAME>`: Target account
- `-p, --page <N>`: Page number (1-indexed, default: 1)
- `-s, --page-size <N>`: Max envelopes per page
- `--has-attachment`: Populate attachment status

## Output Schema (CLI v2.1.0+)

```json
{
  "envelopes": [
    {
      "id": "14273",
      "message-id": "IMNQv7qwThe7f2_c1CUUbA@geopod-ismtpd-84",
      "in-reply-to": [],
      "flags": [
        {
          "iana": "seen",
          "raw": "\\Seen"
        }
      ],
      "subject": "Redis Email Notification",
      "from": [
        {
          "name": "Redis",
          "email": "noreply@redis.com"
        }
      ],
      "to": [
        {
          "name": null,
          "email": "user@example.com"
        }
      ],
      "date": "2026-09-03T01:10:53Z",
      "size": 8351,
      "has-attachment": null
    }
  ]
}
```

## Fields

- `id` (string): Backend-specific message identifier
- `message-id` (string | null): RFC 5322 `Message-ID:`
- `in-reply-to` (string[]): RFC 5322 `In-Reply-To:` IDs
- `flags` (array): Array of Flag objects (`{ iana: "seen"|"answered"|"flagged"|"draft"|null, raw: string }`)
- `subject` (string): Email subject
- `from` (array): Array of Address objects (`{ name: string|null, email: string }`)
- `to` (array): Array of Address objects (`{ name: string|null, email: string }`)
- `date` (string | null): ISO 8601 date-time timestamp (e.g. `2026-09-03T01:10:53Z`)
- `size` (integer): Raw message size in bytes
- `has-attachment` (boolean | null): Attachment presence indicator
