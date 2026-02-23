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
- Folder list in sidebar
- Dynamic page sizing based on window height
- Unicode support in subjects
- Cursorline highlighting
- Proper z-index for notifications

## Requirements

- Neovim >= 0.8
- [Himalaya CLI](https://github.com/pimalaya/himalaya) installed and configured
- [nui.nvim](https://github.com/MunifTanjim/nui.nvim)

## Installation

### lazy.nvim

```lua
{
  "yourusername/himalaya.nvim",
  dependencies = {
    "MunifTanjim/nui.nvim",
  },
  opts = {},
}
```

## Usage

Open the email client:

```vim
:Himalaya
```

## Configuration

```lua
require("himalaya").setup({
  sidebar = {
    width = 30,
  },
  split_ratio = 0.4, -- email list takes 40% when split
})
```

