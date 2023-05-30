bach = require 'bach'
chokidar = require 'chokidar'
fse = require 'fs-extra'
livescript = require 'livescript'
pug = require 'pug'
sass = require 'sass'
{ minify } = require 'terser'

cfg = require('./config').cfg

# OPTIONS #############################

option '-f', '--force', 'override time test'
option '-g', '--github', ''
option '-p', '--id [ID]', 'project id'
option '-r', '--release', ''
option '-w', '--watch', '(only for compile)'

# COMMON FUNS #########################

checkEnv = (opts) ->
  [cfg.dest, cfg.release, cfg.github] =
    if opts.github then [cfg.dest_path.github, true, true]
    else if opts.release then [cfg.dest_path.release, true, false]
    else [cfg.dest_path.debug, false, false]
  cfg.force = opts.force?
  #cfg.watching = false

doExec = (in_file, out_file, selected) ->
  try
    rendered = switch selected
      when 'ls'
        code = await fse.readFile in_file, { encoding: 'utf-8' }
        livescript.compile code, {}
      when 'pug' then pug.renderFile in_file, cfg
      when 'sass' then (sass.compile in_file, { style: 'compressed' }).css
    fse.writeFileSync out_file, rendered
    traceExec selected
  catch e
    console.error "doExec '#{selected}' => Something went wrong!!!!\n\n\n#{e}"

traceExec = (name) ->
  stmp = new Date().toLocaleString()
  console.log "#{stmp} => #{name} compilation done"

runExec = (selected, cb) ->
  [in_file, out_file] = switch selected
    when 'ls' then cfg.src.ls
    when 'pug' then cfg.src.pug
    when 'sass' then cfg.src.sass
  in_file = "#{cfg.dir}/#{in_file}"
  out_file = "#{cfg.out}/#{out_file}"
  doExec in_file, out_file, selected
  if cfg.watching then watchExec in_file, out_file, selected
  cb null, 11

watchExec = (to_watch, out_file, selected) ->
  watcher = chokidar.watch to_watch
  watcher.on 'change', -> doExec(to_watch, out_file, selected)
  watcher.on 'error', (err) -> console.log "CHOKIDAR ERROR:\n#{err}"

# ACTION FUNS #########################

buildAll = ->
  startIdx = (cb) ->
    console.log 'Compile index...'
    cfg.dir = '.'
    cfg.out = "./#{cfg.dest}"
    cfg.id = 0
    cfg.src = { pug: ['index.pug', 'index.html'] }
    cb null, 4
  endIdx = (cb) ->
    console.log 'index done'
    cb null, 5
  starter = bach.series startIdx, createDir, compilePug, endIdx
  args = [starter]
  args.push building for _ in cfg.list
  (bach.series.apply null, args) (e, _) -> if e? then console.log e

buildEnd = (cb) ->
  console.log "building [ #{cfg.list[cfg.id].name} ] DONE"
  cfg.id += 1
  cb null, 22

buildStart = (cb) ->
  prj = cfg.list[cfg.id]
  console.log "starting building [ #{prj.name} ] ..."
  cfg.dir = "./#{prj.path}"
  cfg.out = "./#{cfg.dest}/#{prj.path}"
  cfg.src = prj.src
  cb null, 21

compileLS = (cb) -> runExec 'ls', cb

compilePug = (cb) -> runExec 'pug', cb

compileSass = (cb) -> runExec 'sass', cb

copyStatic = (cb) ->
  if await fse.pathExists "#{cfg.dir}/static"
    console.log 'copy static files'
    try
      fse.mkdirs "#{cfg.out}/static"
      fse.copy "#{cfg.dir}/static", "#{cfg.out}/static"
      cb null, 7
    catch e
      if e.code is 'EEXIST' then cb null, 9 else cb e, null
  else
    console.log 'no static file to copy'
    cb null, 8

createDir = (cb) ->
  try
    await fse.mkdirs "./#{cfg.out}"
    cb null, 0
  catch e
    if e.code = 'EEXIST' then cb null, 1
    else cb e, null

launchServer = (cb) ->
  console.log 'launching dev server...'
  app = (require 'connect')()
  app.use((require 'serve-static') './dist')
  (require 'http').createServer(app).listen 5000
  console.log 'dev server running on port 5000'

# SUB TASKS ###########################

building = bach.series(
  buildStart,
  createDir, copyStatic,
  compilePug, compileSass, compileLS,
  buildEnd
)

# TASKS ###############################

task 'all', 'compile all active projects', (opts) ->
  checkEnv opts
  buildAll()

task 'clean', 'remove `dist`', (opts) ->
  checkEnv opts
  console.log "cleaning `#{cfg.dest}`..."
  fse.remove "./#{cfg.dest}", (e) ->
    if e? then console.log e
    else console.log "`#{cfg.dest}` removed successfully"

task 'create', 'create a new project', (opts) ->
  console.log 'creating a new project...'
  readline = require 'readline-sync'
  { names, printout, srcs } = require './project-src'
  name = readline.question '# What is the name of the new project?'
  path = readline.question '# What is the path of the new project?'
  console.log "name: #{name}, path: #{path}"
  if readline.keyInYN '# Is it what you want?'
    console.log 'building the source...'
    gen = (selected, cb) ->
      try
        out = srcs selected, name
        fse.writeFile "./#{path}/#{names[selected]}", out #srcs(selected, name)
        cb null, 32
      catch e
        console.log "====> Something went wrong <===="
        cb e, null
    cfg.out = path
    genLS = (cb) -> gen 'ls', cb
    genPug = (cb) -> gen 'pug', cb
    genSass = (cb) -> gen 'sass', cb
    creating = bach.series createDir, genLS, genPug, genSass
    creating (e, _) ->
      if e? then console.log e
      else
        console.log 'creation DONE'
        console.log 'copy this in the config.coffee to enable your project:'
        console.log printout name, path
  else
    console.log 'canceling creation...'

task 'compile', 'compile one project, and watch it (USE PROJECT ID!)', (opts) ->
  opts.github = false
  opts.release = false
  checkEnv opts
  cfg.watching = opts.watch
  if opts.id?
    nid = parseInt opts.id
    if isNaN(nid) or nid > cfg.list.length
      console.log 'please select a project IN THE LIST'
    else
      cfg.id = nid
      if cfg.watching
        (bach.series building, launchServer) (e, _) -> if e? then console.log e
      else
        building (e, _) -> if e? then console.log e
  else console.log 'please set the id of the project you want to compile'

task 'list', 'list all projects actually available', (_) ->
  t = (acc, elt, id) ->
    acc.push "#{id}. #{elt.name}"
    acc
  console.log 'Projects list:'
  console.log prj for prj in cfg.list.reduce t, []

task 'serve', 'launch the server to get access to the projects', (opts) ->
  opts.github = false
  opts.release = false
  checkEnv opts
  if not await fse.pathExists './dist' then buildAll()
  launchServer()
