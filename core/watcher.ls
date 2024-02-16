require! {
  chokidar, path
  './builder': builder
}

export watching = (cb) !->
  chkstatiq = /statiq/
  chokopts = awaitWriteFinish: { pollInterval: 200 }
  watcher = chokidar.watch Object.keys cfg.chok, chokopts
  watcher.on \add, (pth) !->
    pth = pth.replaceAll '\\', '/'
    file = path.basename pth
    if chkstatiq.test pth and file not in cfg.statiq
      builder.copy-statiq builder.final-cb
  watcher.on \change, (pth) !->
    pth = pth.replaceAll '\\', '/'
    if pth[0] is \. then pth.slice 2
    if chkstatiq.test pth then builder.copy-statiq builder.final-cb
    else if /font/.test pth
      builder.get-font builder.final-cb
      for fle in cfg.chok[pth]
        builder.do-exec fle, cfg.chok[fle].outf, cfg.chok[fle].lg
    else
      console.log "recompiling: '#pth'"
      builder.do-exec pth, cfg.chok[pth].outf, cfg.chok[pth].lg
  watcher.on \error, (e) !->
    console.log 'CHOKIDAR ERROR:\n'
    console.log e
  watcher.on \unlink, (pth) !-> builder.copy-statiq builder.final-cb
  cb void 31
