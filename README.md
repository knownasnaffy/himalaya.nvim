# himalaya.nvim

Modern Neovim plugin for [Himalaya CLI](https://github.com/pimalaya/himalaya) - a CLI email client.

## About

Himalaya is a Rust-based CLI tool for managing emails from the terminal. This plugin provides a native Neovim interface using Lua and [nui.nvim](https://github.com/MunifTanjim/nui.nvim) for UI components.

## Goals

- **Simple & intuitive**: Clean UI with minimal learning curve
- **Lua-native**: Built for Neovim using modern Lua APIs
- **Keyboard-driven**: Efficient navigation and actions
- **Extensible**: Modular design for easy customization

## Status

🚧 Under active development

### ✅ Milestone 1: Basic Email Fetching (Completed)
- Email list display with sender, subject, and relative date
- Folder list in sidebar with tree structure
- Folder navigation (next/previous/picker/reload)
- Dynamic page sizing based on window height
- Unicode support in subjects
- Real cursorline highlighting for active folder
- Animated spinner for progress indication
- Page number footer in emails panel
- Optional nerd font icons for folders
- Proper z-index for notifications

## Requirements

- Neovim >= 0.8
- [Himalaya CLI](https://github.com/pimalaya/himalaya) installed and configured
- [nui.nvim](https://github.com/MunifTanjim/nui.nvim)

## Installation

### lazy.nvim

```lua
{
  "knownasnaffy/himalaya.nvim",
  dependencies = {
    "MunifTanjim/nui.nvim",
  },
  opts = {
    -- Optional configuration
    icons_enabled = false, -- set to true to use nerd font icons
    wrap_folder_navigation = true,
  },
}
```

## Usage

Open the email client:

```vim
:Himalaya
```

### Keybindings

Default keybindings (all customizable):

| Key | Action |
|-----|--------|
| `gq` | Close Himalaya (`:q` works too) |
| `]f` | Next folder (supports count) |
| `[f` | Previous folder (supports count) |
| `gF` | Folder picker (native) |
| `gr` | Reload current folder |

## Configuration

Default configuration:

```lua
require("himalaya").setup({
  sidebar = {
    width = 30,
  },
  split_ratio = 0.4, -- email list takes 40% when split
  wrap_folder_navigation = true, -- wrap to first/last when navigating
  icons_enabled = false, -- use nerd font icons for folders
  keymaps = {
    listing = {
      ["gq"] = "close",
      ["]f"] = "next_folder",
      ["[f"] = "previous_folder",
      ["gF"] = "folder_picker",
      ["gr"] = "reload",
    },
  },
})
```

### Custom Keymaps

Keymap configuration is inspired by [neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim)'s flexible mapping system.

You can customize keymaps in several ways:

```lua
keymaps = {
  listing = {
    -- Simple action mapping
    ["gq"] = "close",
    
    -- Multiple keys for same action
    ["]f"] = "next_folder",
    ["<Tab>"] = "next_folder",
    
    -- Custom function
    ["<leader>r"] = function()
      require("himalaya.folder").reload()
      vim.notify("Reloaded!", vim.log.levels.INFO)
    end,
    
    -- Custom function with description
    ["<leader>R"] = {
      function()
        require("himalaya.folder").reload()
      end,
      desc = "Reload with custom action"
    },
    
    -- Action with config (for future extensions)
    ["gF"] = { "folder_picker", config = { picker = "telescope" } },
    
    -- Remove a default keymap (don't map it)
    ["gr"] = nil,
  },
}
```

**Available actions:**
- `close` - Close Himalaya window
- `next_folder` - Navigate to next folder (supports count)
- `previous_folder` - Navigate to previous folder (supports count)
- `folder_picker` - Open folder picker (vim.ui.select)
- `reload` - Reload current folder

Or with lazy.nvim using `opts`:

```lua
{
  "knownasnaffy/himalaya.nvim",
  dependencies = { "MunifTanjim/nui.nvim" },
  opts = {
    icons_enabled = true, -- enable nerd font icons
  },
  keys = {
    { '<leader>oh', '<Cmd>Himalaya<CR>', desc = '[O]pen [H]imalaya' },
  },
}
```
