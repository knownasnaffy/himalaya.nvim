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

### ✅ Milestone 1: Core Features (Completed)
- **Email listing**: Display with sender, subject, and relative date
- **Folder navigation**: Sidebar with tree structure, next/previous/picker/reload
- **Page navigation**: `]]` / `[[` with count support
- **Email reading**: Open email in 50/50 split below with `<CR>`
- **Caching**: Instant subsequent launches with cached data
- **Fullscreen mode**: Native split layout when launched via `nvim +':Himalaya'`
- **Visual polish**: 
  - Unicode support in subjects and sender names
  - Real cursorline for active folder
  - Animated spinner for loading states
  - Footer with page number (left) and total (right)
  - Optional nerd font icons for folders
- **Customizable keymaps**: Neo-tree style configuration

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

#### Email Listing
| Key | Action |
|-----|--------|
| `gq` | Close Himalaya |
| `]f` | Next folder (supports count) |
| `[f` | Previous folder (supports count) |
| `gF` | Folder picker |
| `gr` | Reload current folder |
| `]]` | Next page (supports count) |
| `[[` | Previous page (supports count) |
| `<CR>` | Open email in split below |

#### Email Reading
| Key | Action |
|-----|--------|
| `gq` / `q` | Close email pane |

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
      ["]]"] = "next_page",
      ["[["] = "previous_page",
      ["<CR>"] = "open_email",
    },
    email = {
      ["gq"] = "close_email",
      ["q"] = "close_email",
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

**Listing:**
- `close` - Close Himalaya window
- `next_folder` - Navigate to next folder (supports count)
- `previous_folder` - Navigate to previous folder (supports count)
- `folder_picker` - Open folder picker (vim.ui.select)
- `reload` - Reload current folder
- `next_page` - Next page (supports count)
- `previous_page` - Previous page (supports count)
- `open_email` - Open email in split below

**Email:**
- `close_email` - Close email pane

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
