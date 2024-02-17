export c-elt = (tag, attrs, txt, html) ->
  elt = document.createElement tag
  for k, v of attrs then elt.setAttribute k, v
  if txt? then elt.innerText = txt
  else if html? then elt.innerHTML = html
  elt

export  q-sel = (s, a = no) ->
  if a then document.querySelectorAll s
  else document.querySelector s
