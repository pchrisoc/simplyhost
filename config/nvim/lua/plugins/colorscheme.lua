return {
  {
    "folke/tokyonight.nvim",
    opts = {
      style = "storm",
      transparent = false,
      on_colors = function(colors)
        local palette = {
          bg = "#102A43",
          bg_dark = "#0B2135",
          bg_dark1 = "#081C2D",
          bg_float = "#0B2135",
          bg_popup = "#0B2135",
          bg_sidebar = "#0B2135",
          bg_statusline = "#0B2135",
          bg_highlight = "#1A3F5C",
          bg_visual = "#245A81",
          bg_search = "#28668F",
          fg = "#D9EAF7",
          fg_dark = "#A8C9DF",
          fg_sidebar = "#A8C9DF",
          fg_float = "#D9EAF7",
          fg_gutter = "#47708C",
          comment = "#739BB5",
          dark3 = "#466E89",
          dark5 = "#83A9C2",
          black = "#081C2D",
          terminal_black = "#365B75",
          blue = "#82C5ED",
          blue0 = "#245A81",
          blue1 = "#82C5ED",
          blue2 = "#7BA7E8",
          blue5 = "#91B4CF",
          blue6 = "#A1DCE5",
          blue7 = "#244D6B",
          cyan = "#A1DCE5",
          teal = "#65ADA5",
          green = "#83C7C1",
          green1 = "#83C7C1",
          green2 = "#65ADA5",
          yellow = "#D8BE85",
          orange = "#A1DCE5",
          red = "#D98E96",
          red1 = "#D98E96",
          magenta = "#7BA7E8",
          magenta2 = "#82C5ED",
          purple = "#7BA7E8",
          border = "#37688A",
          border_highlight = "#37688A",
          error = "#D98E96",
          warning = "#D8BE85",
          info = "#82C5ED",
          hint = "#65ADA5",
          todo = "#7BA7E8",
          git = { add = "#65ADA5", change = "#7BA7E8", delete = "#D98E96", ignore = "#739BB5" },
          diff = { add = "#21444F", change = "#203E64", delete = "#384154", text = "#245A81" },
          rainbow = { "#7BA7E8", "#82C5ED", "#83C7C1", "#A1DCE5", "#91B4CF", "#65ADA5" },
          terminal = {
            black = "#081C2D", black_bright = "#365B75",
            red = "#D98E96", red_bright = "#EAA9AF",
            green = "#83C7C1", green_bright = "#A4DDD7",
            yellow = "#D8BE85", yellow_bright = "#E8D4A8",
            blue = "#7BA7E8", blue_bright = "#A3C7F5",
            magenta = "#82C5ED", magenta_bright = "#ACDDF7",
            cyan = "#A1DCE5", cyan_bright = "#C2EBF0",
            white = "#A8C9DF", white_bright = "#D9EAF7",
          },
        }
        for key, value in pairs(palette) do
          colors[key] = value
        end
      end,
      on_highlights = function(highlights)
        highlights.PmenuSel = { bg = "#245A81", fg = "#E5F2FA", bold = true }
        highlights.CursorLineNr = { fg = "#82C5ED", bold = true }
        highlights.DiagnosticError = { fg = "#D98E96", bold = true }
        highlights.DiagnosticWarn = { fg = "#D8BE85", underline = true }
        highlights.Keyword = { fg = "#7BA7E8", italic = true }
        highlights.String = { fg = "#83C7C1" }
        highlights.Function = { fg = "#82C5ED" }
        highlights.Number = { fg = "#A1DCE5" }
        highlights.Constant = { fg = "#A1DCE5" }
        highlights.Boolean = { fg = "#A1DCE5" }
        highlights.Float = { fg = "#A1DCE5" }
        highlights.Operator = { fg = "#91B4CF" }
        highlights.Delimiter = { fg = "#91B4CF" }
      end,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight-storm",
    },
  },
}
