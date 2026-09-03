-- Minimal mock for nui components for headless testing
local M = {}

local NuiLine = {}
NuiLine.__index = NuiLine

function NuiLine.new()
	return setmetatable({ texts = {} }, NuiLine)
end

function NuiLine:append(text, hl)
	table.insert(self.texts, { text = text, hl = hl })
	return self
end

function NuiLine:render(bufnr, _, linenr)
	local full_text = ""
	for _, piece in ipairs(self.texts) do
		full_text = full_text .. piece.text
	end
	vim.api.nvim_buf_set_lines(bufnr, linenr - 1, linenr, false, { full_text })
end

package.preload["nui.line"] = function()
	return function()
		return NuiLine.new()
	end
end

local NuiPopup = {}
NuiPopup.__index = NuiPopup

function NuiPopup.new(opts)
	opts = opts or {}
	local bufnr = vim.api.nvim_create_buf(false, true)
	return setmetatable({
		bufnr = bufnr,
		winid = 1000,
		border = {
			style = opts.border and opts.border.style,
			set_text = function() end,
		},
		_opts = opts,
	}, NuiPopup)
end

function NuiPopup:mount()
	if not self.winid or self.winid == 1000 or not vim.api.nvim_win_is_valid(self.winid) then
		local ok, win = pcall(vim.api.nvim_open_win, self.bufnr, false, {
			relative = "editor",
			row = 1,
			col = 1,
			width = 10,
			height = 5,
		})
		if ok then
			self.winid = win
		end
	end
end

function NuiPopup:unmount()
	if self.winid and self.winid ~= 1000 and vim.api.nvim_win_is_valid(self.winid) then
		pcall(vim.api.nvim_win_close, self.winid, true)
	end
end

function NuiPopup:update_layout() end

package.preload["nui.popup"] = function()
	return function(opts)
		return NuiPopup.new(opts)
	end
end

local NuiLayout = {}
NuiLayout.__index = NuiLayout

function NuiLayout.new(opts, box)
	return setmetatable({ opts = opts, box = box }, NuiLayout)
end

local function mount_box(b)
	if not b then return end
	if b.mount then
		b:mount()
	elseif b.box then
		if type(b.box) == "table" then
			if b.box.mount then
				b.box:mount()
			else
				for _, child in ipairs(b.box) do
					mount_box(child)
				end
			end
		end
	end
end

local function unmount_box(b)
	if not b then return end
	if b.unmount then
		b:unmount()
	elseif b.box then
		if type(b.box) == "table" then
			if b.box.unmount then
				b.box:unmount()
			else
				for _, child in ipairs(b.box) do
					unmount_box(child)
				end
			end
		end
	end
end

function NuiLayout:mount()
	mount_box(self.box)
end

function NuiLayout:unmount()
	unmount_box(self.box)
end

function NuiLayout:update() end

local LayoutModule = {}
setmetatable(LayoutModule, {
	__call = function(_, opts, box)
		return NuiLayout.new(opts, box)
	end,
})

LayoutModule.Box = function(box, opts)
	return { box = box, opts = opts }
end

package.preload["nui.layout"] = function()
	return LayoutModule
end

package.preload["nui.utils.autocmd"] = function()
	return {
		event = {
			BufEnter = "BufEnter",
			BufLeave = "BufLeave",
			VimResized = "VimResized",
		},
	}
end

return M
