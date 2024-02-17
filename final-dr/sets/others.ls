require! {
  '../../utils/basics': { q-sel }
  './utils'
}

# D'n'G SET ##################################

class DagSet
  currcirc: 0
  currcomp: 0
  currfocus: 0
  circ: (mode) !-> @swap \circ, mode
  comp: (mode) !-> @swap \comp, mode
  dice-val: (mode) -> switch mode | -1 => 6 | 0 => 8 | 1 => 10
  focus: (mode) !->
    startv = App.tog-val 2, @currfocus
    endv = App.tog-val 2, mode
    App.toggle \#other2-dagfocus, [{cx: "#{startv}px"}, {cx: "#{endv}px"}]
    col = if mode is 0 then \black else \green
    q-sel \#other2-dagfocus .setAttribute \fill, col
    @currfocus = mode
  roll: ->
    dcirc = @dice-val @currcirc
    dcomp = @dice-val @currcomp
    rcirc = App.rand2 dcirc
    rcomp = App.rand2 dcomp
    [ft ,fc] = if @currfocus is 1 then [' (Inspiration)', yes] else ['', no]
    bst = if rcirc > rcomp then rcirc else rcomp
    tt = if bst >= (if fc then 5 else 6) then 'SUCCES!' else 'ECHEC!'
    "D&G:#ft<br/>Compétence (d#dcomp) : #rcomp<br/>" ++
      "Circonstance (d#dcirc) : #rcirc<br/>=> #tt"
  swap: (id, mode) !->
    startv = App.tog-val 3, @["curr#id"]
    endv = App.tog-val 3, mode
    App.toggle "\#other2-dag#id", [{cx: "#{startv}px"}, {cx: "#{endv}px"}]
    t = q-sel "\#other2-dag#{id}-text"
    t.style.display = \none
    t.textContent = @dice-val mode
    t.setAttributeNS void, \x, endv
    window.setTimeout (!~> t.style.display = \block), 200
    @["curr#id"] = mode

# FATE #######################################

function fate mode
  [md, tm, bn] =
    if mode is 0 then [\n, '', 0]
    else if mode < 0 then [\l, " (dis #mode)", Math.abs mode]
    else [\h, " (adv #mode)", mode]
  rolls = [App.rand2 3 for _ til (4 + (parseInt bn))].map (n) -> n - 2
  tt =
    if mode is \0 then rolls.reduce ((a, n) -> n + a), 0
    else
      kr = utils[ if mode < 0 then \kl else \kh ] 4, rolls
      rolls = utils.bold kr.ids, rolls
      kr.values.reduce ((a, n) -> n + a)
  "Fate#tm: [#{rolls * ', '}] => #tt"

# PBTA #######################################

function pbta mode
  rs = [(App.rand2 6), App.rand2 6]
  advdis = (kn, rs) ->
    rs.push (App.rand2 6)
    kr = utils[kn] 2, rs
    rs = utils.bold kr.ids, rs
    [kr.values[0] + kr.values[1], rs]
  [tt, rs, tm] = switch mode
    | \a => (advdis \kh, rs) ++ [' (adv)']
    | \d => (advdis \kl, rs) ++ [' (dis)']
    | \n => [rs[0] + rs[1], rs, '']
  "PbtA#tm: [#{rs * ', '}] => #tt"

# RECLUSE ####################################

function recluse mode
  to-bold = (arr) ->
    arr.push (App.rand2 6)
    id = if arr[0] >= arr[1] then 0 else 1
    itr = arr[id]
    arr[id] = "<b>#{arr[id]}</b>"
    [arr, itr]
  gr = [App.rand2 6]; br = [App.rand2 6]
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
  "Recluse#tm: [#{gr * ', '}] vs. [#{br * ', '}] => #tt"

# TINYD6 #####################################

class Tinyd6Set
  curr-advdis: 0
  roll: (mode) ->
    rs = [App.rand2 6]
    bst = rs[0]
    if mode in <[ n a ]>
      rs.push (App.rand2 6)
      if mode is \a then rs.push (App.rand2 6)
      a = utils.kh 1, rs
      bst = a.values[0]
      rs = utils.bold a.ids, rs
    tm = switch mode | mode is \d => ' (dis)' | mode is \a => ' (adv)' | _ => ''
    dif = 4 - @curr-advdis
    tt = if bst > dif then 'SUCCESS!' else 'FAILED'
    "Tinyd6#tm: [#{rs * ', '}] => #tt"
  disadv: (mode) !->
    startv = (App.tog-val 2, @curr-advdis)
    tranf = [{cx: "#{startv}px"}, {cx: "#{App.tog-val 2, mode}px"}]
    App.toggle \#other1-tinyad , tranf
    col = if mode is 0 then \black else \green
    q-sel \#other1-tinyad .setAttribute \fill, col
    @curr-advdis = mode

# ZOMBICIDE CHRONICLES #######################

function zc mode
  rs = [App.rand2 6 for _ til mode]
  if mode > 6
    for idx from 6 til mode
      if rs[idx] is 1 then rs[idx] = [rs[idx]+ \d, App.rand2 6]
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
  out = "ZC (#mode):<br />Basic: [#{acc.br * ', '}]<br />"
  if mode > 6 then out = out ++ "Master: [#{acc.mr * ', '}]<br />"
  out ++ "==> Molotov: #{acc.mol}, ZH: #{acc.zh}"

# OTHER SET MAIN CLASS #######################

export class OtherSet
  curr-tiny-adv: 0
  dag: new DagSet
  tinyd6: new Tinyd6Set
  roll: (sys, mode) !->
    r = switch sys
      | \dag     => @dag.roll!
      | \fate    => fate mode
      | \pbta    => pbta mode
      | \recluse => recluse mode
      | \tinyd6  => @tinyd6.roll mode
      | \zc      => zc mode
      | _        => alert 'Oops, something gone wrong here'; ''
    if r isnt '' then App.roll r