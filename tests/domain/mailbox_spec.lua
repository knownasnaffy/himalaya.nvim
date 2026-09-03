local mailbox_domain = require("himalaya.domain.mailbox")

describe("Domain Mailbox", function()
	local sample_mailboxes = {
		{ id = "INBOX", name = "INBOX", total = 42, unread = 5 },
		{ id = "[Gmail]/Sent Mail", name = "[Gmail]/Sent Mail", total = 100, unread = 0 },
		{ id = "[Gmail]/Drafts", name = "[Gmail]/Drafts", total = 2, unread = 0 },
		{ id = "Archive", name = "Archive", total = nil, unread = nil },
	}

	it("parses flat mailboxes into tree structure with counts", function()
		local tree = mailbox_domain.build_tree(sample_mailboxes)
		assert.is_not_nil(tree)
		assert.equals(3, #tree) -- INBOX, [Gmail], Archive

		local gmail_node = nil
		for _, node in ipairs(tree) do
			if node.displayName == "[Gmail]" then
				gmail_node = node
			end
		end

		assert.is_not_nil(gmail_node)
		assert.equals(2, #gmail_node.children)
		assert.equals("Sent Mail", gmail_node.children[1].displayName)
		assert.equals("[Gmail]/Sent Mail", gmail_node.children[1].name)
		assert.equals(5, tree[1].unread)
	end)

	it("aggregates unread count for intermediate parent folders without mailbox entries", function()
		local mailboxes = {
			{ id = "Work/ProjA", name = "Work/ProjA", total = 10, unread = 4 },
			{ id = "Work/ProjB", name = "Work/ProjB", total = 5, unread = 2 },
		}
		local tree = mailbox_domain.build_tree(mailboxes)
		assert.equals(1, #tree)
		local work_node = tree[1]
		assert.equals("Work", work_node.displayName)
		assert.equals(6, work_node.unread)
		assert.equals(4, work_node.children[1].unread)
		assert.equals(2, work_node.children[2].unread)
	end)

	it("sanitizes vim.NIL values for total and unread", function()
		local mailboxes = {
			{ id = "Spam", name = "Spam", total = vim.NIL, unread = vim.NIL },
		}
		local tree = mailbox_domain.build_tree(mailboxes)
		assert.is_nil(tree[1].total)
		assert.is_nil(tree[1].unread)
	end)

	it("extracts accessible mailbox names", function()
		local tree = mailbox_domain.build_tree(sample_mailboxes)
		local flat = mailbox_domain.get_accessible_mailboxes(tree)
		assert.equals(4, #flat)
		assert.same({ "INBOX", "[Gmail]/Sent Mail", "[Gmail]/Drafts", "Archive" }, flat)
	end)
end)
