# Himalaya CLI: message operations (copy, move, delete, send, add)

## Copy & Move

```bash
# Copy message(s)
himalaya message copy -f <SOURCE_MBOX> -t <DEST_MBOX> [MESSAGE-IDS]...

# Move message(s)
himalaya message move -f <SOURCE_MBOX> -t <DEST_MBOX> [MESSAGE-IDS]...
```

## Delete

```bash
himalaya message delete -m <MAILBOX> [MESSAGE-IDS]...
```

## Send & Add (Save Draft)

```bash
# Send raw RFC 5322 message via SMTP/JMAP
himalaya message send --save <SENT_MBOX> [-- <MESSAGE>...]

# Append RFC 5322 message to mailbox (e.g. Drafts)
himalaya message add -m <DRAFTS_MBOX> -f draft [-- <MESSAGE>...]
```
