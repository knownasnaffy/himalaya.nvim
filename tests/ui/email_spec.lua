local state = require("himalaya.state")
local email = require("himalaya.email")
local runner = require("himalaya.cli.runner")
local Popup = require("nui.popup")
local Layout = require("nui.layout")

describe("UI Email CRLF Sanitization", function()
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
		state.email_visible = false
		state.current_folder = "INBOX"
		state.current_envelopes = {
			{ id = "101", flags = {} },
		}
	end)

	after_each(function()
		runner.reset_mock()
	end)

	it("sanitizes CRLF so email body buffer has no carriage return (^M) characters", function()
		runner.set_mock(function(cmd, callback)
			callback(nil, "Header: Value\r\n\r\nLine 1\r\nLine 2\r\nLine 3\r\n")
		end)

		email.open()

		local lines = vim.api.nvim_buf_get_lines(state.email, 0, -1, false)
		assert.equals(5, #lines)
		assert.equals("Header: Value", lines[1])
		assert.equals("", lines[2])
		assert.equals("Line 1", lines[3])
		assert.equals("Line 2", lines[4])
		assert.equals("Line 3", lines[5])

		for idx, line in ipairs(lines) do
			assert.falsy(line:find("\r"), string.format("Line %d contains \\r (^M)", idx))
		end
	end)
end)
