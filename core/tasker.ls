# INTERNALS ##################################

# EXPORTED ###################################

export all = !->
  require! { bach, './builder' }
  end-all = (cb) !->
    cfg.id = 0
    cb void 5
  start-all = (cb) !->
    cfg.dir = '.'
    cfg.out = "./#{cfg.dest}"
    cfg.src = cfg.root
    cb void 4
  cfg.list = cfg.list.filter (.active), cfg.list
  args =
    [builder.building pcfg for pcfg in cfg.list].flat!
    |> ([start-all, builder.create-dir, builder.compile-src, end-all] ++)
  (bach.series args) builder.final-cb

export clean = !->
  require! { 'fs-extra': { remove } }
  console.log "cleaning `#{cfg.dest}`..."
  remove "./#{cfg.dest}", (e) ->
    if e? then console.log e
    else console.log "`#{cfg.dest}` removed successfully"

export command = !->
  if opts.id is void
    console.log 'please set the project\'s id you want to call a command from'
  else if opts.id > cfg.list.length
    console.log 'please select a project IN THE LIST!'
  else if cfg.list[opts.id].cmds is void
    console.log 'please select a project WITH COMMANDS!'
  else if opts.list?
    console.log "List of commands in the projet '#{cfg.list[opts.id].name}':\n"
    for cmd in Object.keys cfg.list[opts.id].cmds
      console.log "  - #cmd => #{cfg.list[opts.id].cmds[cmd]}"
  else if opts.cmd is void
    console.log 'please use the --cmd or -c command option'
  else if opts.cmd not of cfg.list[opts.id].cmds
    console.log 'please select a command that exists in the list!'
    console.log '(use `cmd -p PROJECT_ID --l` to get the list of the commands)'
  else cfg.list[opts.id].cmd opts.cmd

export compile = (opts) !->
  if opts.watch? then cfg.watching = opts.watch
  if opts.id?
    if opts.id > cfg.list.length
      console.log 'please select a project IN THE LIST!'
    else
      require! {
        bach
        './builder': { building, final-cb }
        './server': { serve }
        './watcher': { watching }
      }
      cfg.id = opts.id
      bldpack = building cfg.list[cfg.id]
      bld =
        if cfg.watching then [watching, serve] else []
        |> (bldpack ++)
        |> bach.series
      bld final-cb
  else console.log 'please set the id of the project you want to compile'

export create = !->
  console.log 'creating a new project...'
  require! {
    bach
    'fs-extra': { writeFile }
    'readline-sync': readline,
    './builder': { create-dir }
    './project-src': { names, printout, srcs }
  }
  name = readline.question '# What is its name? > '
  pth = readline.question '# What is its path? > '
  console.log "name: #name, path: #pth"
  if readline.keyInYN '# Is it what you want?'
    console.log 'building the source...'
    cfg.out = pth
    gen = (sel, cb) !-->
      try
        out = srcs sel, name
        writeFile "./#pth/#{names[sel]}", out
        cb void 32
      catch e
        console.log '=======> SOMETHING WENT WRONG <======='
        cb e, void
    fcb = (e, _) !->
      if e? then console.log e
      else
        console.log 'creation DONE'
        console.log 'copy this in the config.ls to enable your project:'
        console.log printout name, pth
    (bach.series create-dir, (gen 'ls'), (gen 'pug'), (gen 'sass')) fcb
  else console.log 'canceling creation...'

export list = !->
  console.log 'Projects list:'
  for prj, i in cfg.list then console.log "#i => #{prj.name}"

export serve = !->
  require! './server': { serve }
  cfg.id = -1
  serve!
