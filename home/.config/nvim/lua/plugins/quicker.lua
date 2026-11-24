return {
    'stevearc/quicker.nvim',
    ft = "qf",
    keys = {
        { "<leader>qq", function() require('quicker').toggle() end,                 desc = 'Toggle quickfix' },
        { "<leader>ql", function() require('quicker').toggle({ loclist = true }) end, desc = 'Toggle quickfix' },
    },
    config = function()
        ---@type table[] one record per delete_items call, most recent last
        local delete_history = {}

        -- Reverse the most recent delete_items call made on the current list.
        local function undo_delete()
            local win = vim.api.nvim_get_current_win()
            local is_loc = vim.fn.getwininfo(win)[1].loclist == 1
            local list = is_loc and vim.fn.getloclist(win, { all = 0 }) or vim.fn.getqflist({ all = 0 })

            local idx
            for i = #delete_history, 1, -1 do
                if delete_history[i].id == list.id and delete_history[i].is_loc == is_loc then
                    idx = i
                    break
                end
            end
            if not idx then
                vim.notify("Nothing to undo for this list", vim.log.levels.WARN)
                return
            end
            local record = delete_history[idx]

            -- Refuse if a source buffer changed since the deletion; line numbers could no longer be trusted
            for buf in pairs(record.lines) do
                if not vim.api.nvim_buf_is_valid(buf) or vim.api.nvim_buf_get_changedtick(buf) ~= record.ticks[buf] then
                    vim.notify("A source buffer changed since the deletion; cannot undo safely", vim.log.levels.ERROR)
                    return
                end
            end

            for buf, lines in pairs(record.lines) do
                table.sort(lines, function(a, b) return a[1] < b[1] end)
                for _, entry in ipairs(lines) do
                    vim.api.nvim_buf_set_lines(buf, entry[1] - 1, entry[1] - 1, false, { entry[2] })
                end
                if record.saved[buf] then
                    vim.api.nvim_buf_call(buf, function()
                        vim.cmd.update({ mods = { emsg_silent = true, noautocmd = true } })
                    end)
                end
            end
            table.remove(delete_history, idx)

            local what = { items = record.items, title = list.title, context = list.context }
            local view = vim.fn.winsaveview()
            if is_loc then
                vim.fn.setloclist(win, {}, "r", what)
            else
                vim.fn.setqflist({}, "r", what)
            end
            vim.fn.winrestview(view)
            vim.notify("Restored deleted lines")
        end

        -- Delete the source lines referenced by qf items [first, last] and drop the items from the list.
        local function delete_items(first, last)
            if vim.bo.modified then
                vim.notify("Save or :Refresh the quickfix buffer first", vim.log.levels.WARN)
                return
            end
            local win = vim.api.nvim_get_current_win()
            local is_loc = vim.fn.getwininfo(win)[1].loclist == 1
            local list = is_loc and vim.fn.getloclist(win, { all = 0 }) or vim.fn.getqflist({ all = 0 })

            ---@type table<integer, table<integer, boolean>>
            local to_delete = {}
            local skipped = 0
            for i = first, math.min(last, #list.items) do
                local item = list.items[i]
                if item.bufnr ~= 0 and item.lnum > 0 then
                    vim.fn.bufload(item.bufnr)
                    local src = vim.api.nvim_buf_get_lines(item.bufnr, item.lnum - 1, item.lnum, false)[1]
                    if src and vim.trim(src) == vim.trim(item.text) then
                        to_delete[item.bufnr] = to_delete[item.bufnr] or {}
                        to_delete[item.bufnr][item.lnum] = src
                    else
                        skipped = skipped + 1
                    end
                end
            end

            local record = { id = list.id, is_loc = is_loc, items = vim.deepcopy(list.items), lines = {}, saved = {}, ticks = {} }
            local count = 0
            for buf, set in pairs(to_delete) do
                local lnums = vim.tbl_keys(set)
                table.sort(lnums, function(a, b) return a > b end)
                local was_modified = vim.bo[buf].modified
                record.lines[buf] = {}
                for _, l in ipairs(lnums) do
                    vim.api.nvim_buf_set_lines(buf, l - 1, l, false, {})
                    table.insert(record.lines[buf], { l, set[l] })
                    count = count + 1
                end
                if not was_modified then
                    record.saved[buf] = true
                    vim.api.nvim_buf_call(buf, function()
                        vim.cmd.update({ mods = { emsg_silent = true, noautocmd = true } })
                    end)
                end
                record.ticks[buf] = vim.api.nvim_buf_get_changedtick(buf)
            end
            if count > 0 then
                table.insert(delete_history, record)
            end

            -- Remove deleted items, shift line numbers of the survivors
            local new_items = {}
            for _, item in ipairs(list.items) do
                local set = to_delete[item.bufnr]
                if not (set and set[item.lnum]) then
                    if set then
                        local shift = 0
                        for l in pairs(set) do
                            if l < item.lnum then shift = shift + 1 end
                        end
                        item.lnum = item.lnum - shift
                    end
                    table.insert(new_items, item)
                end
            end

            local what = { items = new_items, title = list.title, context = list.context }
            local view = vim.fn.winsaveview()
            if is_loc then
                vim.fn.setloclist(win, {}, "r", what)
            else
                vim.fn.setqflist({}, "r", what)
            end
            vim.fn.winrestview(view)

            local msg = string.format("Deleted %d line%s", count, count == 1 and "" or "s")
            if skipped > 0 then
                msg = msg .. string.format(" (%d skipped: source text differs)", skipped)
            end
            vim.notify(msg, skipped > 0 and vim.log.levels.WARN or vim.log.levels.INFO)
        end

        vim.api.nvim_create_autocmd("FileType", {
            pattern = "qf",
            callback = function(args)
                vim.keymap.set("n", "<leader>qd", function()
                    local l = vim.fn.line(".")
                    delete_items(l, l + vim.v.count1 - 1)
                end, { buffer = args.buf, desc = "Delete item(s) and source line(s)" })
                vim.keymap.set("n", "<leader>qu", undo_delete,
                    { buffer = args.buf, desc = "Undo last source-line deletion" })
                vim.keymap.set("x", "<leader>qd", function()
                    local a, b = vim.fn.line("v"), vim.fn.line(".")
                    vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "nx", false)
                    delete_items(math.min(a, b), math.max(a, b))
                end, { buffer = args.buf, desc = "Delete selected items and source lines" })
            end,
        })

        require("quicker").setup({
            keys = {
                {
                    ">",
                    function()
                        require("quicker").expand({ before = 2, after = 2, add_to_existing = true })
                    end,
                    desc = "Expand quickfix context",
                },
                {
                    "<",
                    function()
                        require("quicker").collapse()
                    end,
                    desc = "Collapse quickfix context",
                },
            },
        })
    end
}
