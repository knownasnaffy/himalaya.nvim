# Himalaya CLI: envelope search

## Command

```bash
himalaya envelope search [OPTIONS] [QUERY]...
```

## Options

- `-m, --mailbox <NAME>`: Target mailbox (default: inbox)
- `-p, --page <N>`: Page number
- `-s, --page-size <N>`: Page size
- `--json`: Output JSON table of matching envelopes

## Query Syntax

Conditions:
- `date <YYYY-MM-DD>`
- `after <YYYY-MM-DD>`
- `from <PATTERN>`
- `to <PATTERN>`
- `subject <PATTERN>`
- `body <PATTERN>`
- `flag <seen|answered|flagged|draft>`

Logical operators:
- `and`, `or`, `not`, grouped with `(...)`

Ordering:
- `order by <date|from|to|subject> [asc|desc]`
