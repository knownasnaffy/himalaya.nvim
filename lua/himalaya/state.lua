local M = {}

M.current_account = ""
M.current_folder = "INBOX"
M.current_page = 1
M.layout = nil
M.sidebar = nil -- Buffer number
M.main = nil -- Buffer number
M.email = nil -- Buffer number for email reading pane
M.email_visible = false -- Track if email pane is visible
M.main_popup = nil -- Popup object for updating border text
M.sidebar_popup = nil -- Popup object for spinner
M.email_popup = nil -- Popup object for email reading
M.spinner_timer = nil -- Timer for spinner animation
M.is_open = false
M.folder_list = {} -- Flat list of accessible folders (with name field)

return M
