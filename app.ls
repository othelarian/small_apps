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
  Math.floor (Math.random! * m)

# DECK #######################################

State =
  # attributes
  s: [] # the deck
  f: [] # the shuffle
  h: [] # the hand
  p: 0  # the next position to read
  # methods
  reset: (d) !~> #TODO: verify the '@' usage here
    @ <<<< {s: d, f: [], h: [], p: 0}
    for i til @d.length then @f.push rand2(@d.length - i)

Deck =
  back: !->
    q-sel '#deck-cards' .value = JSON.parse(q-sel '#deck-curr' .value) .s
      |> JSON.stringify
  clean: (hand = no) !->
    #
    # TODO: clean all the cards drawed
    #
    console.log 'clean not ready'
    #
  clear: !->
    App.deck.clean!
    App.deck.stats!
  copy: !->
    navigator.clipboard.writeText q-sel('#deck-save-text').value
  draw: !->
    #
    # TODO: drawing a card
    #
    console.log 'draw a card (not ready)'
    #
  dump: !->
    q-sel '#deck-curr' .value = JSON.stringify State
  generate: (newdeck = yes, olddeck = no) !->
    d =
      if newdeck then JSON.parse(q-sel '#deck-cards' .value)
      else
        if olddeck? then JSON.parse(q-sel '#deck-curr' .value).s
        else State.s
    State.reset d
    App.deck.clean yes
    App.deck.stats!
    App.deck.dump!
  load: !->
    App.deck.generate no, yes
  regen: !->
    App.deck.generate no
  shuffle: !->
    #
    # TODO: shuffle under the position
    #
    console.log 'shuffle not ready yet'
    #
  stats: !->
    q-sel '#play-stats-left' .innerText = State.s.length
    q-sel '#play-stats-hand' .innerText = State.h.length
    q-sel '#play-stats-discard' .innerText = State.p - State.h.length

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
      q-sel "\#veil-#{App.veil.screen}" .style.display = if d then \block else \none
    open: (screen) !->
      App.veil.curr = screen
      App.veil.activate on
    close: !->
      App.veil.activate off
      App.veil.curr = ''

init = !-> App.init!

# OUTPUTS ####################################

window.State = State
window.App = App
window.init = init
