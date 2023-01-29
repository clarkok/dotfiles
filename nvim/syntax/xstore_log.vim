" Vim syntax file
" Language: XStore Log
" Maintainer: Jingchao Zhang
" Latest Revision: 17 Dec 2018

if exists("b:current_syntax")
    finish
endif

syn match numberFields '="\d\+"'
syn keyword xstoreLogFieldsKeywords Pid Tid SrcLine nextgroup=numberFields

syn match uuidFields '="[0-9A-Fa-f]\{8\}-[0-9A-Fa-f]\{4\}-[0-9A-Fa-f]\{4\}-[0-9A-Fa-f]\{4\}-[0-9A-Fa-f]\{12\}"'
syn keyword xstoreLogFieldsKeywords ActivityId EntryId nextgroup=uuidFields

syn match stringFields '="[^"]*"'
syn keyword xstoreLogFieldsKeywords SrcFile SrcFunc TS nextgroup=stringFields

syn match messageFields '=".*"'
syn keyword xstoreLogFieldsKeywords String1 nextgroup=messageFields

syn match instanceLabel '\([-a-zA-Z0-9]\+\$\|\)[a-zA-Z]\+_\(IN\|in\)_\d\+:'
syn match logFileLabel 'cosmos[a-zA-Z._0-9]\+.\(bin\|log\):'
syn match infoTimeStamp 'i,\d\d/\d\d/\d\d\d\d \d\d:\d\d:\d\d.\d\d\d\d\d\d,[a-zA-Z0-9_.]\+,[a-zA-Z0-9_.]\+'
syn match debugTimeStamp 'd,\d\d/\d\d/\d\d\d\d \d\d:\d\d:\d\d.\d\d\d\d\d\d,[a-zA-Z0-9_.]\+,[a-zA-Z0-9_.]\+'
syn match warnTimeStamp 'w,\d\d/\d\d/\d\d\d\d \d\d:\d\d:\d\d.\d\d\d\d\d\d,[a-zA-Z0-9_.]\+,[a-zA-Z0-9_.]\+'
syn match statusTimeStamp 's,\d\d/\d\d/\d\d\d\d \d\d:\d\d:\d\d.\d\d\d\d\d\d,[a-zA-Z0-9_.]\+,[a-zA-Z0-9_.]\+'
syn match errorTimeStamp 'e,\d\d/\d\d/\d\d\d\d \d\d:\d\d:\d\d.\d\d\d\d\d\d,[a-zA-Z0-9_.]\+,[a-zA-Z0-9_.]\+'

let b:current_syntax = "xstore_log"
hi def link numberFields Constant
hi def link uuidFields Constant
hi def link stringFields Constant
hi def link xstoreLogFieldsKeywords Type

hi def link instanceLabel PreProc
hi def link logFileLabel PreProc
hi def link infoTimeStamp Comment
hi def link debugTimeStamp Comment
hi def link warnTimeStamp Todo
hi def link statusTimeStamp Todo
hi def link errorTimeStamp Error
