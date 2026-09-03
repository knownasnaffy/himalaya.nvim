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
			set_text = function() end,
		},
	}, NuiPopup)
end

function NuiPopup:mount() end
function NuiPopup:unmount() end
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

function NuiLayout:mount() end
function NuiLayout:unmount() end
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
