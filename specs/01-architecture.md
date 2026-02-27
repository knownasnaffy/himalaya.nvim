# Architecture & Approach

## Core Philosophy

Keep it simple. Focus on core email workflows. Avoid feature bloat.

## Recommended Approach

### 1. **Layout System** (Phase 1)

- Vertical sidebar (left): folder list
- Main area (right): email list/content
- Split behavior: horizontal split within main area only
- Use nui.nvim Layout component for window management

### 2. **State Management** (Phase 2)

- Single source of truth for app state
- Minimal state: current account, folder, selected email
- Reactive updates when state changes

### 3. **CLI Integration** (Phase 3)

- Async job execution for himalaya commands
- Parse JSON output (`--output json`)
- Error handling with user feedback

### 4. **UI Components** (Phase 4)

- Folder list: tree-like structure with counts
- Email list: table with from/subject/date/flags
- Email viewer: formatted message display
- Composer: split with headers + body

## Module Structure

```
lua/himalaya/
├── init.lua              # Plugin entry point
├── config.lua            # User configuration
├── state.lua             # Global state management
├── cli/                  # Himalaya CLI wrapper
│   ├── init.lua
│   ├── account.lua
│   ├── folder.lua
│   ├── envelope.lua
│   └── message.lua
├── ui/                   # UI components
│   ├── layout.lua        # Main layout manager
│   ├── sidebar.lua       # Folder sidebar
│   ├── list.lua          # Email list
│   ├── viewer.lua        # Email viewer
│   └── composer.lua      # Email composer
└── utils/                # Helpers
    ├── async.lua
    └── format.lua
```

## Development Phases

**Phase 1**: Layout skeleton + folder sidebar
**Phase 2**: Email list view + navigation
**Phase 3**: Email reading + basic actions
**Phase 4**: Email composition + sending
**Phase 5**: Advanced features (search, flags, attachments)

## Key Decisions

- **nui.nvim**: Handles window/buffer management, splits, popups
- **JSON output**: Use `--output json` for all CLI calls
- **Async**: Use vim.loop for non-blocking CLI execution
- **Keymaps**: Context-aware (different per buffer type)
- **No external dependencies**: Only nui.nvim required

## Open Questions

1. Caching strategy for folder/email lists?
2. Refresh mechanism (manual vs auto)?
3. Multi-account switching UI?
4. Attachment handling approach?
5. HTML email rendering?
