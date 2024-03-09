require! express

# SERVER #####################################

export serve = (cb) !->
  app = express!
  serv-lst =
    if cfg.id is -1 then cfg.list else [cfg.list[cfg.id]]
    |> (.filter (.server))
  if serv-lst.length isnt 0
    app.set \views, "#{cfg.dest}/views"
    app.set 'view engine' \pug
    console.log 'loading server configs...'
    for config in serv-lst then require "../#{config.path}/server" .setup app
    console.log 'configs DONE'
  console.log 'launching dev server...'
  app.use express.static cfg.dest
  app.listen 5001
  console.log 'dev server running on port 5001'