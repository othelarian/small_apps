# UTILS ######################################

function q-sel s, a = no
  if a then document.querySelectorAll s
  else document.querySelector s

# CORE #######################################

App =
  add: (value) !->
    btn = document.createElement \button
    btn.setAttribute \onclick 'App.remove(event)'
    btn.innerHTML = "<svg viewBox='0 0 24 24'><use href='\#d#value'/></svg>"
    q-sel \#tray .appendChild btn
  clear: !->
    tray = q-sel \#tray
    while tray.firstChild? then tray.removeChild tray.firstChild
  remove: (evt) !-> evt.currentTarget.remove!
  roll: !->
    use = (x, v) ->
      "<g transform='translate(#{24 * x},0)'><use href='\#d#v'/></g>"
    dice = q-sel '#tray use' yes
    d =
      "<svg style='width:#{dice.length * 20}px' "
      |> (++ "viewBox='0 0 #{dice.length * 24} 24'>")
    r = []
    for die, x in dice
      dv = die.getAttribute \href .substring 2
      d = d ++ (use x, dv)
      Math.ceil (Math.random! * dv) |> r.push
    r = r.map (e) -> if e is 1 then "<b>#e</b>" else e
    nres = document.createElement \div
    nres.innerHTML = d ++ '</svg><br/><span>=> ' ++ (r.join ', ') ++ '</span>'
    q-sel \#res .insertBefore nres, q-sel '#res div'
  select: !->
    seld = q-sel \#selector .value
    lk = "http://#{document.location.host}/crunchy/fiches/#seld"
    a = q-sel \#link
    a.innerText = lk
    a.setAttribute \href, lk
    q-sel \#frame .setAttribute \src, lk

# OUTPUTS ####################################

window.App = App
