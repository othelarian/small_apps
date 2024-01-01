require! {
  terser
  'fs-extra': fse
  livescript: ls
}

export bookmark = !->>
  r =
    fse.readFileSync './final-dr/bookmark.ls', \utf-8
    |> ((x) -> ls.compile x, { header: no, bare: no })
  r = 'javascript:' ++ (await terser.minify r).code
  fse.writeFileSync './final-dr/bookmark.js', r