local folder_list = require("himalaya.ui.folder_list")
local state = require("himalaya.state")
local Popup = require("nui.popup")

describe("UI Folder List Unread Counts", function()
	local sidebar_popup

	before_each(function()
		sidebar_popup = Popup({ enter = false })
		local winid = vim.api.nvim_get_current_win()
		sidebar_popup.winid = winid
		vim.api.nvim_win_set_buf(winid, sidebar_popup.bufnr)
		state.sidebar = sidebar_popup.bufnr
		state.sidebar_popup = sidebar_popup
		state.current_folder = "INBOX"
	end)

	it("renders unread count in parentheses for folders with unread > 0", function()
		local mailboxes = {
			{ id = "INBOX", name = "INBOX", total = 42, unread = 7 },
			{ id = "Archive", name = "Archive", total = 100, unread = 0 },
			{ id = "Drafts", name = "Drafts", total = 5, unread = nil },
		}

		folder_list.render(sidebar_popup.bufnr, mailboxes)

		local lines = vim.api.nvim_buf_get_lines(sidebar_popup.bufnr, 0, -1, false)
		assert.equals(3, #lines)

		assert.truthy(lines[1]:find("INBOX %(7%)"), "INBOX line should display (7) unread count")
		assert.falsy(lines[2]:find("%(0%)"), "Archive line should not display (0)")
		assert.falsy(lines[2]:find("%("), "Archive line should not have parentheses")
		assert.falsy(lines[3]:find("%("), "Drafts line should not have parentheses")
	end)

	it("renders unread count on nested folders", function()
		local mailboxes = {
			{ id = "Work/Urgent", name = "Work/Urgent", total = 10, unread = 3 },
			{ id = "Work/Later", name = "Work/Later", total = 5, unread = 0 },
		}

		folder_list.render(sidebar_popup.bufnr, mailboxes)

		local lines = vim.api.nvim_buf_get_lines(sidebar_popup.bufnr, 0, -1, false)
		assert.equals(3, #lines) -- Work, Urgent, Later
		assert.truthy(lines[1]:find("Work %(3%)"), "Parent Work folder should aggregate unread count (3)")
		assert.truthy(lines[2]:find("Urgent %(3%)"), "Urgent child folder should display (3)")
		assert.falsy(lines[3]:find("%("), "Later child folder should not display unread count")
	end)

	it("adjusts cached folder unread count and re-renders sidebar", function()
		local cache = require("himalaya.cache")
		local mailboxes = {
			{ id = "INBOX", name = "INBOX", total = 10, unread = 2 },
		}
		cache.set_folders(mailboxes)
		folder_list.render(sidebar_popup.bufnr, mailboxes)

		local lines = vim.api.nvim_buf_get_lines(sidebar_popup.bufnr, 0, -1, false)
		assert.truthy(lines[1]:find("INBOX %(2%)"))

		cache.adjust_folder_unread("INBOX", -1)
		folder_list.render(sidebar_popup.bufnr, cache.get_folders())

		lines = vim.api.nvim_buf_get_lines(sidebar_popup.bufnr, 0, -1, false)
		assert.truthy(lines[1]:find("INBOX %(1%)"))

		cache.adjust_folder_unread("INBOX", -1)
		folder_list.render(sidebar_popup.bufnr, cache.get_folders())

		lines = vim.api.nvim_buf_get_lines(sidebar_popup.bufnr, 0, -1, false)
		assert.falsy(lines[1]:find("%("))
	end)
end)
