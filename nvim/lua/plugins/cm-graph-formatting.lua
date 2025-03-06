-- cm-graph-formatting.lua
-- Configuration for ConfidentialMind Graph Python formatting

return {
  -- Configure conform.nvim for formatting
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        python = { "isort", "ruff_format" }, -- Add isort before ruff_format
      },
      formatters = {
        ruff_format = {
          -- Ruff will automatically read from pyproject.toml
        },
        isort = {
          -- Add isort configuration to match pyproject.toml
          prepend_args = {
            "--profile=black",
            "--line-length=120",
            "--filter-files",
            "--atomic",
          },
        },
      },
    },
  },

  -- Configure nvim-lint for linting
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        python = { "ruff" },
      },
      linters = {
        ruff = {
          -- Configure ruff linter to match pyproject.toml settings
          args = {
            "--select=E402,F811,E722",
            "--line-length=120",
            "--fix",
          },
        },
      },
    },
  },

  -- Configure ruff-lsp
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ruff_lsp = {
          -- Configure ruff-lsp to use the right settings
          settings = {
            lint = {
              -- Match the selection in pyproject.toml
              select = { "E402", "F811", "E722" },
            },
            format = {
              lineLength = 120,
            },
          },
          on_attach = function(client, _)
            -- Disable formatting since we're using conform.nvim with ruff_format
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
          end,
        },
        pylsp = {
          -- If using python-lsp-server, configure it to respect the line length
          settings = {
            pylsp = {
              plugins = {
                pycodestyle = {
                  maxLineLength = 120,
                },
              },
            },
          },
        },
      },
    },
  },

  -- Ensure tools are installed
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "ruff",
        "ruff-lsp",
        "isort", -- Add isort to the installation list
      })
    end,
  },

  -- Add global editor configuration for line length
  {
    "LazyVim/LazyVim",
    opts = {
      -- These will apply to Python files
      autocmds = {
        {
          "FileType",
          {
            pattern = "python",
            callback = function()
              vim.opt_local.textwidth = 120
              -- Optional: Set colorcolumn to show the line length limit
              vim.opt_local.colorcolumn = "120"
            end,
          },
        },
      },
    },
  },
}
