# svg => to handle svg text tag
export c-elt = (tag, attrs, txt, html, svg = no) ->
  elt =
    if svg then document.createElementNS 'http://www.w3.org/2000/svg', tag
    else document.createElement tag
  for k, v of attrs
    if svg then elt.setAttributeNS void, k, v
    else elt.setAttribute k, v
  if svg and txt? then elt.textContent = txt
  if txt? then elt.innerText = txt
  else if html? then elt.innerHTML = html
  elt

export  q-sel = (s, a = no) ->
  if a then document.querySelectorAll s
  else document.querySelector s
