# Himalaya CLI: attachment operations

## Commands

```bash
# List attachments in a message
himalaya attachment list -m <MAILBOX> <MESSAGE-ID>

# Download all attachments
himalaya attachment download -m <MAILBOX> <MESSAGE-ID>

# Download specific attachment part(s) by ID
himalaya attachment download -m <MAILBOX> <MESSAGE-ID> [ATTACHMENT-ID]... --dir <PATH>
```
