require! {
  browserify, path, pug, sass, terser, through
  'fs-extra': fse
  livescript: ls
  '@rollup/plugin-terser': plug-terser
  rollup: {rollup, watch}
}

# INTERNALS ##################################

brew-ls = (file) ->
  if path.extname(file) is '.ls'
    data = ''
    end = !->
      @queue(ls.compile data, {bare: yes, header: no})
      @queue null
    through ((buf) !-> data += buf), end
  else through!

copy-dir = (cb, target, prep = no) !->>
  lstdir = (sdir, odir) ->>
    src-files = await fse.readdir sdir
    ret-files = []
    src-mod = [...src-files]
    rem-from-src = (tf) !-> src-mod.splice (src-mod.indexOf tf), 1
    for outf in await fse.readdir odir
      if outf is \.gitignore then rem-from-src outf
      else if outf not in src-files then fse.remove "#odir/#outf"
      else
        if fse.statSync "#sdir/#outf" .isDirectory!
          hdl = (e, _) !-> if e? then throw e
          await create-dir hdl, "./#odir/#outf"
          ret-files = await lstdir "#sdir/#outf", "#odir/#outf"
          src-files.splice (src-files.indexOf outf), 1
          rem-from-src outf
        else
          odt = (await fse.stat "#odir/#outf").mtimeMs
          sdt = (await fse.stat "#sdir/#outf").mtimeMs
          if sdt is odt then rem-from-src outf
    for inf in src-mod
      await fse.copy "#sdir/#inf", "#odir/#inf"
    src-files.map ("#sdir/" ++) |> (++ ret-files)
  if await fse.pathExists "#{cfg.dir}/#target"
    try
      odir = switch target
        | \statiq => "#{cfg.out}/#target"
        | \views  => "#{cfg.dest}/#target/#{cfg.dir.substring 2}"
      await fse.mkdirs odir
      lst-files = await lstdir "#{cfg.dir}/#target", odir
      if cfg.watching
        cfg[target] = lst-files
        if prep then cfg.chok["#{cfg.dir}/#target"] = { target }
      cb void 7
    catch e
      console.log "COPY-#{target.toUpperCase!} ERROR:"
      cb e, void
  else cb "ERROR: no #target dir to copy from", void

build-end = (cb) !->
  console.log "building [ #{cfg.list[cfg.id].name} ] DONE"
  if not cfg.watching then cfg.id += 1
  cb void 22

build-start = (cb) !->
  prj = cfg.list[cfg.id]
  console.log "starting building [ #{prj.name} ] ..."
  cfg.dir = "./#{prj.path}"
  cfg.out = "./#{cfg.dest}/#{prj.path}"
  cfg.src = prj.src
  if prj.version? then cfg.version = prj.version
  cfg.mono = if prj.mono? then {} else void
  cb void 21

roll-ls = ~>
  name: 'roll-ls'
  transform: (code, id) ->
    out =
      unless path.extname(id) is '.ls' then null
      else
        try
          ls.compile code, {bare: yes, header: no}
        catch
          thrown e
    code: out

# EXPORTED ###################################

export building = (pcfg) ->
  pack = [build-start, create-dir, compile-src, build-end]
  if pcfg.statiq? and pcfg.statiq
    pack.splice 2 0 ((cb) !-> copy-statiq cb, yes)
  if pcfg.font? then pack.splice (pack.length - 2), 0, get-font
  if pcfg.data? then pack.splice (pack.length - 2), 0, get-data
  if pcfg.views? and pcfg.views
    pack.splice 2 0 ((cb) !-> copy-views cb, pcfg.path, yes)
  if pcfg.mono? then pack.splice (pack.length - 2), 1, compile-mono
  pack

export compile-mono = (cb) !->
  require! bach
  args = []
  carlin = void
  for lg, lst of cfg.src then for entry in lst
    outf = if lg is \carlin then \carlin else entry[1]
    opts = {inf: "#{cfg.dir}/#{entry[0]}", outf, lg}
    if lg is \carlin then opts.opts = {name: entry[3]}
    args.push (do-exec opts)
    if cfg.watching
      if lg in <[brew roll]> then for k in entry[2]
        cfg.chok["#{cfg.dir}/#k".substring 2] = opts
      else cfg.chok[opts.inf.substring 2] = opts
  carlopts =
    inf: "#{cfg.dir}/#{cfg.src['carlin'][0][0]}"
    outf: "#{cfg.out}/#{cfg.src['carlin'][0][1]}"
    lg: \pug
  args.push (do-exec carlopts)
  if cfg.watching then for k in cfg.src['carlin'][0][2]
    cfg.chok.mono = carlopts
  (bach.series args) cb

export compile-src = (cb) !->
  in-lst = (lg, fc) !->
    opts = {inf: "#{cfg.dir}/#{fc[0]}", outf: "#{cfg.out}/#{fc[1]}", lg}
    do-exec opts, void
    if cfg.watching
      if lg in <[brew roll]> then for k in fc[2]
        cfg.chok["#{cfg.dir}/#k".substring 2] = opts
      else cfg.chok[opts.inf.substring 2] = opts
  in-lg = (lg, lst) -> for fc in lst then in-lst lg, fc
  for lg, lst of cfg.src then in-lg lg, lst
  cb void 13

export copy-statiq = (cb, prep = no) !-> copy-dir cb, \statiq, prep

export copy-views = (cb, prep = no) !-> copy-dir cb, \views, prep

export create-dir = (cb, pth = void) !->>
  pth = if pth is void then "./#{cfg.out}" else pth
  try
    await fse.mkdirs pth
    cb void 0
  catch e
    if e.code is 'EEXIST' then cb void 1 else cb e void

export do-exec = ({inf, outf, lg, opts}, cb) !-->>
  try
    r = switch lg
      | \brew
        b = browserify inf, {extensions: [ \.ls ], transform: brew-ls}
        hdl = (res, rej) !->
          bcb = (err, buff) !-> if err isnt null then rej(err) else res(buff)
          b.bundle bcb
        r = (await (new Promise hdl)).toString!
        if cfg.release or cfg.github or cfg.mono?
          (await terser.minify r).code
        else r
      | \carlin
        c = pug.compileFileClient inf, {compileDebug: no, name: opts.name}
        (await terser.minify c).code
      | \ls
        c = fse.readFileSync inf, \utf-8 |> ls.compile
        if cfg.release or cfg.github then (await terser.minify c).code
        else c
      | \pug => pug.renderFile inf, cfg
      | \roll
        in-opts = input: inf, context: \this, plugins: [roll-ls!]
        out-opts = format: \iife, plugins: [plug-terser!]
        bundle = await rollup in-opts
        out = (await bundle.generate out-opts).output.0.code
        bundle.close!
        out
      | \sass => (sass.compile inf, { style: \compressed }).css
    if cfg.mono?
      if lg isnt \pug then cfg.mono[outf] = r
      else fse.writeFileSync outf, r
      if cb? then cb void 24
    else
      drn = path.dirname outf
      if drn isnt \. then await fse.mkdirs drn
      fse.writeFileSync outf, r
    console.log "#{new Date!toLocaleString!} => '#lg / #inf'  compilation done"
  catch e
    console.log 'ERROR(doExec): Something went wrong!!\n\n'
    if cfg.mono? and cb? then cb e, void else console.log e

export final-cb = (e, r) !->
  if e?
    console.log "ERROR:\n(Results: #r)\n\n"
    console.log e

export get-data = (cb) !->
  pth = "#{cfg.dir}/#{cfg.list[cfg.id].data}"
  console.log "get data (#pth) ..."
  unless cfg.data?
    if cfg.watching then cfg.chok[pth.substring 2] = \data
  try
    ctt = fse.readFileSync pth, \utf-8
    cfg.mono.data = ls.compile ctt, { json: yes }# |> JSON.parse
    cb void 51
  catch e
    cb e, void

export get-font = (cb) !->
  require! { 'lucide-static': lucide }
  pth = "#{cfg.dir}/font.ls"
  unless cfg.fonts? # first time
    if cfg.watching then cfg.chok[pth.substring 2] = cfg.list[cfg.id].font
  try
    d = fse.readFileSync pth, \utf8
    f = (ls.compile d, { json: yes } |> JSON.parse).fonts
    clip = (h, s) ->
      s = s.substring s.search('>') + 2
      s = s.split '\n'
      while s[s.length - 1] is '</svg>' or s[s.length - 1] is '' then s.pop()
      s = s.map (e) -> e.trim()
      "<symbol id=\"#{h}\">" + (s * '') + '</symbol>'
    cfg.fonts = (f.map (elt) -> clip elt, lucide[elt]) * ''
    cb void 18
  catch e
    cb e, void

export wasm-pack = (cb) !->
  #
  # TODO: wasm
  #
  require! {
    buffer, path
    child_process: { spawnSync }
  }
  #
  console.log 'wasm pack'
  #
  #process.chdir \wasm_test # change cwd
  #
  args = [
    \--log-level, \error, \build, \--dev, \--no-pack
    \--no-typescript, \--target, \no-modules
  ]
  opts =
    cwd: path.join process.cwd!, \wasm_test
  r = spawnSync \wasm-pack, args, opts
  stderr = r.stderr.toString \utf-8
  if /error/.test stderr
    #
    console.log '###### ERROR! #######'
    #
    console.log stderr
  else
    #
    console.log 'everything is fine'
    #
  #
  #
  cb void 76
  #