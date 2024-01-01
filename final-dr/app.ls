# UTILS ######################################

function c-elt tag, attrs, txt, html
  elt = document.createElement tag
  for k, v of attrs then elt.setAttribute k, v
  if txt? then elt.innerText = txt
  else if html? then elt.innerHTML = html
  elt

function q-sel s, a = no
  if a then document.querySelectorAll s
  else document.querySelector s

function rand2 m
  Math.ceil (Math.random! * m)

# CLASSIC SET ################################

ClassicSet =
  advdis: (set) !->
    defv = (v) -> | v is -1 => 9 | v is 0 => 30 | v is 1 => 51
    App.toggle \#classic-advdis, (defv App.sets.classic.curr-advdis), defv set
    App.sets.classic.curr-advdis = set
  curr-advdis: 0
  roll: (v) !->
    if v is \s
      v = q-sel \#classic-special .value |> parseInt
      if isNaN v then alert 'Please enter a number'; return
      else if v < 1
        alert 'please select a positive value AND ABOVE 2'; return
    r =
      if App.sets.classic.curr-advdis is 0 then "d#v: <b>#{rand2 v}</b>"
      else
        r1 = rand2 v
        r2 = rand2 v
        [chk, aord] =
          if App.sets.classic.curr-advdis is -1 then [r1 <= r2, \dis]
          else [r1 >= r2, \adv]
        br =
          if chk then r1 = "<b>#{r1}</b>"; r1
          else r2 = "<b>#{r2}</b>"; r2
        "d#v with #{aord}: [#{r1}, #{r2}] => #br"
    App.roll r

# COMMON SET #################################

CommonSet =
  bold: (ids, rolls) ->
    for r, id in rolls then if id in ids then "<b>#r</b>" else r
  keep: (n, fn, rolls) ->
    red = (acc, cv, idx) ->
      if acc.ids.length is 0 then acc.ids.push idx; acc.values.push cv
      else
        fnd = no
        for b, id in acc.values
          if fn cv, b
            acc.ids.splice id, 0, idx
            acc.values.splice id, 0, cv
            fnd = yes
            break
        if not fnd and acc.values.length < n
          acc.ids.push idx; acc.values.push cv
        else if acc.values.length > n
          acc.ids.pop!; acc.values.pop!
      acc
    rolls.reduce red, { ids: [], values: [] }
  kh: (n, rolls) -> App.sets.common.keep n, ((a, b) -> a > b), rolls
  kl: (n, rolls) -> App.sets.common.keep n, ((a, b) -> a < b), rolls

# OTHER SET ##################################

OtherSet =
  curr-tinyad: 0
  advdis: (sys, mode) !->
    switch sys
      | \tinyd6
        defv = (v) -> | v is 0 => 9 | v is 1 => 30
        App.toggle \#other1-tinyad , (defv App.sets.other1.curr-tinyad), defv mode
        col = if mode is 0 then \black else \green
        q-sel \#other1-tinyad .setAttribute \fill, col
        App.sets.other1.curr-tinyad = mode
  roll: (sys, mode) !->
    r = switch sys
      | \fate
        [md, tm, bn] =
          if mode is 0 then [\n, '', 0]
          else if mode < 0 then [\l, " (dis #mode)", Math.abs mode]
          else [\h, " (adv #mode)", mode]
        rolls = [rand2 3 for _ til (4 + (parseInt bn))].map (n) -> n - 2
        tt =
          if mode is \0 then rolls.reduce ((a, n) -> n + a), 0
          else
            kr = App.sets.common[ if mode < 0 then \kl else \kh ] 4, rolls
            rolls = App.sets.common.bold kr.ids, rolls
            kr.values.reduce ((a, n) -> n + a)
        "Fate#tm: [#{rolls.join ', '}] => #tt"
      | \pbta
        rs = [(rand2 6), rand2 6]
        advdis = (kn, rs) ->
          rs.push (rand2 6)
          kr = App.sets.common[kn] 2, rs
          #
          rs = App.sets.common.bold kr.ids, rs
          [kr.values[0] + kr.values[1], rs]
        [tt, rs, tm] = switch mode
          | \a => (advdis \kh, rs) ++ [' (adv)']
          | \d => (advdis \kl, rs) ++ [' (dis)']
          | \n => [rs[0] + rs[1], rs, '']
        "PbtA#tm: [#{rs.join ', '}] => #tt"
      | \recluse
        to-bold = (arr) ->
          arr.push (rand2 6)
          id = if arr[0] >= arr[1] then 0 else 1
          itr = arr[id]
          arr[id] = "<b>#{arr[id]}</b>"
          [arr, itr]
        gr = [rand2 6]; br = [rand2 6]
        g = gr[0]; b = br[0]
        tm = switch mode
          | \a => [gr, g] = to-bold gr; ' (adv)'
          | \d => [br, b] = to-bold br; ' (dis)'
          | \n => ''
        tt = switch
          | g is b => 'EQUAL! (and ' ++ (if g < 4 then 'BAD)' else 'GOOD)')
          | g < b => 'NO'
          | g > b => 'YES'
        if g isnt b
          if g > 3 and b > 3 then tt = tt ++ ' and'
          else if g < 3 and b < 3 then tt = tt ++ ' but'
        "Recluse#tm: [#{gr.join ', '}] vs. [#{br.join ', '}] => #tt"
      | \tinyd6
        rs = [rand2 6]
        bst = rs[0]
        if mode in <[ n a ]>
          rs.push (rand2 6)
          if mode is \a then rs.push (rand2 6)
          a = App.sets.common.kh 1, rs
          bst = a.values[0]
          rs = App.sets.common.bold a.ids, rs
        tm = switch mode | mode is \d => ' (dis)' | mode is \a => ' (adv)' | _ => ''
        dif = 4 - App.sets.other1.curr-tinyad
        tt = if bst > dif then 'SUCCESS!' else 'FAILED'
        "Tinyd6#tm: [#{rs.join ', '}] => #tt"
      | \zc
        rs = [rand2 6 for _ til mode]
        if mode > 6
          for idx from 6 til mode
            if rs[idx] is 1 then rs[idx] = [rs[idx]+ \d, rand2 6]
        zombify = (acc, v, idx) ->
          tmp = if typeof v is \object then v[1] else v
          tmp = switch tmp
            | 1 => acc.zh = acc.zh + 1; "<u>#tmp</u>"
            | 6 => acc.mol = acc.mol + 1; "<b>#tmp</b>"
            | _ => tmp
          if idx < 6 then acc.br.push tmp
          else
            acc.mr.push (if typeof v is \object then "[#{v[0]}, #tmp]" else tmp)
          acc
        acc = rs.reduce zombify, { mol: 0, zh: 0, br: [], mr: [] }
        out = "ZC (#mode):<br />Basic: [#{acc.br.join ', '}]<br />"
        if mode > 6 then out = out ++ "Master: [#{acc.mr.join ', '}]<br />"
        out ++ "==> Molotov: #{acc.mol}, ZH: #{acc.zh}"
      | _ => alert 'Oops, something gone wrong here'; ''
    if r isnt '' then App.roll r

# CORE #######################################

App =
  curr-flip: no
  curr-set: ''
  init: !->
    window.addEventListener 'resize', App.resize
    App.show \classic
  flip: !->
    if App.curr-flip
      for col in document.querySelectorAll \.cols then col.removeAttribute \style
      App.curr-flip = no
    else
      q-sel \#diceroller .setAttribute \style \display:none
      q-sel \#history .setAttribute \style \display:block
      App.curr-flip = yes
  resize: -> if App.curr-flip and window.innerWidth > 670 then App.flip!
  roll: (r) !->
    rs = q-sel \#res-show
    if rs.children.length is 1
      e = rs.removeChild rs.children[0]
      q-sel \#results .insertBefore e, q-sel '#results span'
    rs.appendChild (c-elt \span, {}, void, r)
  select: !->
    q-sel "\##{App.curr-set}-set" .style.display = \none
    App.show (q-sel \#the-selector .value)
  show: (v) !->
    App.curr-set = v
    q-sel "\##{v}-set" .style.display = \block
  toggle: (id, start, end) !->
    tranf = [{transform: "translate(#{end - start}px)"}]
    opts = {duration: 250, iteration: 1}
    e = q-sel id
    window.setTimeout (~> q-sel id .setAttribute \cx, end), 250
    e.animate tranf, opts
  # SETS
  sets:
    classic: ClassicSet
    common: CommonSet
    other: OtherSet

# OUTPUTS ####################################

window.App = App
