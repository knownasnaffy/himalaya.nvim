local M = {}

M.config = {
	sidebar = {
		width = 30,
	},
	split_ratio = 0.4, -- email list takes 40% when split
	wrap_folder_navigation = true, -- wrap to first/last when navigating folders
	icons_enabled = false, -- use nerd font icons for folders
	custom_select = nil, -- optional custom picker function: fn(items, opts, on_choice)
	keymaps = {
		listing = {
			["gq"] = "close",
			["]f"] = "next_folder",
			["[f"] = "previous_folder",
			["gF"] = "folder_picker",
			["gA"] = "account_picker",
			["R"] = "reload",
			["]]"] = "next_page",
			["[["] = "previous_page",
			["<CR>"] = "open_email",
			["gw"] = "compose",
			["c"] = "compose",
			["gr"] = "reply",
			["r"] = "reply",
			["gf"] = "forward",
			["gD"] = "delete",
			["d"] = "delete",
			["gM"] = "move",
			["m"] = "move",
			["gC"] = "copy",
			["ga"] = "download_attachments",
			["gFa"] = "flag_add",
			["gFr"] = "flag_remove",
			["g/"] = "search",
		},
		email = {
			["gq"] = "close_email",
			["q"] = "close_email",
			["gr"] = "reply",
			["r"] = "reply",
			["gf"] = "forward",
			["gD"] = "delete",
			["d"] = "delete",
			["gM"] = "move",
			["m"] = "move",
			["gC"] = "copy",
			["ga"] = "download_attachments",
			["gFa"] = "flag_add",
			["gFr"] = "flag_remove",
		},
	},
}

function M.setup(opts)
	M.config = vim.tbl_deep_extend("force", M.config, opts or {})
end

return M
