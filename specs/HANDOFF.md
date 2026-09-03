# Himalaya.nvim - Agent Handoff & Development Guidelines

> **Purpose**: Single-source quick reference for agents continuing development or debugging on `himalaya.nvim` without needing to inspect every file.

---

## 1. Quick Start & Verification

### Running the Test Suite
Always run headless tests before and after making changes:
```bash
nvim --headless -u NONE -l tests/run.lua
```
- **Zero external runtime dependencies**: Test harness (`tests/framework.lua`, `tests/mocks/nui.lua`) runs in standalone Neovim without needing internet or pre-cloned plugins.
- **Fixture data**: Located in `tests/fixtures/v2_fixtures.lua` (pure CLI v2 JSON outputs).
- **Execution seam**: Mock CLI responses via `require("himalaya.cli.runner").set_mock(fn)`.

---

## 2. Architecture & File Cheat Sheet

```
lua/himalaya/
├── init.lua                 # Public API (:setup, :open, :close)
├── config.lua               # Default configuration, keymap maps, custom_select hook
├── state.lua                # Shared session state (active account, folder, page, buffer IDs, envelopes)
├── account.lua              # Account switching logic & commands
├── actions.lua              # High-level domain actions (flag, move, copy, delete, download, search)
├── email.lua                # Reader pane toggle, content fetch, and seen flag synchronization
├── folder.lua               # Mailbox navigation (next, previous, switch_to, picker, reload)
├── page.lua                 # Pagination controls (next, previous)
│
├── cli/                     # DEEP CLI v2 ADAPTER LAYER
│   ├── init.lua             # Low-level argument builder, JSON decoder, nil cleaner
│   ├── runner.lua           # Injectable job execution seam (jobstart wrapper)
│   ├── account.lua          # `account list`, `account check`
│   ├── mailbox.lua          # `mailbox list` (unwraps { mailboxes: [...] })
│   ├── envelope.lua         # `envelope list -m <mbox>`, `envelope search`
│   ├── message.lua          # read, compose, reply, forward, send, add, copy, move, delete
│   ├── flag.lua             # `flag add/remove/set -m <mbox> -f <flag>`
│   └── attachment.lua       # `attachment list/download -m <mbox>`
│
├── domain/                  # PURE DOMAIN & DATA MODELS
│   └── mailbox.lua          # Hierarchy tree parser (`/` split), unread count calculation
│
├── ui/                      # NUI PRESENTATION LAYER
│   ├── layout.lua           # Main 3-pane Layout (Sidebar, Listing, Reader split)
│   ├── fullscreen.lua       # Native split layout fallback
│   ├── envelope_list.lua    # Email list table rendering (flags, attachment, sender, subject, date)
│   ├── folder_list.lua      # Mailbox tree sidebar rendering with unread count badges
│   ├── composer.lua         # Floating multi-window composer (To, Cc, Subject, Body)
│   └── picker.lua           # vim.ui.select wrapper with custom_select callback hook
│
└── utils/
    ├── date.lua             # ISO 8601 UTC timestamp parser ("2026-09-03T01:10:53Z")
    └── keymap.lua           # Neo-tree style keymap applicator
```

---

## 3. Himalaya CLI v2 Breaking Changes & Ground Rules

1. **Global JSON flag**: Use `--json`. Never use `--output json` or `--output plain`.
2. **Mailbox terminology**: Use `mailbox` (not `folder`). Envelope commands take `-m, --mailbox <NAME>`.
3. **Payload wrapping**:
   - `mailbox list --json` &rarr; `{ "mailboxes": [ { "id", "name", "total", "unread" } ] }`
   - `envelope list --json` &rarr; `{ "envelopes": [ ... ] }`
   - `account list --json` &rarr; `{ "accounts": [ { "name", "default", "backends" } ] }`
4. **Envelope shapes**:
   - `from`: Array of objects `[ { "name": ..., "email": ... } ]`.
   - `flags`: Array of objects `[ { "iana": "seen", "raw": "\\Seen" } ]`.
   - `has-attachment`: Boolean (`true`/`false`).
   - `date`: ISO 8601 string (`"2026-09-03T01:10:53Z"`).
5. **No `template` subcommand**: Replaced by `message compose`, `message reply`, `message forward`.
6. **RFC 5322 sending**: Send raw draft via `message send [-- <MSG>]` or `message compose --send`. Save draft via `message compose --save <MBOX>`.

---

## 4. Testing & Mocking Seam Pattern

When writing unit tests for any new CLI or domain feature:
```lua
local runner = require("himalaya.cli.runner")

describe("My Feature", function()
    after_each(function()
        runner.reset_mock()
    end)

    it("runs expected command", function()
        local executed_cmd = nil
        runner.set_mock(function(cmd, callback)
            executed_cmd = cmd
            callback(nil, '{"ok": true}')
        end)

        -- Execute feature under test...
        assert.contains(table.concat(executed_cmd, " "), "expected subcommand")
    end)
end)
```

---

## 5. State Management Conventions

Access `require("himalaya.state")`:
- `state.current_account`: string (e.g. `"gmail"`). If empty string, uses default CLI account.
- `state.current_folder`: string (e.g. `"INBOX"`). Current mailbox.
- `state.current_page`: integer (1-indexed).
- `state.current_envelopes`: table array of envelopes currently loaded in `main` buffer.
- `state.selected_email_id`: string ID of email currently displayed in reader pane.
- `state.sidebar`: buffer number of sidebar.
- `state.main`: buffer number of envelope listing.
- `state.email`: buffer number of email reader pane.
- `state.email_visible`: boolean flag for reader pane visibility.

---

## 6. Keybindings & Command Mappings

### User Commands
- `:Himalaya [account]` - Open client (optionally select account).
- `:HimalayaAccounts` - Open interactive account picker (`vim.ui.select`).
- `:HimalayaAccount <name>` - Switch active account directly.
- `:HimalayaMailboxes` / `:HimalayaFolders` - Mailbox picker.
- `:HimalayaMailbox <name|next|previous>` - Switch mailbox.
- `:HimalayaWrite` - Open floating composer.
- `:HimalayaSearch` - Cross-backend search prompt.

### Buffer Keymaps (`ftplugin/himalaya-envelope-listing.lua` & `ftplugin/himalaya-email.lua`)
- `<CR>`: `open_email`
- `gq` / `q`: `close` / `close_email`
- `gw` / `c`: `compose`
- `gr` / `r`: `reply`
- `gf`: `forward`
- `gD` / `d`: `delete` (prompts confirmation)
- `gM` / `m`: `move` (prompts target mailbox via `vim.ui.select`)
- `gC`: `copy` (prompts target mailbox)
- `ga`: `download_attachments`
- `gFa` / `gFr`: `flag_add` / `flag_remove` (`seen`, `flagged`, `answered`, `draft`)
- `g/`: `search`
- `]f` / `[f`: `next_folder` / `previous_folder`
- `gF` / `gA`: `folder_picker` / `account_picker`
- `R`: `reload`
- `]]` / `[[`: `next_page` / `previous_page`

### Composer Controls (`lua/himalaya/ui/composer.lua`)
- `<Tab>` / `<S-Tab>`: Cycle focus (To &rarr; Cc &rarr; Subject &rarr; Body).
- `<C-s>`: Send email.
- `<C-d>`: Save draft to Drafts mailbox.
- `<Esc>`: Cancel composition.

---

## 7. Mandatory Git Commit Protocol

As specified in `specs/00-agent-instructions.md`, **ALWAYS commit** after completing any feature, fix, or refactor:
```bash
git add <files> && git commit -m "<type>: <concise description>"
```
Types: `feat`, `fix`, `refactor`, `docs`, `spec`, `chore`. Never skip this step.

---

## 8. Suggested Skills for Next Agent

Call the `Skill` tool for:
1. **`caveman`**: Terse, token-efficient communication mode.
2. **`tdd`**: For building any new feature or bug fix test-first via `tests/run.lua`.
3. **`codebase-design`** / **`improve-codebase-architecture`**: For designing clean module seams and keeping deep abstractions.

---

## 9. Relevant Spec References

- Migration Guide: `specs/05-himalaya-v2-migration.md`
- Architecture & Seams: `specs/01-architecture.md`
- UI & Floating Composer: `specs/02-ui-layout.md`
- Himalaya CLI v2 Reference Sheets: `specs/himalaya-cli/*.md`
- Agent Instructions: `specs/00-agent-instructions.md`
- User Docs: `README.md` and `doc/himalaya.txt`
