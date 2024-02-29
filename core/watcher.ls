require! { bach, chokidar, path, './builder' }

export watching = (cb) !->
  chkstatiq = /statiq/
  chkviews = /views/
  chokopts = awaitWriteFinish: { pollInterval: 200 }
  choklog = (evt, pth) !-> console.log "CHOKIDAR: #evt `#pth`"
  watcher = chokidar.watch Object.keys cfg.chok, chokopts
  watcher.on \add, (pth) !->
    pth = pth.replaceAll '\\', '/'
    file = path.basename pth
    if chkstatiq.test pth and "./#pth" not in cfg.statiq
      choklog \add, pth
      builder.copy-statiq builder.final-cb
    else if chkviews.test pth and "./#pth" not in cfg.views
      choklog \add, pth
      builder.copy-views builder.final-cb
  watcher.on \change, (pth) !->
    pth = pth.replaceAll '\\', '/'
    if pth[0] is \. then pth.slice 2
    if chkstatiq.test pth
      choklog \change, pth; builder.copy-statiq builder.final-cb
    else if chkviews.test pth
      choklog \change, pth; builder.copy-views builder.final-cb
    else if /font/.test pth
      nxt =
        if cfg.mono? then [builder.do-exec cfg.chok.mono]
        else [(builder.do-exec cfg.chok[fle]) for fle in cfg.chok[pth]]
      (bach.series ([builder.get-font] ++ nxt)) builder.final-cb
    else if cfg.chok[pth]? and cfg.chok[pth] is \data
      choklog \change, pth
      args = [builder.get-data, (builder.do-exec cfg.chok.mono)]
      (bach.series args) builder.final-cb
    else
      console.log "recompiling: '#pth'"
      if cfg.mono?
        args =
          (builder.do-exec cfg.chok[pth])
          (builder.do-exec cfg.chok.mono)
        (bach.series args) builder.final-cb
      else builder.do-exec cfg.chok[pth], void
  watcher.on \error, (e) !->
    console.log 'CHOKIDAR ERROR:\n'
    console.log e
  watcher.on \unlink, (pth) !->
    pth = pth.replaceAll '\\', '/'
    choklog \unlink, pth
    if chkstatiq.test pth then builder.copy-statiq builder.final-cb
    else if chkviews.test pth then builder.copy-views builder.final-cb
  cb void 31
