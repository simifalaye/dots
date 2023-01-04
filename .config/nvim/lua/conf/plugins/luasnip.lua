return {
  {
    "L3MON4D3/LuaSnip",
    tag = "v1.0.0",
    dependencies = { "rafamadriz/friendly-snippets" },
    event = "InsertEnter",
    config = function()
      local luasnip = require("luasnip")
      local fmt = require("luasnip.extras.fmt").fmt
      local types = require("luasnip.util.types")
      local extras = require("luasnip.extras")

      -- Setup plugin
      luasnip.config.set_config({
        history = false,
        region_check_events = "CursorMoved,CursorHold,InsertEnter",
        delete_check_events = "InsertLeave",
        ext_opts = {
          [types.choiceNode] = {
            active = {
              hl_mode = "combine",
              virt_text = { { "?", "Operator" } },
            },
          },
          [types.insertNode] = {
            active = {
              hl_mode = "combine",
              virt_text = { { ">", "Type" } },
            },
          },
        },
        enable_autosnippets = true,
        snip_env = {
          fmt = fmt,
          m = extras.match,
          t = luasnip.text_node,
          f = luasnip.function_node,
          c = luasnip.choice_node,
          d = luasnip.dynamic_node,
          i = luasnip.insert_node,
          l = extras.lamda,
          snippet = luasnip.snippet,
        },
      })

      -- Load snippets
      require("luasnip/loaders/from_lua").lazy_load()
      require("luasnip/loaders/from_vscode").lazy_load() -- friendly-snippets

      -- Set keymaps
      local m = require("conf.utils.map")
      m.noremap({ "s", "i" }, "<C-l>", function()
        if luasnip.choice_active() then
          luasnip.change_choice(1)
        end
      end, "Snippet choice select")
      m.noremap({ "s", "i" }, "<C-j>", function()
        if luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        end
      end, "Snippet expand")
      m.noremap({ "s", "i" }, "<C-b>", function()
        if luasnip.jumpable(-1) then
          luasnip.jump(-1)
        end
      end, "Snippet jump")
    end,
  },
}
