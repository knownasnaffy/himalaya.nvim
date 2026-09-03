<div align="center">
  <img width="128" height="128" alt="output-nvim" src="https://github.com/user-attachments/assets/0ce78792-0def-4198-9659-73ce50dfa3f8" />
  <h1>himalaya.nvim</h1>
  <p>Modern Neovim plugin for <a href="https://github.com/pimalaya/himalaya">Himalaya CLI v2</a> - a CLI email client.</p>
</div>

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/be56131f-c687-4259-ba00-7c75349ce3d5" />

## About

Himalaya is a modern CLI tool for managing emails from the terminal. This plugin provides a native Neovim interface using Lua, [nui.nvim](https://github.com/MunifTanjim/nui.nvim) for UI components, and full compatibility with **Himalaya CLI v2.1+**.

## Goals

- **Simple & intuitive**: Clean UI with minimal learning curve
- **Himalaya v2 native**: Direct integration with CLI v2 schemas, flags, and subcommands
- **Keyboard-driven**: Efficient navigation, reading, composing, and mailbox management
- **Extensible**: Modular architecture with deep seams and custom picker support

## Features

- **Himalaya CLI v2.x compatible**: Fully updated to the v2 CLI architecture (`--json`, `mailbox`, `envelope`, `message`, `flag`, `attachment`, `account`).
- **Mailbox navigation**: Sidebar with nested tree hierarchy, unread count badges, next/previous navigation, and interactive picker.
- **Email listing**: Table layout displaying flags, attachment presence, sender, truncated subject, and relative dates.
- **Email reading**: Open and read emails in split below with `<CR>`, automatic `seen` flag handling.
- **Multi-window composer**: Floating popup matching main dimensions, dedicated sub-windows for To, Cc, Subject, and full-featured vim editing in Body with field cycling (`<Tab>` / `<S-Tab>`), send (`<C-s>`), and draft saving (`<C-d>`).
- **Mailbox actions**: Move (`gM`), copy (`gC`), and delete (`gD` with confirmation).
- **Flag operations**: Add (`gFa`) or remove (`gFr`) flags (`seen`, `flagged`, `answered`, `draft`) with immediate UI update.
- **Attachments**: Download message attachments (`ga`) using `attachment download`.
- **Search DSL**: Interactive search queries (`g/`) utilizing Himalaya v2's cross-backend query DSL.
- **Account switching**: Switch between accounts seamlessly (`gA` or `:HimalayaAccount <name>`).
- **Picker integration**: Uses `vim.ui.select` by default (integrates with Telescope, fzf-lua, dressing.nvim) or optional custom selector hook.

## Requirements

- Neovim >= 0.8
- [Himalaya CLI v2.0+](https://github.com/pimalaya/himalaya) installed and configured
- [nui.nvim](https://github.com/MunifTanjim/nui.nvim)

## Installation

### vim.pack.add

```lua
vim.pack.add({ 'https://github.com/MunifTanjim/nui.nvim', 'https://github.com/knownasnaffy/himalaya.nvim' })

require('himalaya').setup({
  icons_enabled = true,
  wrap_folder_navigation = true,
  -- Optional custom picker (e.g. telescope or fzf-lua override):
  -- custom_select = function(items, opts, on_choice) ... end,
})

vim.keymap.set('n', '<Leader>oh', '<Cmd>Himalaya<CR>', { desc = 'Open Himalaya' })
```

### lazy.nvim

```lua
{
  "knownasnaffy/himalaya.nvim",
  dependencies = {
    "MunifTanjim/nui.nvim",
  },
  opts = {
    icons_enabled = false, -- set to true to use nerd font icons
    wrap_folder_navigation = true,
  },
  keys = {
    { "<leader>oh", "<Cmd>Himalaya<CR>", desc = "[O]pen [H]imalaya" },
  },
}
```

## Usage

### Commands

| Command | Description |
| ------- | ----------- |
| `:Himalaya [account]` | Open Himalaya client, optionally specifying account |
| `:HimalayaAccounts` | Open account selector |
| `:HimalayaAccount <name>` | Switch active account directly |
| `:HimalayaMailboxes` / `:HimalayaFolders` | Open mailbox selector |
| `:HimalayaMailbox <name\|next\|previous>` | Switch or navigate mailboxes |
| `:HimalayaWrite` | Open email composer |
| `:HimalayaSearch` | Open interactive email search prompt |

### Keybindings

Default keybindings (all customizable via `config.keymaps`):

#### Email Listing

| Key | Action | Description |
| --- | ------ | ----------- |
| `<CR>` | `open_email` | Open email in split pane below |
| `gq` | `close` | Close Himalaya |
| `]f` | `next_folder` | Next mailbox (supports count) |
| `[f` | `previous_folder` | Previous mailbox (supports count) |
| `gF` | `folder_picker` | Open mailbox picker (`vim.ui.select`) |
| `gA` | `account_picker` | Open account picker (`vim.ui.select`) |
| `R` | `reload` | Reload current mailbox |
| `]]` | `next_page` | Next page (supports count) |
| `[[` | `previous_page` | Previous page (supports count) |
| `gw` / `c` | `compose` | Compose new email |
| `gr` / `r` | `reply` | Reply to selected email |
| `gf` | `forward` | Forward selected email |
| `gD` / `d` | `delete` | Delete email (with confirmation) |
| `gM` / `m` | `move` | Move email to mailbox |
| `gC` | `copy` | Copy email to mailbox |
| `ga` | `download_attachments` | Download attachments |
| `gFa` | `flag_add` | Add flag (`seen`, `flagged`, etc.) |
| `gFr` | `flag_remove` | Remove flag |
| `g/` | `search` | Search envelopes query |

#### Email Reading

| Key | Action | Description |
| --- | ------ | ----------- |
| `gq` / `q` | `close_email` | Close email pane |
| `gr` / `r` | `reply` | Reply to email |
| `gf` | `forward` | Forward email |
| `gD` / `d` | `delete` | Delete email |
| `gM` / `m` | `move` | Move email |
| `gC` | `copy` | Copy email |
| `ga` | `download_attachments` | Download attachments |
| `gFa` | `flag_add` | Add flag |
| `gFr` | `flag_remove` | Remove flag |

#### Email Composer (Floating Popup)

| Key | Action |
| --- | ------ |
| `<Tab>` / `<S-Tab>` | Cycle focus between To, Cc, Subject, and Body |
| `<C-s>` | Send email |
| `<C-d>` | Save email to Drafts |
| `<Esc>` | Cancel composition and close popup |

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
  custom_select = nil, -- custom picker hook: function(items, opts, on_choice)
  keymaps = {
    listing = {
      ["gq"] = "close",
      ["]f"] = "next_folder",
      ["[f"] = "previous_folder",
      ["gF"] = "folder_picker",
      ["gA"] = "account_picker",
      ["R"] = "reload",
      ["]]"] = "next_page",
      ["[["] = "previous_page",
      ["<CR>"] = "open_email",
      ["gw"] = "compose",
      ["c"] = "compose",
      ["gr"] = "reply",
      ["r"] = "reply",
      ["gf"] = "forward",
      ["gD"] = "delete",
      ["d"] = "delete",
      ["gM"] = "move",
      ["m"] = "move",
      ["gC"] = "copy",
      ["ga"] = "download_attachments",
      ["gFa"] = "flag_add",
      ["gFr"] = "flag_remove",
      ["g/"] = "search",
    },
    email = {
      ["gq"] = "close_email",
      ["q"] = "close_email",
      ["gr"] = "reply",
      ["r"] = "reply",
      ["gf"] = "forward",
      ["gD"] = "delete",
      ["d"] = "delete",
      ["gM"] = "move",
      ["m"] = "move",
      ["gC"] = "copy",
      ["ga"] = "download_attachments",
      ["gFa"] = "flag_add",
      ["gFr"] = "flag_remove",
    },
  },
})
```

## Running Tests

Zero-dependency headless test suite:

```bash
nvim --headless -u NONE -l tests/run.lua
```

## Hon'ble Mentions

- [himalaya-vim](https://github.com/pimalaya/himalaya-vim/) - The OG Vim plugin by [Clément DOUIN](https://github.com/soywod)
- [himalaya-nvim](https://github.com/xav-ie/himalaya-nvim) - Another himalaya UI for neovim by [Xavier Ruiz](https://github.com/xav-ie)


<details>
<summary>
<h2>More Screenshots</h2>
</summary>
<h3>Email List View</h3>
<img width="1920" height="1080" alt="list" src="https://github.com/user-attachments/assets/336e86dc-691e-49a7-b41f-606cf154cd10" />
<h3>Email Content View</h3>
<img width="1920" height="1080" alt="content" src="https://github.com/user-attachments/assets/566167f1-eb4c-4eb4-a6da-59948285ca51" />
<h3>Email Compose View</h3>
<img width="1920" height="1080" alt="compose" src="https://github.com/user-attachments/assets/87948394-bdd2-4eaf-b30a-64833b988e71" />
</details>
