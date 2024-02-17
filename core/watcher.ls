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
      builder.get-font (e) !->
        if e? then builder.final-cb e, void
        else
          for fle in cfg.chok[pth] then builder.do-exec cfg.chok[fle]
    else
      console.log "recompiling: '#pth'"
      builder.do-exec cfg.chok[pth]
  watcher.on \error, (e) !->
    console.log 'CHOKIDAR ERROR:\n'
    console.log e
  watcher.on \unlink, (pth) !-> builder.copy-statiq builder.final-cb
  cb void 31
