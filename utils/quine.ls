export class Quine
  fn: void
  detect: ->>
    if location.protocol.startsWith 'http'
      try
        res = await fetch location.pathname, { method: \OPTIONS }
        if res.ok and res.headers.get 'dav' then yes
        else console.log 'Server not compatible'; no
      catch
        console.error e; no
  download: (data, name, json = no) !->
    rep = if json then JSON.stringify data else @prepare data
    href = "data:text/html;charset:utf-8,#{encodeURIComponent rep}"
    elt = document.createElement \a
      ..setAttribute \href, href
      ..setAttribute \download, name
    document.body.appendChild elt; elt.click!; document.body.removeChild elt
  init: (@fn) -> document.querySelector \#mono-data .textContent |> JSON.parse
  load: (fn) !->
    read-file = (evt) !->
      file = evt.target.files[0]
      reader = new FileReader!
      reader.onload = (evt) !-> fn evt.target.result
      reader.readAsText file
    elt = document.createElement \input
      ..type = \file
      ..style.display = \none
      ..onchange = read-file
    document.body.appendChild elt; elt.click!; document.body.removeChild elt
  prepare: (data) ->
    cfg =
      mono:
        app: document.querySelector \#mono-app .textContent
        carlin: document.querySelector \#mono-carlin .textContent
        data: data |> JSON.stringify
        style: document.querySelector \#mono-style .textContent
      fonts: document.querySelector \#mono-fonts
          .outerHTML.substring 22 .replace \</defs> ''
    @fn cfg
  sync: (data) ->>
    try
      res = await fetch location.pathname, { method: \PUT, body: @prepare data }
      unless res.ok then console.log(if res.text? then res.text else res.status)
      res.ok
    catch
      console.log e; no