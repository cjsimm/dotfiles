return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  event = "VeryLazy", -- only load when explicitly used
  config = function()
    require("copilot").setup({
      suggestion = { enabled = false }, -- turn off inline suggestions
      panel = { enabled = false },      -- turn off Copilot panel
      auto_attach = false,              -- never auto-attach to buffers
      filetypes = { ["*"] = false },    -- never attach to any filetype
    })
  end,
}
