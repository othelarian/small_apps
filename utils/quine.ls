qs = (id) -> document.querySelector id

export class Quine
  fn: void
  detect: ->>
    if location.protocol.startsWith 'http'
      try
        res = await fetch location.pathname, { method: \OPTIONS }
        if res.ok and res.headers.get 'dav' then yes
        else console.log 'Server not compatible'; no
      catch e
        console.error e; no
  download: (data, name, json = no) !->
    rep = if json then JSON.stringify data else @prepare data
    elt = document.createElement \a
    href = "data:text/html;charset:utf-8,#{encodeURIComponent rep}"
    elt.setAttribute \href, href; elt.setAttribute \download, name
    document.body.appendChild elt; elt.click!; document.body.removeChild elt
  init: (@fn) -> qs \#mono-data .textContent |> JSON.parse
  load: (fn) !->
    read-file = (evt) !->
      file = evt.target.files[0]
      reader = new FileReader!
      reader.onload = (evt) !-> fn evt.target.result
      reader.readAsText file
    elt = document.createElement \input
    elt.type = \file; elt.style.display = \none; elt.onchange = read-file
    document.body.appendChild elt; elt.click!; document.body.removeChild elt
  prepare: (data) ->
    cfg =
      mono:
        app: qs \#mono-app .textContent
        carlin: qs \#mono-carlin .textContent
        data: data |> JSON.stringify
        style: qs \#mono-style .textContent
      fonts: qs \#mono-fonts .outerHTML .substring 22 .replace \</defs> ''
    @fn cfg
  sync: (data) ->>
    try
      res = await fetch location.pathname, { method: \PUT, body: @prepare data }
      unless res.ok then console.log(if res.text? then res.text else res.status)
      res.ok
    catch e
      console.log e; no