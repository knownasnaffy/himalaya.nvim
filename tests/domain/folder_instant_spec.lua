local state = require("himalaya.state")
local folder = require("himalaya.folder")
local cache = require("himalaya.cache")
local runner = require("himalaya.cli.runner")
local Popup = require("nui.popup")

describe("Folder Instant Active Item Switch", function()
	local sidebar_popup, main_popup
	local sample_folders = {
		{ name = "INBOX", unread = 2 },
		{ name = "Sent", unread = 0 },
		{ name = "Drafts", unread = 1 },
	}

	before_each(function()
		sidebar_popup = Popup({ enter = false })
		main_popup = Popup({ enter = true })

		local winid = vim.api.nvim_get_current_win()
		sidebar_popup.winid = winid
		vim.api.nvim_win_set_buf(winid, sidebar_popup.bufnr)

		state.sidebar = sidebar_popup.bufnr
		state.sidebar_popup = sidebar_popup
		state.main = main_popup.bufnr
		state.main_popup = main_popup
		state.current_folder = "INBOX"
		state.current_account = "personal"
		state.folder_list = { "INBOX", "Sent", "Drafts" }

		cache.clear()
		cache.set_folders(sample_folders)
	end)

	after_each(function()
		runner.reset_mock()
	end)

	it("immediately updates sidebar to active folder from cache before async CLI callback resolves", function()
		local cli_callback = nil
		runner.set_mock(function(cmd, callback)
			-- Do not immediately call callback to simulate network delay
			cli_callback = callback
		end)

		folder.switch_to("Sent")

		-- Assert that state.current_folder is updated
		assert.equals("Sent", state.current_folder)

		-- Assert that sidebar buffer already rendered "Sent" as active line (cursor moved to line 2)
		local cursor = vim.api.nvim_win_get_cursor(sidebar_popup.winid)
		assert.equals(2, cursor[1], "Cursor should immediately be on line 2 for Sent")

		-- Now resolve async CLI callback
		if cli_callback then
			cli_callback(nil, sample_folders)
		end
	end)

	it("normalizes default INBOX to match Inbox in sidebar and advances correctly via next()", function()
		local custom_folders = {
			{ name = "Archive", unread = 0 },
			{ name = "Drafts", unread = 0 },
			{ name = "Inbox", unread = 5 },
			{ name = "Sent", unread = 0 },
		}
		cache.set_folders(custom_folders)
		state.current_folder = "INBOX"

		local folder_list = require("himalaya.ui.folder_list")
		folder_list.render(sidebar_popup.bufnr, custom_folders)

		-- State should be normalized to "Inbox"
		assert.equals("Inbox", state.current_folder)

		-- Cursor in sidebar must be on line 3 ("Inbox"), not line 1 ("Archive")
		local cursor = vim.api.nvim_win_get_cursor(sidebar_popup.winid)
		assert.equals(3, cursor[1], "Cursor should be on line 3 for Inbox")

		-- Calling next() should advance from Inbox (line 3) to Sent (line 4)
		folder.next(true, true)
		assert.equals("Sent", state.current_folder, "Next folder after Inbox should be Sent, not Archive")
	end)
end)
