return {
    "nvim-mini/mini.jump",
    version = false,
    config = function()
        local mini_jump = require("mini.jump")
        mini_jump.setup({
            delay = {
                highlight = 0,
                idle_stop = 2000,
            },
            silent = true,
        })
    end,
}
