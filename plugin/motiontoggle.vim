" motiontoggle.vim
" Author: Vincent Wang (linsong dot qizi at gmail dot com) & Updated by Zack
" Frost
" Created:  Fri Jun 29 18:06:29 CST 2007
" Requires: Vim Ver7.0+ 
" Version:  1.5
"
" Documentation: 
"   The purpose of this plugin is very simple, it can toggle words among
"   'true'=>'false', 'True'=>'False', 'if'=>'elseif'=>'else'=>'endif' etc . 
"
"   To use it, move the cursor on some words like 'true', 'False', 'YES', etc, 
"   call command 
"     :ToggleWord
"
"   It will toggle 'true'=>'false', 'False'=>'True', 'YES'=>'NO' etc. Yes,
"   this script will try to take the case into account when toggling words, so
"   'True' will be toggled to 'False' instead of 'false'. Currently the way to
"   check the case is very simple, but it works well for me.
"
"   You can define a map for 'ToggleWord' comand to make it easier: 
"     nmap ,t :ToggleWord<CR>
"
"   This script can search the candicate words to toggle based on
"   current filetype, for example, you can put the following configuration
"   into your .vimrc to define some words for python:
"      let g:motion_toggle_words = {'python': [['if', 'elif', 'else']]}
"   
"   There are some default words for toggling predefined in the
"   script(g:_toogle_words_dict) that will work for all filetypes.
"   Any comment, suggestion, bug report are welcomed. 
"
" History:
"  1.5:
"    - add support to extend default toggle words ('*'), based on patch
"    provided by Jeremy Cantrell, thanks
"  1.4:
"    - add one more toggle word option: 1 and 0
"  1.3:
"    - fix error of 'E488: Trailing characters', patch provided by Jeremy Cantrell
"  1.2:
"    - fixed typo(november => novermber)
"    - sorted and stacked the definitions to make them more readable/editable
"    - added a few new definitions (allow/deny, min/max, before/after, block/inline/none, left/right)
"    - add revision history 
"    - most of above changes come from Fergus Bremner, thanks Fergus!
"
"  1.1:
"    - add a simple case sensitive support 
"
"  1.0:
"    - initial upload
"
" Contributors:
"  Fergus Bremner
"  Jeremy Cantrell
"
"   Thanks! 

if v:version < 700
    "TODO: maybe I should make this script works under vim7.0
    echo "This script required vim7.0 or above version." 
    finish 
endif

if exists("g:load_motiontoggle")
   finish
endif

let s:keepcpo= &cpo
set cpo&vim

let g:load_motiontoggle = "1.5"

let g:_motion_toggle_words = {'*': [
    \ ['==', '!='], 
    \ ['>', '<'], 
    \ ['(', ')'], 
    \ ['[', ']'], 
    \ ['{', '}'], 
    \ ['+', '-'], 
    \ ['allow', 'deny'], 
    \ ['before', 'after'], 
    \ ['block', 'inline', 'none'],
    \ ['define', 'undef'], 
    \ ['good', 'bad'], 
    \ ['if', 'elseif', 'else', 'endif'], 
    \ ['in', 'out'], 
    \ ['left', 'right'],
    \ ['min', 'max'], 
    \ ['on', 'off'], 
    \ ['start', 'stop'], 
    \ ['success', 'failure'], 
    \ ['true', 'false'],
    \ ['up', 'down'], 
    \ ['left', 'right'],
    \ ['yes', 'no'], 
    \ ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'], 
    \ ['january', 'february', 'march', 'april', 'may', 'june', 'july', 'august', 'september', 'october', 'november', 'december'], 
    \ ['1', '0'],
    \ [],
    \ ],  }

if exists('g:motion_toggle_words')
    for key in keys(g:motion_toggle_words)
        if has_key(g:_motion_toggle_words, key)
            call extend(g:_motion_toggle_words[key], g:motion_toggle_words[key])
        else
            let g:_motion_toggle_words[key] = g:motion_toggle_words[key]
        endif
    endfor
endif

function! ToggleMotion(type)
    let cur_filetype = &filetype
    if ! has_key(g:_motion_toggle_words, cur_filetype)
        let words_candicates_array = g:_motion_toggle_words['*']
    else
        let words_candicates_array = g:_motion_toggle_words[cur_filetype] + g:_motion_toggle_words['*']
    endif
    let cur_word = ""
	let last_reg = @@
	if a:type==# 'v'
		" Characterwise visual mode
		execute "normal! `<v`>y"
		let cur_word = @@
	elseif a:type ==# 'char'
		" Normal mode
		execute "normal! `[v`]y"
		let cur_word = @@
	else
		" Linewise or blockwise mode	
		return
	endif
	let @@ = last_reg

    let word_attr = 0 " 0 - lowercase; 1 - Capital; 2 - uppercase

    if toupper(cur_word)==#cur_word
        let word_attr = 2
    elseif cur_word ==# substitute(cur_word, '.*', '\u\0', '')
        let word_attr = 1
    else
        let word_attr = 0
    endif
    let cur_word = tolower(cur_word)

    for words_candicates in words_candicates_array
        let index = index(words_candicates, cur_word)
        if index != -1
            let new_word_index = (index+1)%len(words_candicates)
            let new_word = words_candicates[new_word_index]
            if word_attr==2
                let new_word =toupper(new_word)
            elseif word_attr==1
                let new_word = substitute(new_word, '.*', '\u\0', '')
            else
                let new_word = tolower(new_word)
            endif

            " use the new word to replace the old word
            exec "norm gvc" . new_word . ""
            break
        endif
    endfor
endfunction

nnoremap tt :set operatorfunc=ToggleMotion<CR>g@
vnoremap tt :<C-u>call ToggleMotion(visualmode())<CR>gv

let &cpo= s:keepcpo
unlet s:keepcpo
