require! {
  browserify, path, pug, sass, terser, through
  'fs-extra': fse
  livescript: ls
  'lucide-static': lucide
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
  cb void 21

# EXPORTED ###################################

export building = (pcfg) ->
  pack = [build-start, create-dir, compile-src, build-end]
  if pcfg.statiq? and pcfg.statiq
    pack.splice 2 0 ((cb) !-> copy-statiq cb, yes)
  if pcfg.font? then pack.splice (pack.length - 2), 0, get-font
  pack

export compile-src = (cb) !->
  in-lst = (lg, fc) !->
    opts = {inf: "#{cfg.dir}/#{fc[0]}", outf: "#{cfg.out}/#{fc[1]}", lg}
    do-exec opts
    if cfg.watching
      if lg is \brew then for k in fc[2]
        cfg.chok["#{cfg.dir}/#k".substring 2] = opts
      else cfg.chok[opts.inf.substring 2] = opts
  in-lg = (lg, lst) -> for fc in lst then in-lst lg, fc
  for lg, lst of cfg.src then in-lg lg, lst
  cb void 13

export copy-statiq = (cb, prep = no) !->>
  lstdir = (pdir) ->>
    src-files = await fse.readdir "#{cfg.dir}/#pdir"
    ret-files = []
    src-mod = [...src-files]
    rem-from-src = (tf) !-> src-mod.splice (src-mod.indexOf tf), 1
    for outf in await fse.readdir "#{cfg.out}/#pdir"
      pdoutf = "#pdir/#outf"
      if outf is \.gitignore then rem-from-src outf
      if outf not in src-files then fse.remove "#{cfg.out}/#pdoutf"
      else
        if fse.statSync "#{cfg.dir}/#pdoutf" .isDirectory!
          hdl = (e, _) !-> if e? then throw e
          await create-dir hdl, "./#{cfg.out}/#pdoutf"
          ret-files = lstdir pdoutf
          src-files.splice (src-files.indexOf outf), 1
          rem-from-src outf
        else
          odt = (await fse.stat "#{cfg.out}/#pdoutf").mtimeMs
          sdt = (await fse.stat "#{cfg.dir}/#pdoutf").mtimeMs
          if sdt is odt then rem-from-src outf
    for inf in src-mod
      await fse.copy "#{cfg.dir}/#pdir/#inf", "#{cfg.out}/#pdir/#inf"
    src-files ++ ret-files
  if await fse.pathExists "#{cfg.dir}/statiq"
    console.log 'copy statiq file'
    try
      await fse.mkdirs "#{cfg.out}/statiq"
      lst-files = await lstdir \statiq
      if cfg.watching
        cfg.statiq = lst-files
        if prep then cfg.chok["#{cfg.dir}/statiq"] = { \statiq, '' }
      cb void 7
    catch e
      console.log 'COPY-STATIQ ERROR:'
      cb e, void
  else cb 'ERROR: no statiq file to copy' void

export create-dir = (cb, pth = void) !->>
  pth = if pth is void then "./#{cfg.out}" else pth
  try
    await fse.mkdirs pth
    cb void 0
  catch e
    if e.code is 'EEXIST' then cb void 1 else cb e void

export do-exec = ({inf, outf, lg}) !-->>
  try
    r = switch lg
      | \brew
        b = browserify inf, {extensions: [ \.ls ], transform: brew-ls}
        hdl = (res, rej) !->
          bcb = (err, buff) !-> if err isnt null then rej(err) else res(buff)
          b.bundle bcb
        r = (await (new Promise hdl)).toString!
        if cfg.release or cfg.github then (await terser.minify r).code
        else r
      | \ls
        c = fse.readFileSync inf, \utf-8 |> ls.compile
        if cfg.release or cfg.github then (await terser.minify c).code
        else c
      | \pug  => pug.renderFile inf, cfg
      | \sass => (sass.compile inf, { style: \compressed }).css
    fse.writeFileSync outf, r
    console.log "#{new Date!toLocaleString!} => '#{lg}' compilation done"
  catch e
    console.log 'ERROR(doExec): Something went wrong!!\n\n'
    console.log e

export final-cb = (e, r) !->
  if e?
    console.log "ERROR:\n(Results: #r)\n\n"
    console.log e

export get-font = (cb) ->
  pth = "#{cfg.dir}/font.ls"
  if not cfg.fonts? # first time
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
  # TODO
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