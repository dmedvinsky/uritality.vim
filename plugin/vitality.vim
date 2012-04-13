" ============================================================================
" File:        uritality.vim
" Description: Make Vim play nicely with URxvt and Tmux.
" Maintainer:  Dmitry Medvinsky <dmedvinsky@gmail.com>
" Based of:    vitality.vim by Steve Losh <steve@stevelosh.com>
" License:     MIT/X11
" ============================================================================

" Init {{{
if has('gui_running')
    finish
endif

if !exists('g:uritality_debug') && (exists('loaded_uritality') || &cp)
    finish
endif

let loaded_uritality = 1

if !exists('g:uritality_fix_cursor') " {{{
    let g:uritality_fix_cursor = 1
endif " }}}

let s:inside_tmux = exists('$TMUX')
" }}}

function! s:WrapForTmux(s) " {{{
    if s:inside_tmux
        " To escape a sequence through tmux:
        "
        " * Wrap it in these sequences.
        " * Any <Esc> characters inside it must be doubled.
        let tmux_start = "\<Esc>Ptmux;"
        let tmux_end   = "\<Esc>\\"

        return tmux_start . substitute(a:s, "\<Esc>", "\<Esc>\<Esc>", 'g') . tmux_end
    else
        return a:s
    endif
endfunction " }}}

function! s:URitality() " {{{
    " Escape sequences {{{

    " These sequences save/restore the screen.
    " They should NOT be wrapped in tmux escape sequences for some reason!
    let save_screen    = "\<Esc>[?1049h"
    let restore_screen = "\<Esc>[?1049l"

    " These sequences tell URxvt to change the cursor color.
    let cursor_green   = s:WrapForTmux("\<Esc>]12;green\x7")
    let cursor_red     = s:WrapForTmux("\<Esc>]12;red\x7")
    " }}}

    " Startup/shutdown escapes {{{

    " When starting Vim, save the screen.
    " When exiting Vim, save the screen.
    let &t_ti = save_screen
    let &t_te = restore_screen
    " }}}

    " Insert enter/leave escapes {{{
    " When entering insert mode, change the cursor to a bar.
    let &t_SI = cursor_red

    " When exiting insert mode, change it back to a block.
    let &t_EI = cursor_green
    " }}}
endfunction " }}}

call s:URitality()
