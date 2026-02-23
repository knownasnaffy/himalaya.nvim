# Plugin Structure

## Files Created

```
himalaya.nvim/
├── lazy.lua                    # lazy.nvim plugin spec
├── plugin/
│   └── himalaya.lua           # :Himalaya command definition
├── lua/himalaya/
│   ├── init.lua               # Main entry point
│   ├── config.lua             # Configuration management
│   ├── state.lua              # Global state
│   └── ui/
│       └── layout.lua         # Layout manager with nui.nvim
```

## How It Works

1. **Command**: `:Himalaya` calls `require("himalaya").open()`
2. **Layout**: Creates sidebar (30 cols) + main area using nui.nvim Layout
3. **Config**: Default settings in `config.lua`, customizable via `setup()`

## Testing

To test the plugin:

1. Install with lazy.nvim using the `lazy.lua` spec
2. Run `:Himalaya` command
3. Should see a split window with "Folders" sidebar and "Emails" main area

## Next Steps

- Add folder list rendering in sidebar
- Integrate himalaya CLI to fetch folders
- Add keybindings for navigation
