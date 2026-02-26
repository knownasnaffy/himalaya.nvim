local M = {}

M.config = {
	sidebar = {
		width = 30,
	},
	split_ratio = 0.4, -- email list takes 40% when split
	wrap_folder_navigation = true, -- wrap to first/last when navigating folders
	icons_enabled = false, -- use nerd font icons for folders
	keymaps = {
		listing = {
			["gq"] = "close",
			["]f"] = "next_folder",
			["[f"] = "previous_folder",
			["gF"] = "folder_picker",
			["gr"] = "reload",
			["]]"] = "next_page",
			["[["] = "previous_page",
		},
	},
}

function M.setup(opts)
	M.config = vim.tbl_deep_extend("force", M.config, opts or {})
end

return M
