# REQUIRES ###################################

require! { 'fs-extra': fse }

# INTERNALS ##################################

put-handler = (req, res) !->
  data = ''
  req.on \data, (chunk) !-> data += chunk
  req.on \end, ->
    console.log "#{new Date!toLocaleString!} => Writing put-save.html..."
    fse.writeFileSync "#{cfg.out}/put-save.html", data
  res.send 'ok'

# EXPORTED ###################################

export setup = (app) !->
  app.options '/cs/', (_, res) !->
    res.append \dav 1
    res.send \ok
  app.put '/cs/', put-handler
  app.put '/cs/put-save.html', put-handler
