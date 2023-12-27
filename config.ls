code =
  default:
    ls: [[\app.ls, \app.js ]]
    pug: [[\index.pug, \index.html ]]
    sass: [[\style.sass, \style.css ]]

export cfg =
  dest: ''
  dest_path: { debug: \dist, release: \out, github: \docs }
  dir: ''
  id: 0
  list:
    * active: yes
      name: '54 cards deck'
      path: \54_deck
      src: code.default
    #
    # TODO: clock
    #
    * active: no
      name: \final-diceroller
      path: \final-dr
      src: code.default
      cmd:
        bookmark: \get_bookmark
    * active: no
      name: \minesweeper
      path: \minesweeper
      src: code.default
      statiq: yes
      font: yes
    #
    # TODO: simon
    #
    * active: yes
      name: \wasm_test
      path: \wasm_test
      src: [
        []
      ]
      cmd:
        wasm: \wasm
    #
  out: ''
  root: { pug: [[\index.pug, \index.html ]] }
  src: void
  statiq: []
  watching: no
  chok: {}