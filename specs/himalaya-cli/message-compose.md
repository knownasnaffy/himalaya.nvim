# Himalaya CLI: message compose, reply, forward

## Commands

### Compose
```bash
himalaya message compose [OPTIONS]
```
- `-t, --to <ADDR>`: Recipient address
- `--cc <ADDR>`: Carbon copy
- `--bcc <ADDR>`: Blind carbon copy
- `-s, --subject <TEXT>`: Subject
- `--body <TEXT>`: Inline body (or stdin / `--body-file <PATH>`)
- `--attach <PATH>`: Attachment file
- `--save <MAILBOX>`: Save copy to mailbox (e.g. `Drafts`)
- `--send`: Send via account's SMTP/JMAP path

### Reply
```bash
himalaya message reply [OPTIONS] <ID>
```
- `-m, --mailbox <NAME>`: Mailbox containing source message
- `-P, --posting-style <top|bottom>`: Quote positioning
- `-s, --subject`, `-t, --to`, `--body`, `--send`, `--save <MAILBOX>`

### Forward
```bash
himalaya message forward [OPTIONS] <ID>
```
- `-m, --mailbox <NAME>`: Mailbox containing source message
- `-t, --to <ADDR>`: Recipient address
- `-s, --subject`, `--body`, `--send`, `--save <MAILBOX>`
