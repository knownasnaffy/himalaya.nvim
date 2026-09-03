local M = {}

local current_suite = ""
local failures = {}
local total_tests = 0
local passed_tests = 0
local before_each_hooks = {}
local after_each_hooks = {}

local function deep_compare(t1, t2)
	if t1 == t2 then
		return true
	end
	if type(t1) ~= "table" or type(t2) ~= "table" then
		return false
	end
	for k, v in pairs(t1) do
		if not deep_compare(v, t2[k]) then
			return false
		end
	end
	for k, _ in pairs(t2) do
		if t1[k] == nil then
			return false
		end
	end
	return true
end

local function dump(v)
	if type(v) == "string" then
		return string.format("%q", v)
	elseif type(v) == "table" then
		local ok, s = pcall(vim.json.encode, v)
		if ok then
			return s
		end
		return tostring(v)
	else
		return tostring(v)
	end
end

M.assert = {
	equals = function(expected, actual, msg)
		if expected ~= actual then
			error((msg and (msg .. ": ") or "") .. "expected " .. dump(expected) .. ", got " .. dump(actual), 2)
		end
	end,
	same = function(expected, actual, msg)
		if not deep_compare(expected, actual) then
			error((msg and (msg .. ": ") or "") .. "expected " .. dump(expected) .. ", got " .. dump(actual), 2)
		end
	end,
	truthy = function(val, msg)
		if not val then
			error((msg and (msg .. ": ") or "") .. "expected truthy, got " .. dump(val), 2)
		end
	end,
	falsy = function(val, msg)
		if val then
			error((msg and (msg .. ": ") or "") .. "expected falsy, got " .. dump(val), 2)
		end
	end,
	is_nil = function(val, msg)
		if val ~= nil then
			error((msg and (msg .. ": ") or "") .. "expected nil, got " .. dump(val), 2)
		end
	end,
	is_not_nil = function(val, msg)
		if val == nil then
			error((msg and (msg .. ": ") or "") .. "expected non-nil value, got nil", 2)
		end
	end,
	contains = function(str, substr, msg)
		if type(str) ~= "string" or not string.find(str, substr, 1, true) then
			error((msg and (msg .. ": ") or "") .. "expected " .. dump(str) .. " to contain " .. dump(substr), 2)
		end
	end,
}

function M.describe(suite_name, fn)
	local old_suite = current_suite
	current_suite = old_suite == "" and suite_name or (old_suite .. " > " .. suite_name)
	print("\n  " .. current_suite)
	fn()
	current_suite = old_suite
end

function M.before_each(fn)
	table.insert(before_each_hooks, fn)
end

function M.after_each(fn)
	table.insert(after_each_hooks, fn)
end

function M.it(test_name, fn)
	total_tests = total_tests + 1

	for _, hook in ipairs(before_each_hooks) do
		hook()
	end

	local ok, err = pcall(fn)

	for _, hook in ipairs(after_each_hooks) do
		hook()
	end

	if ok then
		passed_tests = passed_tests + 1
		print("    \27[32m✔\27[0m " .. test_name)
	else
		table.insert(failures, {
			suite = current_suite,
			test = test_name,
			err = err,
		})
		print("    \27[31m✖\27[0m " .. test_name)
	end
end

function M.report()
	print("\n==========================================")
	if #failures == 0 then
		print(string.format("\27[32mAll %d tests passed!\27[0m\n", passed_tests))
		return 0
	else
		print(string.format("\27[31m%d of %d tests failed:\27[0m\n", #failures, total_tests))
		for i, fail in ipairs(failures) do
			print(string.format("%d) %s > %s\n   \27[31m%s\27[0m\n", i, fail.suite, fail.test, fail.err))
		end
		return 1
	end
end

return M
