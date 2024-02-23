# REQUIRES ###################################

require! {
  'fs-extra': fse
  livescript: ls
}

# INTERNALS ##################################

read-dir = ->>
  dir = "#{cfg.dest}/crunchy/statiq/fiches"
  lst = await fse.readdir dir
  [dir, lst]

read-lson = (pth) ->
  try
    c = ls.compile ( fse.readFileSync pth, \utf-8 ), {json: yes} |> JSON.parse
    {ok: yes, r: c}
  catch e
    console.log e
    {ok: no}

# EXPORTED ###################################

export setup = (app) !->
  app.get '/crunchy/persos', (_, res) !->>
    [dir, lst] = await read-dir!
    res.render 'crunchy/persos', {fiches: lst}
  app.get '/crunchy/fiches/:ficheId', (req, res) !->>
    [dir, lst] = await read-dir!
    entry = "#{req.params.ficheId}.j.ls"
    if entry in lst
      j = read-lson "#dir/#entry"
      if j.ok then res.render 'crunchy/fiche', j.r
      else res.send 'Oups! Something wrong happened with the fiche'
    else res.send 'I think you are looking for a fiche that does not exists'