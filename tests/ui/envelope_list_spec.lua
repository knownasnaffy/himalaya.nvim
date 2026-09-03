local envelope_list = require("himalaya.ui.envelope_list")
local state = require("himalaya.state")

describe("UI Envelope List", function()
	it("renders v2 envelopes with structured from and flags", function()
		local bufnr = vim.api.nvim_create_buf(false, true)

		local test_envelopes = {
			{
				id = "101",
				subject = "Unread Message",
				from = { { name = "Alice Smith", email = "alice@example.com" } },
				flags = {},
				date = "2026-09-03T01:10:53Z",
				["has-attachment"] = false,
			},
			{
				id = "102",
				subject = "Seen and Flagged",
				from = { { name = nil, email = "bob@example.com" } },
				flags = {
					{ iana = "seen", raw = "\\Seen" },
					{ iana = "flagged", raw = "\\Flagged" },
				},
				date = "2026-09-02T10:00:00Z",
				["has-attachment"] = true,
			},
		}

		envelope_list.render(bufnr, test_envelopes)

		assert.equals(2, state.current_envelope_count)
		assert.same(test_envelopes, state.current_envelopes)

		local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
		assert.equals(2, #lines)

		-- Line 1 should have Alice Smith and Unread Message
		assert.contains(lines[1], "Alice Smith")
		assert.contains(lines[1], "Unread Message")
		assert.contains(lines[1], "●")

		-- Line 2 should have bob@example.com and Seen and Flagged
		assert.contains(lines[2], "bob@example.com")
		assert.contains(lines[2], "Seen and Flagged")
		assert.contains(lines[2], "★")

		vim.api.nvim_buf_delete(bufnr, { force = true })
	end)
end)
