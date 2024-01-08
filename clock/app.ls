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

# CONFIG #####################################

Config =
  #
  # TODO
  #
  tt: \plop
  #

# CORE #######################################

App =
  canvas: void
  size: 0
  # methods
  draw: !->
    #
    # TODO
    #
    console.log 'draw the clock'
    #
  init: !->
    App.canvas = q-sel \#clock
    window.addEventListener \resize, App.resize
    @resize!
    @tick!
  resize: !->
    App.size =
      if window.innerWidth > window.innerHeight then window.innerHeight
      else window.innerWidth
    App.canvas.setAttribute \width, App.size
    App.canvas.setAttribute \height, App.size
    App.draw!
  tick: !->
    #
    # TODO
    #
    console.log \tick
    #
    #window.setTimeout
    #

# OUTPUTS ####################################

window.App = App