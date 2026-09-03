local composer = require("himalaya.ui.composer")
local runner = require("himalaya.cli.runner")

describe("UI Composer", function()
	after_each(function()
		runner.reset_mock()
	end)

	it("extracts composition data and builds compose arguments", function()
		local executed_cmd = nil
		runner.set_mock(function(cmd, callback)
			executed_cmd = cmd
			callback(nil, "ok")
		end)

		composer.send_message({
			to = "recipient@example.com",
			cc = "copy@example.com",
			subject = "Testing Himalaya v2",
			body = "Hello from Neovim!",
			account = "gmail",
		}, function(err)
			assert.is_nil(err)
		end)

		assert.truthy(executed_cmd)
		local cmd_str = table.concat(executed_cmd, " ")
		assert.contains(cmd_str, "message compose")
		assert.contains(cmd_str, "-t recipient@example.com")
		assert.contains(cmd_str, "--cc copy@example.com")
		assert.contains(cmd_str, "-s Testing Himalaya v2")
		assert.contains(cmd_str, "--send")
	end)

	it("saves draft with --save", function()
		local executed_cmd = nil
		runner.set_mock(function(cmd, callback)
			executed_cmd = cmd
			callback(nil, "ok")
		end)

		composer.save_draft({
			to = "recipient@example.com",
			subject = "Draft Subject",
			body = "Draft Body",
			account = "gmail",
		}, function(err)
			assert.is_nil(err)
		end)

		assert.truthy(executed_cmd)
		local cmd_str = table.concat(executed_cmd, " ")
		assert.contains(cmd_str, "message compose")
		assert.contains(cmd_str, "--save Drafts")
	end)

	it("restores window focus to previous window when composer is closed", function()
		local list_buf = vim.api.nvim_create_buf(false, true)
		local list_win = vim.api.nvim_open_win(list_buf, true, {
			relative = "editor",
			row = 1,
			col = 1,
			width = 40,
			height = 20,
		})
		vim.api.nvim_set_current_win(list_win)
		assert.equals(list_win, vim.api.nvim_get_current_win())

		composer.open()
		assert.truthy(list_win ~= vim.api.nvim_get_current_win(), "Focus should have moved to composer popup")

		composer.close()
		assert.equals(list_win, vim.api.nvim_get_current_win(), "Focus should return to previous window")

		if vim.api.nvim_win_is_valid(list_win) then
			vim.api.nvim_win_close(list_win, true)
		end
	end)

	it("intercepts :q in composer buffers to close composer and restore focus", function()
		local list_buf = vim.api.nvim_create_buf(false, true)
		local list_win = vim.api.nvim_open_win(list_buf, true, {
			relative = "editor",
			row = 1,
			col = 1,
			width = 40,
			height = 20,
		})
		vim.api.nvim_set_current_win(list_win)

		composer.open()
		local body_buf = composer.popups.body.bufnr

		local keymaps = vim.api.nvim_buf_get_keymap(body_buf, "c")
		local found_q_interceptor = false
		for _, map in ipairs(keymaps) do
			if map.lhs == "<CR>" and map.expr == 1 then
				found_q_interceptor = true
				break
			end
		end
		assert.truthy(found_q_interceptor, "Expected buffer-local c mode mapping for <CR> to intercept :q in composer")

		composer.close()
		if vim.api.nvim_win_is_valid(list_win) then
			vim.api.nvim_win_close(list_win, true)
		end
	end)

	it("restores focus when sending an email closes composer", function()
		local list_buf = vim.api.nvim_create_buf(false, true)
		local list_win = vim.api.nvim_open_win(list_buf, true, {
			relative = "editor",
			row = 1,
			col = 1,
			width = 40,
			height = 20,
		})
		vim.api.nvim_set_current_win(list_win)

		runner.set_mock(function(_, cb) cb(nil, "ok") end)

		composer.open()
		vim.api.nvim_buf_set_lines(composer.popups.to.bufnr, 0, -1, false, { "user@example.com" })

		-- Trigger send
		local form = { to = "user@example.com", body = "Hello" }
		composer.send_message(form, function()
			composer.close()
		end)

		assert.equals(list_win, vim.api.nvim_get_current_win())

		if vim.api.nvim_win_is_valid(list_win) then
			vim.api.nvim_win_close(list_win, true)
		end
	end)

	it("falls back to state.main_popup window if previous window was closed", function()
		local main_buf = vim.api.nvim_create_buf(false, true)
		local main_win = vim.api.nvim_open_win(main_buf, true, {
			relative = "editor",
			row = 1,
			col = 1,
			width = 40,
			height = 20,
		})
		local state = require("himalaya.state")
		state.main_popup = { winid = main_win }

		local temp_buf = vim.api.nvim_create_buf(false, true)
		local temp_win = vim.api.nvim_open_win(temp_buf, true, {
			relative = "editor",
			row = 1,
			col = 1,
			width = 20,
			height = 10,
		})
		vim.api.nvim_set_current_win(temp_win)

		composer.open()
		-- Close temp_win while composer is open
		vim.api.nvim_win_close(temp_win, true)

		composer.close()
		assert.equals(main_win, vim.api.nvim_get_current_win())

		if vim.api.nvim_win_is_valid(main_win) then
			vim.api.nvim_win_close(main_win, true)
		end
		state.main_popup = nil
	end)
end)
