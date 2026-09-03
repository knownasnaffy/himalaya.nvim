# Himalaya CLI v2 Migration Specification

## Context & Motivation

`himalaya.nvim` was initially written against Himalaya CLI v1.x (or early v2-alpha prototypes). Development was paused pending the official release of Himalaya CLI v2.x.
Himalaya v2.x is now officially released (v2.1.0+), introducing breaking CLI syntax changes, redesigned JSON schemas, and consolidated commands.

This specification documents the changes required to align `himalaya.nvim` with Himalaya CLI v2.

---

## 1. Reference Material Analysis

### `himalaya-vim`
- **Master branch**: Kept on v1 (`folder list`, `--output json`, `template write`).
- **`origin/v2` branch (`d1ebaa5 "wip"`)**: Author Clément DOUIN began adapting to CLI v2.
  - Subcommands: `folder` &rarr; `mailbox`, `template` &rarr; `message compose/reply/forward`.
  - Flags: `--output json` &rarr; `--json`, `--folder` &rarr; `--mailbox`.
  - Actions: added `message copy`, `message move`, `message delete`, `flag add`, `flag remove`, `attachment download`.

### `himalaya-tui`
- Pure Rust Ratatui application using `pimalaya-cli`, `io-imap`, `io-jmap`, `pimalaya-config`.
- Does not shell out to the CLI executable, but shares identical v2 domain models and configuration standards (as verified in Cairn change `cli-parity-and-guidelines`).

---

## 2. Command Mapping (v1 vs v2)

| Action | v1 Command (Obsolete) | v2 Command (Target) |
|---|---|---|
| **Global JSON output** | `--output json` | `--json` (global flag) |
| **List Accounts** | `himalaya account list --output json` | `himalaya account list --json` |
| **List Folders / Mailboxes** | `himalaya folder list --output json` | `himalaya mailbox list --json` |
| **List Envelopes** | `himalaya envelope list --folder <F> --output json` | `himalaya envelope list -m <MAILBOX> --json` |
| **Search Envelopes** | Query positional on `envelope list` | `himalaya envelope search [OPTIONS] [QUERY]...` |
| **Read Message** | `himalaya message read <ID>` | `himalaya message read -m <MAILBOX> <ID>` (or `--raw` / `--json`) |
| **Compose / Write Email** | `himalaya template write` | `himalaya message compose [OPTIONS]` |
| **Reply to Email** | `himalaya template reply <ID>` | `himalaya message reply -m <MAILBOX> <ID> [OPTIONS]` |
| **Forward Email** | `himalaya template forward <ID>` | `himalaya message forward -m <MAILBOX> <ID> [OPTIONS]` |
| **Send Email** | `himalaya message send` | `himalaya message send [OPTIONS] [-- <MESSAGE>...]` |
| **Save Draft / Add Message**| `himalaya message write` | `himalaya message add -m <MAILBOX> -f draft [-- <MESSAGE>...]` |
| **Copy Message** | N/A | `himalaya message copy -f <SRC> -t <DST> [IDS]...` |
| **Move Message** | N/A | `himalaya message move -f <SRC> -t <DST> [IDS]...` |
| **Delete Message** | N/A | `himalaya message delete -m <MAILBOX> [IDS]...` |
| **Add Flag** | N/A | `himalaya flag add -m <MAILBOX> -f <FLAG> [IDS]...` |
| **Remove Flag** | N/A | `himalaya flag remove -m <MAILBOX> -f <FLAG> [IDS]...` |
| **Download Attachments** | N/A | `himalaya attachment download -m <MAILBOX> <ID> [ATTACHMENT-IDS]...` |

---

## 3. JSON Output Schema Shifts

### 3.1 Mailboxes
- **v1**: Array `[ { "name": "INBOX", "desc": "\\HasNoChildren" } ]`
- **v2**: Object with `mailboxes` list:
```json
{
  "mailboxes": [
    {
      "id": "Inbox",
      "name": "Inbox",
      "total": 120,
      "unread": 5
    }
  ]
}
```

### 3.2 Envelopes
- **v1**: Array of flat objects, single `from: { name, addr }`, string flags `["Seen"]`.
- **v2**: Object with `envelopes` list:
```json
{
  "envelopes": [
    {
      "id": "14273",
      "message-id": "msg-id@domain.com",
      "in-reply-to": [],
      "flags": [
        { "iana": "seen", "raw": "\\Seen" }
      ],
      "subject": "Email Subject",
      "from": [
        { "name": "Sender Name", "email": "sender@domain.com" }
      ],
      "to": [
        { "name": null, "email": "user@domain.com" }
      ],
      "date": "2026-09-03T01:10:53Z",
      "size": 8351,
      "has-attachment": null
    }
  ]
}
```

### 3.3 Accounts
- **v1**: Array `[ { "name": "main", "backend": "IMAP, SMTP", "default": true } ]`
- **v2**: Object with `accounts` list:
```json
{
  "accounts": [
    {
      "name": "gmail",
      "default": true,
      "backends": ["imap", "smtp"]
    }
  ]
}
```

---

## 4. Architectural Guidelines

1. **Vocabulary Update**:
   - Internal types and functions use `mailbox` (matching CLI v2 and RFC vocabulary).
   - User configuration and keymaps may retain `folder` aliases (`]f`, `[f`, `wrap_folder_navigation`) for ergonomics.
2. **Deep CLI Adapter**:
   - Hide all string construction, escaping, and JSON decoding behind `himalaya.cli.*`.
   - Provide an injectable runner for headless testing without live CLI or network access.
3. **Domain Layer**:
   - Pure Lua data models and state management independent of Neovim UI buffers or windows.
