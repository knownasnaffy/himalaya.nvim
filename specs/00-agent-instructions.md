# Agent Development Instructions

## ⚠️ CRITICAL: Git Commit Protocol

**ALWAYS commit after completing ANY feature, fix, or meaningful change.**

This is the MOST IMPORTANT part of the development process.

### When to Commit

- ✅ After implementing a feature (even if small)
- ✅ After fixing a bug
- ✅ After refactoring code
- ✅ After adding/updating specs
- ✅ After completing a logical unit of work
- ✅ Before starting a new feature

### Commit Message Format

```
<type>: <short description>

<optional detailed explanation>
```

**Types:**

- `feat`: New feature
- `fix`: Bug fix
- `refactor`: Code restructuring
- `docs`: Documentation changes
- `spec`: Specification updates
- `chore`: Maintenance tasks

**Examples:**

```
feat: implement sidebar layout with nui.nvim

feat: add async CLI wrapper for folder list

fix: handle empty folder list gracefully

refactor: extract layout config to separate module

docs: update README with installation steps
```

### Why This Matters

- **Easy rollback**: Revert to last working state instantly
- **Track progress**: See what was built and when
- **Debug faster**: Identify when bugs were introduced
- **Clear history**: Understand evolution of codebase

### Agent Workflow

```
1. Implement feature/fix
2. Test that it works
3. COMMIT with clear message
4. Move to next task
```

**Never skip step 3.**

## Development Approach

### Incremental Building

**Phase 1: Read-Only (Foundation)**

1. View folders
2. View email list
3. Read messages

**Phase 2: Actions**

1. Delete emails
2. Move emails
3. Flag/unflag emails

**Phase 3: Composition**

1. Write new emails
2. Reply to emails
3. Forward emails

### Code Principles

- **Minimal**: Write only what's needed
- **Testable**: Each module works independently
- **Async**: Never block the editor
- **Clear**: Code should be self-documenting

### File Organization

```
lua/himalaya/
├── init.lua              # Entry point
├── config.lua            # Configuration
├── state.lua             # State management
├── cli/                  # CLI wrappers
├── ui/                   # UI components
└── utils/                # Helpers
```

## Testing Strategy

- Manual testing as we build
- Test each component in isolation
- Test integration after combining components
- Use dummy data when CLI not available

## Error Handling

- Always handle CLI errors gracefully
- Show user-friendly error messages
- Log errors for debugging
- Never crash the editor
