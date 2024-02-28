require! '../../utils/basics': { c-elt, q-sel }

export class DR
  tog: off
  add: (v) !->
    svg = c-elt \svg, {\viewBox : '0 0 24 24'}, void, void, yes
    svg.appendChild(c-elt \use, {href: "\#d#v"}, void, void, yes)
    btn = c-elt \button, onclick: 'App.dr.rem(event)'
    btn.appendChild svg
    q-sel \#dr-tray .appendChild btn
  clear: !->
    tray = q-sel \#dr-tray
    while tray.firstChild? then tray.removeChild tray.firstChild
  rem: (evt) !-> evt.currentTarget.remove!
  roll: !->
    rand2 = (v) -> Math.ceil(Math.random! * v)
    gen-die = (v, r) ->
      hitch = if r is 1 then ' style="stroke:red"' else ''
      "<svg class='dice' viewBox='0 0 24 24' #hitch><use href='\#d#v'/>"
      |> (++ "<circle cx='12' cy='12' r='8' fill='url(\#dr-grad)'/>")
      |> (++ "<text x='12' y='16'>#r</text></svg>")
    dice = q-sel '#dr-tray use' yes
    dr = []
    if dice.length > 0 then for die in dice
      v = die.getAttribute \href .substring 2
      r = rand2 v
      dr.push(gen-die v, r)
    hist = q-sel \#dr-history
    hist.insertBefore (c-elt \div, {}, void, (dr.join '')), hist.firstChild
    if hist.childNodes.length > 6 then hist.removeChild hist.lastChild
  toggle: !->
    [btn, blk] = if @tog then [\0, \none ] else [\202px, \block ]
    q-sel \#dr-btn .style.left = btn
    q-sel \#dr-block .style.display = blk
    @tog = not @tog