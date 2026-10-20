-- Apply SimplyHost editor preferences without replacing an existing options.lua.
return {
  {
    "LazyVim/LazyVim",
    opts = function()
      vim.opt.number = true
      vim.opt.relativenumber = false
      vim.opt.tabstop = 2
      vim.opt.shiftwidth = 2
      vim.opt.wrap = false
    end,
  },
}
