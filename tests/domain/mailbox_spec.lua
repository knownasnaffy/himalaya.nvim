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
	end)

	it("extracts accessible mailbox names", function()
		local tree = mailbox_domain.build_tree(sample_mailboxes)
		local flat = mailbox_domain.get_accessible_mailboxes(tree)
		assert.equals(4, #flat)
		assert.same({ "INBOX", "[Gmail]/Sent Mail", "[Gmail]/Drafts", "Archive" }, flat)
	end)
end)
