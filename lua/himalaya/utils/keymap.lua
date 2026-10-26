local M = {}

local function default_desc(action_name)
	return action_name:gsub("_", " "):gsub("^%l", string.upper)
end

local function parse(mapping)
	if type(mapping) == "string" then
		if mapping == "none" then
			return nil
		end
		return {
			action_name = mapping,
			desc = default_desc(mapping),
		}
	elseif type(mapping) == "table" then
		if type(mapping[1]) == "function" then
			return {
				callback = mapping[1],
				desc = mapping.desc or "Custom action",
			}
		elseif type(mapping[1]) == "string" and mapping[1] ~= "none" then
			return {
				action_name = mapping[1],
				desc = mapping.desc or default_desc(mapping[1]),
				config = mapping.config,
			}
		end
	elseif type(mapping) == "function" then
		return {
			callback = mapping,
			desc = "Custom action",
		}
	end
end

-- Return displayable entries from a keymap config. Disabled and invalid
-- mappings are omitted so help always represents the effective config.
function M.entries(keymap_config)
	local entries = {}
	for key, mapping in pairs(keymap_config or {}) do
		local parsed = parse(mapping)
		if parsed then
			table.insert(entries, {
				key = key,
				desc = parsed.desc,
			})
		end
	end

	table.sort(entries, function(a, b)
		return a.key < b.key
	end)
	return entries
end

-- Apply keymaps from config to buffer
-- keymap_config: table of key -> action_name or { action_name, config = {...} } or function
-- actions: table of action_name -> function
function M.apply(bufnr, keymap_config, actions)
	for key, mapping in pairs(keymap_config) do
		local parsed = parse(mapping)
		if not parsed then
			goto continue
		end

		local callback = parsed.callback or actions[parsed.action_name]

		-- Skip if no valid callback
		if not callback then
			goto continue
		end

		-- Wrap callback to pass config if provided
		local final_callback = callback
		if parsed.config then
			final_callback = function()
				callback(parsed.config)
			end
		end

		-- Map the key
		vim.keymap.set("n", key, final_callback, {
			buffer = bufnr,
			desc = parsed.desc,
			nowait = true,
		})

		::continue::
	end
end

return M
