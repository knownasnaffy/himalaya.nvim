local M = {}

M.current_account = ""
M.current_folder = nil -- Discovered dynamically from mailboxes
M.current_page = 1
M.current_envelope_count = 0 -- Number of emails in current view
M.current_envelopes = {} -- Envelopes currently displayed in main view
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
M.folder_list = {} -- Flat list of accessible folders/mailboxes

function M.reset_ui()
	if M.spinner_timer then
		pcall(function()
			M.spinner_timer:stop()
		end)
		M.spinner_timer = nil
	end
	M.is_open = false
	M.layout = nil
	M.sidebar = nil
	M.main = nil
	M.email = nil
	M.email_visible = false
	M.main_popup = nil
	M.sidebar_popup = nil
	M.email_popup = nil
	M.selected_email_id = nil
	M.current_folder = nil
end

return M
