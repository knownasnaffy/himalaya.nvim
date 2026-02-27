# Himalaya CLI: folder list

## Command

```bash
RUST_LOG=off himalaya folder list --output json [OPTIONS]
```

## Options

- `--account <name>`: Account to use (default: default account)

## Output Format

```json
[
  {
    "name": "INBOX",
    "desc": "\\HasNoChildren"
  },
  {
    "name": "Sent",
    "desc": "\\HasNoChildren"
  },
  {
    "name": "Drafts",
    "desc": "\\HasNoChildren"
  }
]
```

## Fields

- `name` (string): Folder name/path
- `desc` (string): Folder attributes (IMAP flags)

## Common Attributes

- `\HasChildren`: Folder has subfolders
- `\HasNoChildren`: Folder has no subfolders
- `\Drafts`: Drafts folder
- `\Trash`: Trash folder
- `\Sent`: Sent folder
- `\All`: All mail folder

## Usage

```bash
# List folders from default account
himalaya folder list --output json

# List folders from specific account
himalaya folder list --output json --account work
```

## Notes

- Folder names may contain `/` for hierarchy (e.g., "Sync Issues/Conflicts")
- Use `RUST_LOG=off` to suppress log output
