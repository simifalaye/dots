local lazy = require("utils.lazy")

lazy.now_if_args(function()
  local ns = vim.api.nvim_create_namespace("user.term.prompt")

  -- Autocmds
  local augroup = vim.api.nvim_create_augroup("user.term", { clear = true })
  vim.api.nvim_create_autocmd("TermOpen", {
    desc = "Term setup",
    group = augroup,
    pattern = { "{term,shell}://*", ":shell*" },
    callback = function()
      vim.cmd([=[
      " Enable prompt sign in :terminal buffers.
      setlocal signcolumn=auto

      nnoremap <silent><buffer> <cr> i<cr><c-\><c-n>
      nnoremap <silent><buffer> <c-c> i<c-c><c-\><c-n>
    ]=])
    end,
  })
  vim.api.nvim_create_autocmd("TermRequest", {
    desc = "Osc 7 and 133 support",
    group = augroup,
    callback = function(ev)
      if string.match(ev.data.sequence, "^\027]133;A") then
        -- OSC 133: shell-prompt
        local lnum = ev.data.cursor[1]
        vim.api.nvim_buf_set_extmark(ev.buf, ns, lnum - 1, 0, {
          sign_text = "∙",
          sign_hl_group = "SpecialChar",
        })
      end

      local val, n = string.gsub(ev.data.sequence, "^\027]7;file://[^/]*", "")
      if n > 0 then
        -- OSC 7: dir-change
        local dir = val
        assert(vim.fn.isdirectory(dir) ~= 0, "invalid dir: " .. dir)
        if vim.api.nvim_get_current_buf() == ev.buf then
          vim.cmd.lcd(dir)
        end
      end
    end,
  })

  -- Auto term
  -- Source: https://github.com/justinmk/config/blob/master/.config/nvim/lua/my/ctrl_s_shell.lua
  vim.cmd([[
  " :shell
  "
  " Creates a global default :shell with maximum 'scrollback'.
  func! s:auto_term(cnt, here) abort
    let g:term_shell = get(g:, 'term_shell', { 'prevwid': win_getid() })
    let b = bufnr(':shell')

    if bufexists(b) && a:here  " Edit the :shell buffer in this window.
      exe 'buffer' b
      setlocal nobuflisted
      let g:term_shell.prevwid = win_getid()
      return
    endif

    "
    " Return to previous window, maybe close the :shell tabpage.
    "
    if bufnr('%') == b
      let tab = tabpagenr()
      let term_prevwid = win_getid()
      if !win_gotoid(g:term_shell.prevwid)
        wincmd p
      endif
      if tabpagewinnr(tab, '$') == 1 && tabpagenr() != tab
      " Close the :shell tabpage if it's the only window in the tabpage.
        exe 'tabclose' tab
      endif
      if bufnr('%') == b
        " Edge-case: :shell buffer showing in multiple windows in curtab.
        " Find a non-:shell window in curtab.
        let bufs = filter(tabpagebuflist(), 'v:val != '.b)
        if len(bufs) > 0
          exe bufwinnr(bufs[0]).'wincmd w'
        else
          " Last resort: can happen if :mksession restores an old :shell.
          " tabprevious
          if &buftype !=# 'terminal' && getline(1) == '' && line('$') == 1
            " XXX: cleanup stale, empty :shell buffer (caused by :mksession).
            bwipeout! %
            " Try again.
            call s:auto_term(a:cnt, a:here)
          end
          return
        endif
      endif
      let g:term_shell.prevwid = term_prevwid

      return
    endif

    "
    " Go to existing :shell or create a new one.
    "
    let curwinid = win_getid()
    if a:cnt == 0 && bufexists(b) && winbufnr(g:term_shell.prevwid) == b
      " Go to :shell displayed in the previous window.
      call win_gotoid(g:term_shell.prevwid)
    elseif bufexists(b)
      " Go to existing :shell.

      let w = bufwinid(b)
      if a:cnt == 0 && w > 0
        " Found in current tabpage.
        call win_gotoid(w)
      else
        " Not in current tabpage.
        let ws = win_findbuf(b)
        if a:cnt == 0 && !empty(ws)
          " Found in another tabpage.
          call win_gotoid(ws[0])
        else
          " Not in any existing window; open a tabpage (or split-window if [count] was given).
          exe ((a:cnt == 0) ? 'tab split' : a:cnt.'split')
          exe 'buffer' b
        endif
      endif

      if &buftype !=# 'terminal' && getline(1) == '' && line('$') == 1
        call win_gotoid(g:term_shell.prevwid)
        " XXX: cleanup stale, empty :shell buffer (caused by :mksession).
        exe 'bwipeout!' b
        " Try again.
        call s:auto_term(a:cnt, a:here)
      end
    else
      " Create new :shell.
      let origbuf = bufnr('%')
      if !a:here
        exe ((a:cnt == 0) ? 'tab split' : a:cnt.'split')
      endif
      terminal
      setlocal scrollback=-1
      " TODO: call nvim_buf_set_name(0, bufname('%') .. '#shell')
      file :shell
      " XXX: original term:// buffer hangs around after :file ...
      bwipeout! #
      autocmd VimLeavePre * bwipeout! ^:shell$
      " Set alternate buffer to something intuitive.
      let @# = origbuf
      tnoremap <buffer> <C-s> <C-\><C-n>:call <SID>auto_term(0, v:false)<CR>
    endif

    let g:term_shell.prevwid = curwinid
    setlocal nobuflisted
  endfunc
  nnoremap <M-;> <cmd>call <SID>auto_term(v:count, v:false)<CR>
  nnoremap '<M-;> <cmd>call <SID>auto_term(v:count, v:true)<CR>
  ]])
end)
