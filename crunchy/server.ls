# REQUIRES ###################################

require! {
  'fs-extra': fse
  '@othelarian/livescript': ls
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
  app.get '/crunchy/stories', (_, res) !->>
    rdir = \./crunchy/statiq/stories
    lst = await fse.readdir rdir
    #
    # TODO: read the data.txt and send it to the app
    #
    r = {}
    for dir in lst
      #
      raw = await fse.readFile "#rdir/#dir/data.txt", \utf-8
      data = raw.split '\r\n'
      mode = \none
      type-persos = ''
      list-persos = []
      for line,idx in data when idx > 0
        #
        switch
          | line.startsWith \persos
            mode = \persos
            type-persos = line.split(':')[0].trim!
          | line.startsWith '- '
            #
            # TODO
            #
            console.log 'oups'
            #
        #
      #
      r[dir] =
        name: data[0]
        persos:
          type: type-persos
          list: list-persos
      #
      #
    #
    res.send JSON.stringify r
    #
  app.post '/crunchy/story/notes', (req, res) !->
    #
    # TODO
    #
    res.send 'not ready'
    #
  app.get '/crunchy/fiches/:ficheId', (req, res) !->>
    [dir, lst] = await read-dir!
    entry = "#{req.params.ficheId}.j.ls"
    if entry in lst
      j = read-lson "#dir/#entry"
      if j.ok then res.render 'crunchy/fiche', j.r
      else res.send 'Oups! Something wrong happened with the fiche'
    else res.send 'I think you are looking for a fiche that does not exists'
  app.get '/crunchy/persos', (_, res) !->>
    [dir, lst] = await read-dir!
    res.render 'crunchy/persos', {fiches: lst}