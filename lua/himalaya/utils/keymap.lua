local M = {}

-- Apply keymaps from config to buffer
-- keymap_config: table of action_name -> keys/function
-- actions: table of action_name -> default_function
function M.apply(bufnr, keymap_config, actions)
	for action_name, default_fn in pairs(actions) do
		local keys = keymap_config[action_name]

		-- Skip if disabled
		if keys == false or keys == nil then
			goto continue
		end

		local callback, desc

		-- Handle custom function with desc
		if type(keys) == "table" and type(keys[1]) == "function" then
			callback = keys[1]
			desc = keys.desc
		else
			-- Use default action
			callback = default_fn
			desc = action_name:gsub("_", " "):gsub("^%l", string.upper)
		end

		-- Normalize to list
		local key_list = type(keys) == "string" and { keys } or (type(keys) == "table" and keys or {})

		-- Map each key
		for _, key in ipairs(key_list) do
			if type(key) == "string" and key ~= "" then
				vim.keymap.set("n", key, callback, {
					buffer = bufnr,
					desc = desc,
					nowait = true,
				})
			end
		end

		::continue::
	end
end

return M
