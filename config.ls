code =
  default:
    ls: [[\app.ls, \app.js ]]
    pug: [[\index.pug, \index.html ]]
    sass: [[\style.sass, \style.css ]]

exports.cfg =
  dest: ''
  dest_path: { debug: \dist, release: \out, github: \docs }
  dir: ''
  id: 0
  list:
    * active: yes
      name: '54 cards deck'
      path: \54_deck
      src: code.default
    * active: no
      name: \final-diceroller
      path: \final-dr
      src: code.default
    * active: yes
      name: \minesweeper
      path: \minesweeper
      src: code.default
    * active: no
      name: 'Zombicide Decks Handler'
      path: \zombicide_deck
      src: code.default
    # svg_map
  out: ''
  root: { pug: [[\index.pug, \index.html ]] }
  src: void
  watching: no
  chok: {}