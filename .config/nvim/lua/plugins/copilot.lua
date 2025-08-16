return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "nvim-lua/plenary.nvim", branch = "master" },
    },
    build = "make tiktoken",
    opts = {
      mappings = {
        toggle = {
          normal = "<C-i>", -- Alt+i in normal mode
          insert = "<C-i>", -- Alt+i in insert mode
        },
      },
    },
  },
}
