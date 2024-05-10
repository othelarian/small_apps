export copy = (opts) !->
  require! fs
  try
    for _, files of cfg.list[opts.id].src
      fl = files[0][0]
      console.log "copying => #fl"
      fs.copyFileSync "../trancode/criptic/#fl", "./criptic/#fl"
  catch
    console.log e
