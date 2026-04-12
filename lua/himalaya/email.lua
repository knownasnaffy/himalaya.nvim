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
    -- Get the current window and line from the main buffer (email list)
    local main_win = vim.fn.bufwinid(state.main)
    if main_win == -1 then return end

    local cursor = vim.api.nvim_win_get_cursor(main_win)
    local current_line = vim.api.nvim_buf_get_lines(state.main, cursor[1] - 1, cursor[1], false)[1]

    if not current_line or current_line == "" then return end

    -- Attempt to extract the ID from the line. 
    -- NOTE: The regex "%d+" matches the first sequence of numbers in the line.
    -- If the ID is not visible in the line or conflicts with numbers in the subject, 
    -- we might need to fetch the ID directly from the plugin's state table (e.g., state.emails[cursor[1]].id).
    local email_id = string.match(current_line, "%d+")

    if not email_id then
        vim.api.nvim_buf_set_lines(state.email, 0, -1, false, { 
            "Error: Could not identify the numeric ID in the selected line.",
            "Line content: " .. current_line 
        })
        return
    end

    -- Visual loading feedback
    vim.api.nvim_buf_set_lines(state.email, 0, -1, false, { "Loading email ID " .. email_id .. "..." })

    -- Execute the Himalaya CLI asynchronously
    vim.fn.jobstart({"himalaya", "read", email_id}, {
        stdout_buffered = true,
        on_stdout = function(_, data)
            if data and #data > 0 then
                vim.schedule(function()
                    -- Check if the buffer still exists before injecting text 
                    -- (prevents crashes if the user closes the window too quickly)
                    if vim.api.nvim_buf_is_valid(state.email) then
                        vim.api.nvim_buf_set_lines(state.email, 0, -1, false, data)
                    end
                end)
            end
        end,
        on_stderr = function(_, data)
            if data and #data > 0 and data[1] ~= "" then
                vim.schedule(function()
                    if vim.api.nvim_buf_is_valid(state.email) then
                        vim.api.nvim_buf_set_lines(state.email, 0, -1, false, { "Error reading email via CLI:", unpack(data) })
                    end
                end)
            end
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
