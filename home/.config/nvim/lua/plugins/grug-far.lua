return {
    "MagicDuck/grug-far.nvim",
    keys = {
        {
            "<leader>as",
            function()
                require("grug-far").open({ transient = true })
            end,
            desc = "Search and replace",
        },
    },
    cmd = { "GrugFar", "GrugFarWithin" },
    config = function()
        require("grug-far").setup({
            -- keymaps are buffer local, false removes the default (localleader) mapping
            keymaps = {
                gotoLocation = { n = "<c-l>" },
                syncLocations = { n = "<c-y>" },
                previewLocation = { n = "K" },
                applyNext = { n = "<c-j>" },
                nextInput = { n = "<c-n>" },
                prevInput = { n = "<c-p>" },
                qflist = { n = "<c-q>" },
                historyOpen = { n = "L" },
                openNextLocation = { n = "<down>" },
                openPrevLocation = { n = "<up>" },
                pickHistoryEntry = { n = "<enter>" },
                help = { n = "g?" },
                replace = false,
                syncLine = false,
                syncFile = false,
                syncNext = false,
                syncPrev = false,
                close = false,
                historyAdd = false,
                refresh = false,
                openLocation = false,
                abort = false,
                toggleShowCommand = false,
                swapEngine = false,
                swapReplacementInterpreter = false,
                applyPrev = false,
            },
        })

        -- flag toggles aren't grug-far actions, so map them through the instance api
        vim.api.nvim_create_autocmd("FileType", {
            group = vim.api.nvim_create_augroup("grug-far-keybindings", { clear = true }),
            pattern = { "grug-far" },
            callback = function()
                vim.keymap.set("n", "H", function()
                    require("grug-far").get_instance(0):toggle_flags({ "--hidden" })
                end, { buffer = true, desc = "Toggle search hidden" })
            end,
        })
    end,
}
