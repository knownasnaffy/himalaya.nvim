local M = {}

M.current_account = ""
M.current_folder = "INBOX"
M.current_page = 1
M.layout = nil
M.sidebar = nil -- Buffer number
M.main = nil -- Buffer number
M.main_popup = nil -- Popup object for updating border text
M.is_open = false
M.folder_list = {} -- Flat list of accessible folders (with name field)

return M
