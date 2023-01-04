return {
  {
    "ibhagwan/fzf-lua",
    lazy = false,
    branch = "main",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      local fzf = require("fzf-lua")
      local fwrap = function(func, arg)
        return function()
          func(arg)
        end
      end

      -- Setup keymaps
      -- -------------
      local m = require("conf.utils.map")
      -- root
      m.nnoremap("<C-f>", fzf.live_grep, "Find text")
      m.nnoremap("<C-p>", fzf.files, "Find Files")
      m.nnoremap("<leader>;", fzf.buffers, "Find Buffer")
      m.nnoremap("<leader>:", fzf.command_history, "Find CmdHist")
      m.nnoremap("<leader>,", fzf.oldfiles, "Find Recent")
      m.nnoremap("<leader>.", fzf.resume, "Find resume")
      m.nnoremap("<leader>/", fzf.search_history, "Search Hist")

      m.group("<leader>f", "+find")
      m.nnoremap("<leader>f'", fzf.marks, "Marks")
      m.nnoremap('<leader>f"', fzf.registers, "Registers")
      m.nnoremap("<leader>f*", fzf.blines, "(in) Buffer")
      m.nnoremap("<leader>fc", fzf.commands, "Commands")
      m.nnoremap(
        "<leader>ff",
        fwrap(fzf.files, {
          fd_opts = "--no-ignore --color=never --type f --hidden --follow --exclude .git",
        }),
        "Files (all)"
      )
      m.nnoremap("<leader>fh", fzf.help_tags, "Help tags")
      m.nnoremap("<leader>fk", fzf.keymaps, "Keymaps")
      m.nnoremap("<leader>fm", fzf.man_pages, "Man Pages")
      m.nnoremap("<leader>fq", fzf.quickfix, "Quickfix")
      -- git
      m.group("<leader>fg", "+git")
      m.nnoremap("<leader>fgb", fzf.git_branches, "Branches")
      m.nnoremap("<leader>fgc", fzf.git_commits, "Commits")
      m.nnoremap("<leader>fgC", fzf.git_bcommits, "Commits (buf)")
      m.nnoremap("<leader>fgf", fzf.git_files, "Files")
      m.nnoremap("<leader>fgs", fzf.git_status, "Status")
      -- lsp
      m.group("<leader>fl", "+lsp")
      m.nnoremap("<leader>flc", fzf.lsp_code_actions, "Code actions")
      m.nnoremap(
        "<leader>fld",
        fzf.lsp_document_diagnostics,
        "Diagnostics (document)"
      )
      m.nnoremap(
        "<leader>flD",
        fzf.lsp_workspace_diagnostics,
        "Diagnostics (workspace)"
      )
      m.nnoremap("<leader>fls", fzf.lsp_document_symbols, "Symbols (document)")
      m.nnoremap(
        "<leader>flS",
        fzf.lsp_workspace_symbols,
        "Symbols (workspace)"
      )
      -- notes
      local n_opts = { prompt = "Notes> ", cwd = "~/Notes" }
      m.group("<leader>fn", "+notes")
      m.nnoremap("<leader>fnf", fwrap(fzf.files, n_opts), "Files")
      m.nnoremap("<leader>fng", fwrap(fzf.live_grep, n_opts), "Search")
      -- yadm
      local yadm_git_dir = "$HOME/.local/share/yadm/repo.git"
      local yadm_cmd =
        string.format("yadm -C $HOME --yadm-repo %s", yadm_git_dir)
      local yadm_git_opts = {
        show_cwd_header = false,
        git_dir = yadm_git_dir,
      }
      local yadm_grep_opts = {
        prompt = "YadmGrep❯ ",
        cwd = "$HOME",
        cmd = ("%s grep --line-number --column --color=always"):format(
          yadm_cmd
        ),
        rg_glob = false, -- this isn't `rg`
      }
      m.group("<leader>fy", "+yadm")
      m.nnoremap(
        "<leader>fyb",
        fwrap(fzf.git_branches, yadm_git_opts),
        "Branches"
      )
      m.nnoremap(
        "<leader>fyc",
        fwrap(fzf.git_commits, yadm_git_opts),
        "Commits"
      )
      m.nnoremap(
        "<leader>fyC",
        fwrap(fzf.git_bcommits, yadm_git_opts),
        "Commits (buf)"
      )
      m.nnoremap("<leader>fyf", fwrap(fzf.git_files, yadm_git_opts), "Files")
      m.nnoremap("<leader>fyg", fwrap(fzf.live_grep, yadm_grep_opts), "Grep")
      m.nnoremap("<leader>fys", fwrap(fzf.git_status, yadm_git_opts), "Status")
    end,
  },
}
