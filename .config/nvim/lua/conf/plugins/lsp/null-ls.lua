return function(options)
  local utils = require("conf.utils")
  local nls = require("null-ls")
  nls.setup({
    debug = true,
    debounce = 150,
    save_after_format = false,
    sources = {
      nls.builtins.formatting.prettier.with({
        condition = function()
          return utils.executable("prettier")
        end,
      }),
      nls.builtins.formatting.stylua.with({
        condition = function()
          return utils.executable("stylua")
        end,
        extra_args = function(params)
          if
            utils.file_exists(utils.join_paths(params.root, "stylua.toml"))
            or utils.file_exists(utils.join_paths(params.root, ".stylua.toml"))
          then
            return {}
          end
          return {
            "--column-width",
            "80",
            "--indent-width",
            "2",
            "--indent-type",
            "Spaces",
            "--quote-style",
            "AutoPreferDouble",
          }
        end,
      }),
    },
    on_attach = options.on_attach,
  })
end
