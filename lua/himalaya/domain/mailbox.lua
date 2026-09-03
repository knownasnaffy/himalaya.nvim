local M = {}

function M.build_tree(mailboxes)
	local root = {}
	local lookup = {}

	for _, mailbox in ipairs(mailboxes or {}) do
		local name = mailbox.name or mailbox.id or ""
		local parts = vim.split(name, "/", { plain = true })
		local current_path = ""
		local parent = root

		for i, part in ipairs(parts) do
			local is_last = (i == #parts)

			if current_path == "" then
				current_path = part
			else
				current_path = current_path .. "/" .. part
			end

			local existing = nil
			for _, item in ipairs(parent) do
				if item.displayName == part then
					existing = item
					break
				end
			end

			if not existing then
				local item = {
					displayName = part,
					children = {},
				}

				if is_last then
					item.name = name
					item.id = mailbox.id
					item.total = mailbox.total
					item.unread = mailbox.unread
				end

				table.insert(parent, item)
				lookup[current_path] = item
				parent = item.children
			else
				if is_last and not existing.name then
					existing.name = name
					existing.id = mailbox.id
					existing.total = mailbox.total
					existing.unread = mailbox.unread
				end
				parent = existing.children
			end
		end
	end

	return root
end

-- Backward compatibility alias
M.parse_folders = M.build_tree

function M.get_accessible_mailboxes(tree)
	local result = {}

	local function traverse(items)
		for _, item in ipairs(items) do
			if item.name then
				table.insert(result, item.name)
			end
			if #item.children > 0 then
				traverse(item.children)
			end
		end
	end

	traverse(tree or {})
	return result
end

-- Backward compatibility alias
M.get_accessible_folders = M.get_accessible_mailboxes

return M
