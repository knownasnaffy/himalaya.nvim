# Architecture & Approach

## Core Philosophy

Keep it simple. Deep modules, clean seams, test-first behavior verification.

## Architecture Layers

```
┌────────────────────────────────────────────────────────┐
│ UI Components (Nui layouts, views, popups, keymaps)    │
└──────────────────────────┬─────────────────────────────┘
                           │ calls domain actions & queries
┌──────────────────────────▼─────────────────────────────┐
│ Domain Services & State Store (mailbox, envelope, etc) │
└──────────────────────────┬─────────────────────────────┘
                           │ queries parsed entities
┌──────────────────────────▼─────────────────────────────┐
│ Deep CLI Adapter Layer (himalaya.cli.*)                │
└──────────────────────────┬─────────────────────────────┘
                           │ runs typed commands via runner
┌──────────────────────────▼─────────────────────────────┐
│ Command Runner Seam (Async vim.fn.jobstart or Mock)    │
└──────────────────────────┬─────────────────────────────┘
                           │ executes
┌──────────────────────────▼─────────────────────────────┐
│ Himalaya CLI v2.1.0+ (`himalaya --json ...`)           │
└────────────────────────────────────────────────────────┘
```

### 1. Command Runner & CLI Adapter Seam
- **Runner**: Wraps `vim.fn.jobstart` with stdout/stderr buffers, timeout, and exit code handling. Injectable for zero-dependency headless unit tests.
- **CLI Adapter**: Builds command vectors with global `--json`, `--account`, `--config` options.
- **Entity Normalization**: Translates raw CLI v2 JSON schemas into stable Lua tables (`Mailbox`, `Envelope`, `Message`, `Account`).

### 2. Domain State Store
- Separates domain state (account, mailbox hierarchy, envelope page, unread counts) from transient view state (window IDs, timers, spinners).
- Provides synchronous access to cached items and async refresh methods.

### 3. UI System
- **Main View**: Nui Layout with left sidebar (Mailbox tree) and right main area (Envelope table).
- **Reader Split**: Expands within the main area when reading an email.
- **Composer Floating Popup**: Separate floating popup matching layout dimensions (90% width/height), with top header rows for To/Cc/Subject and bottom area for Body.
- **Pickers**: Uses `vim.ui.select` by default, with configurable custom selector hook (`config.custom_select`).

## Module Structure

```
lua/himalaya/
├── init.lua              # Plugin entry point
├── config.lua            # User configuration
├── state.lua             # Domain state management
├── cli/                  # Deep CLI v2 Adapter
│   ├── init.lua          # Base runner & command builder
│   ├── runner.lua        # Injectable job execution seam
│   ├── account.lua       # Account list/check
│   ├── mailbox.lua       # Mailbox list
│   ├── envelope.lua      # Envelope list/search
│   ├── message.lua       # Message read/compose/send/copy/move/delete
│   ├── flag.lua          # Flag add/remove/set
│   └── attachment.lua    # Attachment list/download
├── domain/               # Domain logic
│   ├── account.lua
│   ├── mailbox.lua
│   └── envelope.lua
├── ui/                   # UI components
│   ├── layout.lua        # Main layout manager
│   ├── mailbox_list.lua  # Mailbox tree sidebar
│   ├── envelope_list.lua # Envelope table
│   ├── reader.lua        # Email viewer
│   ├── composer.lua      # Multi-window composition popup
│   └── picker.lua        # vim.ui.select integration
└── utils/                # Helpers
    ├── date.lua          # ISO 8601 parser
    └── keymap.lua
```

## Testing Strategy
- Zero-dependency headless Lua runner (`tests/run.lua`).
- Unit tests use mock CLI runner with offline fixtures generated from `himalaya json-schema`.
