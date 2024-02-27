require!  '../../utils/basics'

export class CortexSet
  clear: !->
    tray = basics.q-sel \#cortex-tray
    while tray.firstChild? then tray.removeChild tray.firstChild
  dice: (d) !->
    svg = basics.c-elt \svg, {'viewBox': '0 0 24 24'}, void, void, yes
    svg.appendChild(basics.c-elt \use, {href: "\#d#d"}, void, void, yes)
    btn = basics.c-elt \button, onclick: 'App.sets.cortex.rem(event)'
    btn.appendChild svg
    basics.q-sel \#cortex-tray .appendChild btn
  rem: (evt) !-> evt.currentTarget.remove!
  roll: !->
    use = (x, v) ->
      "<g transform='translate(#{24 * x},0)'><use href='\#d#v'/></g>"
    dice = basics.q-sel '#cortex-tray use' yes
    d =
      "<svg style='width:#{dice.length * 20}px' "
      |> (++ "viewBox='0 0 #{dice.length * 24} 24'>")
    r = []
    for die, x in dice
      dv = die.getAttribute \href .substring 2
      d = d ++ (use x, dv)
      App.rand2 dv |> r.push
    r = r.map (e) -> if e is 1 then "<b>#e</b>" else e
    r = 'Cortex: ' ++ d ++ '</svg><br/> => ' ++ (r.join ', ')
    App.roll r