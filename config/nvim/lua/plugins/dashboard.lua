-- Keep every row the same width so dashboard centering preserves the lettering.
local function align_header(text)
  local lines = vim.split(text, "\n", { trimempty = true })
  local width = 0
  for _, line in ipairs(lines) do
    width = math.max(width, vim.fn.strdisplaywidth(line))
  end
  for index, line in ipairs(lines) do
    lines[index] = line .. string.rep(" ", width - vim.fn.strdisplaywidth(line))
  end
  return table.concat(lines, "\n")
end

return {
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        preset = {
          header = align_header([[
███████╗██╗███╗   ███╗██████╗ ██╗     ██╗   ██╗██╗  ██╗ ██████╗ ███████╗████████╗
██╔════╝██║████╗ ████║██╔══██╗██║     ╚██╗ ██╔╝██║  ██║██╔═══██╗██╔════╝╚══██╔══╝
███████╗██║██╔████╔██║██████╔╝██║      ╚████╔╝ ███████║██║   ██║███████╗   ██║
╚════██║██║██║╚██╔╝██║██╔═══╝ ██║       ╚██╔╝  ██╔══██║██║   ██║╚════██║   ██║
███████║██║██║ ╚═╝ ██║██║     ███████╗   ██║   ██║  ██║╚██████╔╝███████║   ██║
╚══════╝╚═╝╚═╝     ╚═╝╚═╝     ╚══════╝   ╚═╝   ╚═╝  ╚═╝ ╚═════╝ ╚══════╝   ╚═╝
]]),
        },
      },
    },
  },
}
