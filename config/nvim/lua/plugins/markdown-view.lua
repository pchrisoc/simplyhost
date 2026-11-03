-- Enable Markdown rendering for new and existing LazyVim installations.
return {
  { import = "lazyvim.plugins.extras.lang.markdown" },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      heading = {
        icons = { " " },
        position = "inline",
        sign = false,
      },
      -- Reveal source only around the line being edited.
      anti_conceal = { enabled = true, above = 0, below = 0 },
      win_options = { conceallevel = { default = 0, rendered = 2 } },
    },
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("markdown_reading_view", { clear = true }),
        pattern = { "markdown", "markdown.mdx" },
        callback = function(event)
          vim.opt_local.conceallevel = 2
          -- Keep Markdown prose free of lint messages, signs and underlines.
          vim.diagnostic.enable(false, { bufnr = event.buf })
        end,
      })
    end,
  },
}
