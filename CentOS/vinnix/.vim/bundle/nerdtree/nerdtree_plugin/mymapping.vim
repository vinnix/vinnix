call NERDTreeAddKeyMap({
  \ 'key': '<CR>',
  \ 'scope': "Node",
  \ 'callback': 'OpenInNewTab',
  \ 'quickhelpText': 'open node' })


" FUNCTION: s:openInNewTab(target) {{{1
function! OpenInNewTab(node)
  if a:node.path.isDirectory
    call a:node.activate()
  else
    call a:node.activate({'where': 't'})
    call g:NERDTreeCreator.CreateMirror()
    wincmd l
  endif
endfunction

