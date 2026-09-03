-- Add ./lua and ./tests to package.path
local project_root = vim.fn.fnamemodify(vim.fn.resolve(debug.getinfo(1, "S").source:sub(2)), ":p:h:h")
package.path = project_root .. "/lua/?.lua;" .. project_root .. "/lua/?/init.lua;" .. package.path
package.path = project_root .. "/tests/?.lua;" .. package.path

local framework = require("framework")
_G.describe = framework.describe
_G.it = framework.it
_G.assert = framework.assert
_G.before_each = framework.before_each
_G.after_each = framework.after_each

local test_files = vim.fn.glob(project_root .. "/tests/**/*_spec.lua", false, true)

if #test_files == 0 then
	print("No test files found matching tests/**/*_spec.lua")
	vim.cmd("q")
	return
end

print(string.format("Running %d test file(s)...", #test_files))

for _, file in ipairs(test_files) do
	local rel = file:sub(#project_root + 2)
	print("\n\27[34m--- " .. rel .. " ---\27[0m")
	dofile(file)
end

local exit_code = framework.report()
if exit_code ~= 0 then
	os.exit(1)
else
	os.exit(0)
end
