# Himalaya CLI: message read

## Command

```bash
himalaya message read [OPTIONS] <ID>
```

## Options

- `-m, --mailbox <NAME>`: Mailbox containing the message
- `-a, --account <NAME>`: Target account
- `--seen`: Mark the message as seen when reading
- `--raw`: Emit raw RFC 5322 bytes
- `--json`: With `--raw`, outputs `{ "message": "..." }`; otherwise outputs parsed `MessageView` JSON structure

## Output

Without `--json`: Returns human-readable plain text rendered with header block (`Date`, `From`, `To`, `Cc`, `Subject`) followed by MIME parts and plain-text body.
With `--json`: Returns parsed message structure or `{ "message": "raw rfc822..." }`.
