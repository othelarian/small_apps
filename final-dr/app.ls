# REQUIRES ###################################

require! {
  '../utils/basics': { c-elt, q-sel }
  './sets/classic': { ClassicSet }
  './sets/others': { OtherSet }
}

# CORE #######################################

App =
  curr-flip: no
  curr-set: ''
  init: !->
    window.addEventListener 'resize', App.resize
    App.show \classic
    # firefox hack
    q-sel \#the-selector .value = \classic
  flip: !->
    if App.curr-flip
      for col in document.querySelectorAll \.cols then col.removeAttribute \style
      App.curr-flip = no
    else
      q-sel \#diceroller .setAttribute \style \display:none
      q-sel \#history .setAttribute \style \display:block
      App.curr-flip = yes
  rand2: (m) -> Math.ceil (Math.random! * m)
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
  toggle: (id, tranf) !->
    q-sel id .animate tranf, { duration: 200, fill: \forwards }
  tog-val: (nb, mode) ->
    | nb is 2
      switch mode | 0 => 9 | 1 => 30
    | nb is 3
      switch mode | -1 => 9 | 0 => 30 | 1 => 51
  # SETS
  sets:
    classic: new ClassicSet
    other: new OtherSet

# OUTPUTS ####################################

window.App = App
