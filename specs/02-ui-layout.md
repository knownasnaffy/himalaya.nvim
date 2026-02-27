# UI Layout Specification

## Main Layout

```
┌─────────────┬──────────────────────────────────────┐
│             │                                      │
│   SIDEBAR   │          MAIN AREA                   │
│   (Folders) │       (Email List/Viewer)            │
│             │                                      │
│             │                                      │
└─────────────┴──────────────────────────────────────┘
```

### Sidebar (Left)

- Fixed width (configurable, default: 30 cols)
- Shows folder tree
- Displays unread count per folder
- Always visible

### Main Area (Right)

- Takes remaining width
- Initially shows email list
- Can split horizontally for email viewing

## Split Behavior

When viewing an email (press Enter on email list):

```
┌─────────────┬──────────────────────────────────────┐
│             │         EMAIL LIST                   │
│   SIDEBAR   │  (from/subject/date)                 │
│   (Folders) ├──────────────────────────────────────┤
│             │         EMAIL VIEWER                 │
│             │  (message content)                   │
└─────────────┴──────────────────────────────────────┘
```

- Horizontal split within main area only
- Sidebar unaffected
- Split ratio configurable (default: 40/60)

## Component Details

### Sidebar Component

```
Folders
├─ INBOX (12)
├─ Sent
├─ Drafts (2)
├─ Spam
└─ Trash
```

- Tree-style rendering
- Unread count in parentheses
- Highlight current folder
- Keybinds:
  - `j/k`: navigate
  - `<CR>`: select folder
  - `R`: refresh

### Email List Component

```
┌──────────────────────────────────────────────────────┐
│ From          Subject                    Date  Flags │
├──────────────────────────────────────────────────────┤
│ Alice         Meeting tomorrow          2/23   ●    │
│ Bob           Re: Project update        2/22        │
│ Charlie       Invoice #1234             2/21   ★    │
└──────────────────────────────────────────────────────┘
```

- Table format
- Columns: From, Subject, Date, Flags
- Visual indicators: ● (unread), ★ (flagged)
- Keybinds:
  - `j/k`: navigate
  - `<CR>`: open email
  - `d`: delete
  - `r`: reply
  - `c`: compose new

### Email Viewer Component

```
From: alice@example.com
To: me@example.com
Date: Mon, 23 Feb 2026 13:00:00
Subject: Meeting tomorrow

────────────────────────────────────────

Hey, let's meet tomorrow at 10am.

Best,
Alice
```

- Header section (from/to/date/subject)
- Separator line
- Message body
- Keybinds:
  - `q`: close viewer
  - `r`: reply
  - `d`: delete

## Layout Implementation Notes

- Use `nui.Layout` for main structure
- Use `nui.Split` for horizontal division
- Use `nui.Tree` for sidebar folders
- Use custom buffer rendering for list/viewer
- All components share same layout instance
- Layout persists across buffer changes
