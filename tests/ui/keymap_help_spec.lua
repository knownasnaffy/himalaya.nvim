local keymap_help = require("himalaya.ui.keymap_help")
local keymap_util = require("himalaya.utils.keymap")

describe("UI Keymap Help", function()
	after_each(function()
		keymap_help.close()
	end)

	it("lists customized mappings and omits disabled mappings", function()
		local entries = keymap_util.entries({
			["g?"] = "show_keymaps",
			["x"] = { "delete", desc = "Remove message" },
			["q"] = "none",
		})

		assert.same({
			{ key = "g?", desc = "Show keymaps" },
			{ key = "x", desc = "Remove message" },
		}, entries)
	end)

	it("renders a closeable popup", function()
		keymap_help.open("Test keymaps", {
			["g?"] = "show_keymaps",
			["q"] = "close",
		})

		assert.is_not_nil(keymap_help.popup)
		local lines = vim.api.nvim_buf_get_lines(keymap_help.popup.bufnr, 0, -1, false)
		assert.equals(2, #lines)
		assert.contains(table.concat(lines, "\n"), "g?")
		assert.contains(table.concat(lines, "\n"), "Show keymaps")

		keymap_help.close()
		assert.is_nil(keymap_help.popup)
	end)
end)
