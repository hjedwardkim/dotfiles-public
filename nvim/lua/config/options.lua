-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Neovide

if vim.g.neovide then
  -- Appearance
  local alpha = function()
    return string.format("%x", math.floor(255 * vim.g.transparency or 0.8))
  end

  vim.g.neovide_transparency = 1.0
  vim.g.neovide_normal_opacity = 0.20
  vim.g.transparency = 0.8
  vim.cmd([[highlight Normal guibg=NONE]])
  vim.cmd([[highlight NonText guibg=NONE]])
  vim.cmd([[highlight Normal ctermbg=NONE guibg=NONE]])
  vim.cmd([[highlight SignColumn ctermbg=NONE guibg=NONE]])

  vim.g.neovide_background_color = "#24283b" .. alpha()

  vim.g.neovide_window_blurred = true
  --vim.g.neovide_floating_blur_amount_x = 1.0
  --vim.g.neovide_floating_blur_amount_y = 1.0
  vim.g.neovide_floating_shadow = true
  vim.g.neovide_light_radius = 15

  vim.g.neovide_padding_top = 10
  vim.g.neovide_padding_bottom = 10
  vim.g.neovide_padding_left = 10
  vim.g.neovide_padding_right = 10

  vim.g.neovide_show_border = true
  vim.g.neovide_title_text_color = "#24283b"

  -- Keymaps
  vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Page down and center" })
  vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Page up and center" })
  vim.keymap.set("n", "n", "nzz", { desc = "Next result centered" })
  vim.keymap.set("n", "N", "Nzz", { desc = "Previous result centered" })
end
