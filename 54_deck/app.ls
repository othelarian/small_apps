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
  s: []
  f: []
  h: []
  p: 0

Deck =
  #
  # TODO: h(and?) / d(iscard) / f / p(osition):0
  #
  clear: !->
    #
    # TODO: clear the play screen with all the current stuff
    #
  dump: !->
    q-sel '#deck-curr' .value = JSON.stringify State
  generate: !->
    #
    # TODO
    #
    d = JSON.parse(q-sel '#deck-cards' .value)
    #
    # TODO: get the d length and generate the table from it
    #
    #
    # TODO: h: [], d: [], f: [], p:0
    #
    State.s = d
    State.f = []
    State.h = []
    for i til d.length then State.f.push rand2(d.length - i)
    #
    #initPack(); updateNb();
    #
    # TODO: clear the play screen
    #
    App.deck.clear!
    App.deck.dump!
  load: !->
    #
    # TODO
    #
    console.log 'loading not ready'
    #
    #
    # TODO: going back to 'play'
    #
    #

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

init = !-> App.init!

# OUTPUTS ####################################

window.State = State
window.App = App
window.init = init
