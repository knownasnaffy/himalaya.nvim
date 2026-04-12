local state = require("himalaya.state")
local Layout = require("nui.layout")
local config = require("himalaya.config")

local M = {}

function M.open()
    if not state.layout or not state.main_popup or not state.sidebar_popup or not state.email_popup then
        return
    end

    -- If already open, just focus it
    if state.email_visible then
        local email_win = vim.fn.bufwinid(state.email)
        if email_win ~= -1 then
            vim.api.nvim_set_current_win(email_win)
        end
        return
    end

    -- Update layout to show email popup
    state.layout:update(Layout.Box({
        Layout.Box(state.sidebar_popup, { size = config.config.sidebar.width }),
        Layout.Box({
            Layout.Box(state.main_popup, { size = "50%" }),
            Layout.Box(state.email_popup, { grow = 1 }),
        }, { dir = "col", grow = 1 }),
    }, { dir = "row" }))

    state.email_visible = true

    -- Focus email window
    vim.schedule(function()
        local email_win = vim.fn.bufwinid(state.email)
        if email_win ~= -1 then
            vim.api.nvim_set_current_win(email_win)
        end
    end)

    -- async email content loading implementation
    local main_win = vim.fn.bufwinid(state.main)
    if main_win == -1 then return end

    local cursor = vim.api.nvim_win_get_cursor(main_win)
    local current_row = cursor[1] 

    vim.api.nvim_buf_set_lines(state.email, 0, -1, false, { "Loading..." })

    local list_cmd = { "himalaya", "envelope", "list", "--page-size", "100", "--output", "json" }

    if state.current_folder and state.current_folder ~= "" then
        table.insert(list_cmd, "--folder")
        table.insert(list_cmd, state.current_folder)
    end
    
    if state.current_page then
        table.insert(list_cmd, "--page")
        table.insert(list_cmd, tostring(state.current_page))
    end

    local json_str = ""
    vim.fn.jobstart(list_cmd, {
        stdout_buffered = true,
        on_stdout = function(_, data)
            if data then
                json_str = json_str .. table.concat(data, "\n")
            end
        end,
        on_exit = function(_, code)
            vim.schedule(function()
                if code ~= 0 or json_str == "" then
                    if vim.api.nvim_buf_is_valid(state.email) then
                        vim.api.nvim_buf_set_lines(state.email, 0, -1, false, { "Error: Could not fetch email list to resolve ID." })
                    end
                    return
                end

                local ok, envelopes = pcall(vim.fn.json_decode, json_str)
                
                if not ok or type(envelopes) ~= "table" or not envelopes[current_row] then
                    if vim.api.nvim_buf_is_valid(state.email) then
                        vim.api.nvim_buf_set_lines(state.email, 0, -1, false, { "Error: Failed to parse JSON or row is out of bounds." })
                    end
                end

                local email_id = envelopes[current_row].id
                if not email_id then return end

                vim.fn.jobstart({"himalaya", "message", "read", tostring(email_id)}, {
                    stdout_buffered = true,
                    on_stdout = function(_, read_data)
                        if read_data and #read_data > 0 then
                            vim.schedule(function()
                                if vim.api.nvim_buf_is_valid(state.email) then
                                    vim.api.nvim_buf_set_lines(state.email, 0, -1, false, read_data)
                                end
                            end)
                        end
                    end,
                })
            end)
        end
    })
end

function M.close()
    if not state.layout or not state.email_visible then
        return
    end

    -- Update layout to hide email popup
    state.layout:update(Layout.Box({
        Layout.Box(state.sidebar_popup, { size = config.config.sidebar.width }),
        Layout.Box(state.main_popup, { grow = 1 }),
    }, { dir = "row" }))

    state.email_visible = false

    -- Realign main window content to fill the space
    vim.schedule(function()
        local main_win = vim.fn.bufwinid(state.main)
        if main_win ~= -1 then
            vim.api.nvim_set_current_win(main_win)
            -- Scroll to top then back to maintain proper alignment
            local cursor = vim.api.nvim_win_get_cursor(main_win)
            vim.cmd("normal! gg")
            vim.api.nvim_win_set_cursor(main_win, cursor)
        end
    end)
end

return M
