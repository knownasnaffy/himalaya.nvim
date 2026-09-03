local state = require("himalaya.state")
local email = require("himalaya.email")
local himalaya = require("himalaya")
local Popup = require("nui.popup")
local Layout = require("nui.layout")
local runner = require("himalaya.cli.runner")

describe("UI Email Close and Reopen Lifecycle", function()
	local sidebar_popup, main_popup, email_popup, layout

	before_each(function()
		sidebar_popup = Popup({ enter = false })
		main_popup = Popup({ enter = true })
		email_popup = Popup({ enter = false })

		layout = Layout({
			position = "50%",
			size = { width = "90%", height = "90%" },
		}, Layout.Box({
			Layout.Box(sidebar_popup, { size = 30 }),
			Layout.Box(main_popup, { grow = 1 }),
		}, { dir = "row" }))

		state.sidebar = sidebar_popup.bufnr
		state.sidebar_popup = sidebar_popup
		state.main = main_popup.bufnr
		state.main_popup = main_popup
		state.email = email_popup.bufnr
		state.email_popup = email_popup
		state.layout = layout
		state.is_open = true
		state.email_visible = false
		state.current_folder = "INBOX"
		state.current_envelopes = {
			{ id = "101", flags = {} },
		}

		runner.set_mock(function(cmd, callback)
			callback(nil, "Test email body")
		end)
	end)

	after_each(function()
		runner.reset_mock()
	end)

	it("closes email pane without closing layout and returns to listing", function()
		email.open()
		assert.truthy(state.email_visible)

		email.close()
		assert.falsy(state.email_visible)
		assert.truthy(state.layout)
		assert.truthy(state.is_open)
	end)

	it("resets state when entire UI is closed and allows reopening email pane after relaunch", function()
		email.open()
		assert.truthy(state.email_visible)

		-- Close entire himalaya UI
		himalaya.close()
		assert.falsy(state.is_open)
		assert.falsy(state.email_visible, "email_visible must be reset to false when closing UI")
		assert.is_nil(state.layout)

		-- Relaunch UI (simulate new layout)
		sidebar_popup = Popup({ enter = false })
		main_popup = Popup({ enter = true })
		email_popup = Popup({ enter = false })
		layout = Layout({
			position = "50%",
			size = { width = "90%", height = "90%" },
		}, Layout.Box({
			Layout.Box(sidebar_popup, { size = 30 }),
			Layout.Box(main_popup, { grow = 1 }),
		}, { dir = "row" }))

		state.sidebar = sidebar_popup.bufnr
		state.sidebar_popup = sidebar_popup
		state.main = main_popup.bufnr
		state.main_popup = main_popup
		state.email = email_popup.bufnr
		state.email_popup = email_popup
		state.layout = layout
		state.is_open = true
		state.current_envelopes = {
			{ id = "102", flags = {} },
		}

		-- Pressing Enter on email item in new session
		email.open()
		assert.truthy(state.email_visible, "email_visible must be true when viewing email in reopened UI")
		assert.equals("102", state.selected_email_id)
	end)

	it("intercepts :q in himalaya-email buffer to close only email pane", function()
		-- Load ftplugin for email
		vim.api.nvim_set_current_buf(state.email)
		dofile(vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h:h") .. "/ftplugin/himalaya-email.lua")

		local keymaps = vim.api.nvim_buf_get_keymap(state.email, "c")
		local found_q_interceptor = false
		for _, map in ipairs(keymaps) do
			if map.lhs == "<CR>" and map.expr == 1 then
				found_q_interceptor = true
				break
			end
		end
		assert.truthy(found_q_interceptor, "Expected buffer-local c mode mapping for <CR> to intercept :q")
	end)
end)
