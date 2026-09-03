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
end)
