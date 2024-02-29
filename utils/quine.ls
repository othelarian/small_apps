export class Quine
  detect: ->>
    if location.protocol.startsWith 'http'
      try
        res = await fetch location.pathname, { method: \OPTIONS }
        if res.ok and res.headers.get 'dav' then yes
        else console.log 'Server not compatible'; no
      catch e
        console.error e; no
  download: (data, name) !->
    elt = document.createElement \a
    href = "data:text/html;charset:utf-8,#{encodeURIComponent data}"
    elt.setAttribute \href, href; elt.setAttribute \download, name
    document.body.appendChild elt; elt.click!; document.body.removeChild elt
  init: (data-id) ->
    document.querySelector "\##data-id" .textContent |> JSON.parse
  sync: (data) ->>
    try
      res = await fetch location.pathname, { method: \PUT, body: data }
      unless res.ok then console.log(if res.text? then res.text else res.status)
      res.ok
    catch e
      console.log e; no