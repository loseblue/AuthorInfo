"=============================================================================
"  Author:          dantezhu - http://www.vimer.cn
"  Email:           zny2008@gmail.com
"  FileName:        authorinfo.vim
"  Description:     
"  Version:         1.6
"  LastChange:      2012-10-24 15:10:54
"  History:         support bash's #!xxx
"                   fix bug for NerdComment's <leader>
"=============================================================================
if exists('g:loaded_authorinfo')
    finish
endif
let g:loaded_authorinfo= 1

if exists("mapleader")
    let s:t_mapleader = mapleader
elseif exists("g:mapleader")
    let s:t_mapleader = g:mapleader
else
    let s:t_mapleader = '\'
endif

function! g:CheckFileType(type)
    let t_filetypes = split(&filetype,'\.')
    if index(t_filetypes,a:type)>=0
        return 1
    else
        return 0
    endif
endfunction
function s:DetectFirstLine()
    exe 'normal '.1.'G'
    let arrData = [
                \['sh',['^#!.*$']],
                \['python',['^#!.*$','^#.*coding:.*$']],
                \['php',['^<?.*']]
                \]
    let oldNum = line('.')
    while 1
        let line = getline('.')
        let findMatch = 0
        for [t,v] in arrData
            if g:CheckFileType(t)
                for it in v
                    if line =~ it
                        let findMatch = 1
                        break
                    endif
                endfor
            endif
        endfor
        if findMatch != 1
            break
        endif
        normal j
        if oldNum == line('.')
            normal o
            return
        endif
        let oldNum = line('.')
    endwhile
    normal O
endfunction
function s:BeforeTitle()
    let arrData = [['python',"'''"]]
    for [t,v] in arrData
        if g:CheckFileType(t)
            call setline('.',v)
            normal o
            break
        endif
    endfor
endfunction
function s:AfterTitle()
    let arrData = [['python',"'''"]]
    for [t,v] in arrData
        if g:CheckFileType(t)
            normal o
            call setline('.',v)
            normal k
            break
        endif
    endfor
endfunction
function s:AddTitle()
    call s:DetectFirstLine()
    let hasMul = 0
    let preChar = ''
    let noTypeChar = ''

    call setline('.','test mul')
    let oldline = getline('.')
    exec 'normal '.s:t_mapleader.'cm'
    let newline = getline('.')
    if oldline != newline
        let hasMul = 1
        let preChar = '#'
    else
        exec 'normal '.s:t_mapleader.'cl'
        let newline = getline('.')
        if oldline == newline
            let hasMul = -1
            let noTypeChar = '#'
        endif
    endif

    call s:BeforeTitle()

    let firstLine = line('.')
    call setline('.',noTypeChar.'=============================================================================')
    normal o
    call setline('.',noTypeChar.preChar.'     FileName: '.expand("%:t"))
    normal o
    call setline('.',noTypeChar.preChar.'         Desc: ')
    let gotoLn = line('.')
    normal o
    call setline('.',noTypeChar.preChar.'       Author: '.g:vimrc_author)
    normal o
    call setline('.',noTypeChar.preChar.'        Email: '.g:vimrc_email)
    normal o
    call setline('.',noTypeChar.preChar.'     HomePage: '.g:vimrc_homepage)
    normal o
    call setline('.',noTypeChar.preChar.'      Version: 0.0.1')
    normal o
    call setline('.',noTypeChar.preChar.'   LastChange: '.strftime("%Y-%m-%d %H:%M:%S"))
    normal o
    call setline('.',noTypeChar.preChar.'      History:')
    normal o
    call setline('.',noTypeChar.'=============================================================================')
    let lastLine = line('.')

    call s:AfterTitle()

    if hasMul == 1
        exe 'normal '.firstLine.'Gv'.lastLine.'G'.s:t_mapleader.'cm'
    else
        exe 'normal '.firstLine.'Gv'.lastLine.'G'.s:t_mapleader.'cl'
    endif

    exe 'normal '.gotoLn.'G'
    startinsert!
    echohl WarningMsg | echo "Succ to add the copyright." | echohl None
endf
function s:TitleDet()
    silent! normal ms
    let updated = 0
    let n = 1
    while n < 20
        let line = getline(n)
        if line =~ '^.*FileName:\S*.*$'
            let newline=substitute(line,':\(\s*\)\(\S.*$\)$',':\1'.expand("%:t"),'g')
            call setline(n,newline)
            let updated = 1
        endif
        if line =~ '^.*LastChange:\S*.*$'
            let newline=substitute(line,':\(\s*\)\(\S.*$\)$',':\1'.strftime("%Y-%m-%d %H:%M:%S"),'g')
            call setline(n,newline)
            let updated = 1
        endif
        let n = n + 1
    endwhile
    if updated == 1
        silent! normal 's
        echohl WarningMsg | echo "Succ to update the copyright." | echohl None
        return
    endif
    call s:AddTitle()
endfunction
command! -nargs=0 AuthorInfoDetect :call s:TitleDet()
