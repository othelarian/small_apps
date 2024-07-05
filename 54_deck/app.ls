# UTILS ######################################

function c-elt tag, attrs = {}, txt = void, html = void
  elt = document.createElement tag
  for k, v of attrs then elt.setAttribute k, v
  if txt? then elt.innerText = txt
  else if html? then elt.innerHTML = html
  elt

function q-sel s, a = no
  if a then document.querySelectorAll s
  else document.querySelector s

function rand2 m
  Math.floor (Math.random! * m)

# DECK #######################################

State =
  # attributes
  s: [] # the deck
  f: [] # the shuffle
  #h: [] # the hand # TODO
  hs: [[]] # multiple hands
  nh: 1 # number of hand (min: 1)
  #
  # TODO: n instead of h?
  #
  d: [] # the discard
  p: 0  # the next position to read
  # methods
  gendeck: (s, t = void) ->
    a = if t? then t else [0 til s]
    for v, i in a by -1
      p = rand2(i + 1)
      a[i] = a[p]
      a[p] = v
    a
  reset: (d) !->
    State <<<< {s: d, f: State.gendeck(d.length), hs: [[]], nh: 1, d: [], p: 0}

Deck =
  back: !->
    try
      q-sel '#deck-cards' .value = JSON.parse(q-sel '#deck-curr' .value) .s
        |> JSON.stringify
    catch e
      App.veil.open 'no-deck-err'
  card: (id) !->
    e = c-elt \div {class: 'card', id: "c#{id}"}
    e.append c-elt \span {class: \text} State.s[id]
    s = c-elt \span {class: \btns}
    s.append c-elt \button {onclick: "App.deck.discard(#{id})"} 'D'
    e.append s
    q-sel '#play-hand' .append e
  clean: (hand = no) !->
    #
    # TODO: how to clean the hand number too?
    #
    if hand
      q-sel '#play-hand' .innerHTML = ''
      State.hs = [[]]
    q-sel '#play-discard' .innerHTML = ''
    State.d = []
  copy: !->
    navigator.clipboard.writeText q-sel('#deck-curr').value
  discard: (id, load = no) !->
    #
    # TODO: add a button to get the card back in hand
    #
    State.hs.0 = State.hs.0.filter (isnt id)
    State.d.push id
    q-sel "\#c#id button" .remove!
    q-sel '#play-discard' .append q-sel "\#c#id"
    if not load
      App.deck.stats!
      App.deck.dump!
  draw: !->
    if State.p < State.s.length
      id = State.f[State.p]
      #
      # TODO: insert into the only hand we have right now
      #
      State.hs.0.push id
      #
      App.deck.card id
      State.p++
      App.deck.stats!
      App.deck.dump!
  dump: !->
    q-sel '#deck-curr' .value = JSON.stringify State
  generate: (newdeck = yes) !->
    d = if newdeck then JSON.parse(q-sel '#deck-cards' .value) else State.s
    State.reset d
    App.deck.clean yes
    App.deck.stats!
    App.deck.dump!
  load: !->
    ld = JSON.parse(q-sel '#deck-curr' .value)
    du = no
    if ld.h?
      ld.hs = [ld.h]
      ld.nh = 1
      delete ld.h
      du = yes
    State <<< ld
    if du then App.deck.dump!
    App.deck.clean yes
    #
    # TODO: modify this to adapt to multi hand system
    #
    console.log ld
    #
    for id in (ld.hs.flat!concat ld.d) then App.deck.card id
    for id in ld.d then App.deck.discard id, yes
    App.deck.stats!
  regen: !->
    App.deck.generate no
  shuffle: !->
    App.deck.clean!
    nd = [0 til State.s.length].filter (v) -> (State.h.findIndex (is v)) is -1
    nd = State.gendeck void, nd
    State.p = State.h.length
    State.f = State.h.concat nd
    App.deck.stats!
    App.deck.dump!
  stats: !->
    q-sel '#play-stats-left' .innerText = State.s.length - State.p
    q-sel '#play-stats-hand' .innerText = State.hs.flat!length
    q-sel '#play-stats-discard' .innerText = State.d.length

# CORE #######################################

App =
  deck: Deck
  init: !->
    App.sample.copy \classic
    q-sel '#screen-play' .style.display = \block
  menu:
    status: \play
    action: (act) !->
      if act isnt App.menu.status
        switchy = (curr, d) ->
          b = q-sel "\#menu-btn-#{curr}"
          if d then b.classList.add \selected else b.classList.remove \selected
          s = q-sel "\#screen-#{curr}"
          s.style.display = if d then \block else \none
        switchy App.menu.status, off
        switchy act, on
        App.menu.status = act
  sample:
    copy: (deck) !->
      q-sel '#deck-cards' .value = q-sel "\#sample-#{deck}" .innerText
  veil:
    curr: ''
    activate: (d) !->
      q-sel '#veil' .style.display = if d then \block else \none
      q-sel "\#veil-#{App.veil.curr}" .style.display = if d then \block else \none
    open: (screen) !->
      App.veil.curr = screen
      switch screen
      | \deck
        lst = q-sel '#veil-deck-list'
        lst.innerHTML = ''
        lst.innerHTML =
          if State.s.length is 0 then 'There\'s no card in the deck'
          else (for c in State.s then "<span>#{c}</span>") * ''
      App.veil.activate on
    close: !->
      App.veil.activate off
      App.veil.curr = ''

init = !-> App.init!

# OUTPUTS ####################################

window.State = State
window.App = App
window.init = init
