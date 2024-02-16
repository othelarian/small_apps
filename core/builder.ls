require! {
  pug, sass, terser
  'fs-extra': fse
  livescript: ls
  'lucide-static': lucide
}

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

export building = (pcfg) ->
  pack = [build-start, create-dir, compile-src, build-end]
  if pcfg.statiq? and pcfg.statiq
    pack.splice 2 0 ((cb) !-> copy-statiq cb, yes)
  if pcfg.font? then pack.splice (pack.length - 2), 0, get-font
  pack

export compile-src = (cb) !->
  in-lst = (lg, fc) !->
    inf = "#{cfg.dir}/#{fc[0]}"
    outf = "#{cfg.out}/#{fc[1]}"
    do-exec inf, outf, lg
    if cfg.watching then cfg.chok[inf.substring 2] = { lg, outf }
  in-lg = (lg, lst) -> for fc in lst then in-lst lg, fc
  for lg, lst of cfg.src then in-lg lg, lst
  cb void 13

export copy-statiq = (cb, prep = no) !->>
  if await fse.pathExists "#{cfg.dir}/statiq"
    console.log 'copy statiq file'
    try
      await fse.mkdirs "#{cfg.out}/statiq"
      src_files = await fse.readdir "#{cfg.dir}/statiq"
      src_mod = [...src_files]
      for outf in await fse.readdir "#{cfg.out}/statiq"
        if outf not in src_files then fse.remove "#{cfg.out}/statiq/#outf"
        else
          odt = (await fse.stat "#{cfg.out}/statiq/#outf").mtimeMs
          sdt = (await fse.stat "#{cfg.dir}/statiq/#outf").mtimeMs
          if sdt is odt then src_mod.splice (src_mod.indexOf outf), 1
      for inf in  src_mod
        await fse.copy "#{cfg.dir}/statiq/#inf", "#{cfg.out}/statiq/#inf"
      if cfg.watching
        cfg.statiq = src_files
        if prep then cfg.chok["#{cfg.dir}/statiq"] = { \statiq, '' }
      cb void 7
    catch e
      cb e, void
  else cb 'ERROR: no statiq file to copy' void

export create-dir = (cb) !->>
  try
    await fse.mkdirs "./#{cfg.out}"
    cb void 0
  catch e
    if e.code is 'EEXIST' then cb void 1 else cb e void

export do-exec = (inf, outf, sel) !-->>
  try
    r = switch sel
      | \ls
        c = fse.readFileSync inf, \utf-8 |> ls.compile
        if cfg.release or cfg.github then (await terser.minify c).code
        else c
      | \pug  => pug.renderFile inf, cfg
      | \sass => (sass.compile inf, { style: \compressed }).css
    fse.writeFileSync outf, r
    console.log "#{new Date!toLocaleString!} => '#{sel}' compilation done"
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
      "<symbol id=\"#{h}\">" + (s.join '') + '</symbol>'
    cfg.fonts = (f.map (elt) -> clip elt, lucide[elt]) .join ''
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