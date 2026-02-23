local M = {}

-- Apply keymaps from config to buffer
-- keymap_config: table of key -> action_name or { action_name, config = {...} } or function
-- actions: table of action_name -> function
function M.apply(bufnr, keymap_config, actions)
	for key, mapping in pairs(keymap_config) do
		local action_name, callback, desc, config

		-- Parse mapping format
		if type(mapping) == "string" then
			-- Simple: key = "action_name"
			action_name = mapping
			callback = actions[action_name]
			desc = action_name:gsub("_", " "):gsub("^%l", string.upper)
		elseif type(mapping) == "table" then
			if type(mapping[1]) == "function" then
				-- Custom function: key = { function, desc = "..." }
				callback = mapping[1]
				desc = mapping.desc
			elseif type(mapping[1]) == "string" then
				-- With config: key = { "action_name", config = {...} }
				action_name = mapping[1]
				callback = actions[action_name]
				desc = mapping.desc or action_name:gsub("_", " "):gsub("^%l", string.upper)
				config = mapping.config
			end
		elseif type(mapping) == "function" then
			-- Direct function: key = function
			callback = mapping
			desc = "Custom action"
		end

		-- Skip if no valid callback
		if not callback then
			goto continue
		end

		-- Wrap callback to pass config if provided
		local final_callback = callback
		if config then
			final_callback = function()
				callback(config)
			end
		end

		-- Map the key
		vim.keymap.set("n", key, final_callback, {
			buffer = bufnr,
			desc = desc,
			nowait = true,
		})

		::continue::
	end
end

return M
