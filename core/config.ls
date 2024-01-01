code =
  default:
    ls: [[ \app.ls, \app.js ]]
    pug: [[ \index.pug, \index.html ]]
    sass: [[ \style.sass, \style.css ]]

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
    * active: yes
      name: \final-diceroller
      path: \final-dr
      src: code.default
      cmd: (cmd) !-> require! '../final-dr/cmds': module; module[cmd]!
      cmds:
        bookmark: 'generate the bookmark code'
    * active: no
      name: \minesweeper
      path: \minesweeper
      src: code.default
      statiq: yes
      font: yes
    #
    # TODO: simon
    #
    * active: no
      name: \wasm_test
      path: \wasm_test
      src: { pug: [[ \index.pug, \index.html ]] }
      wasm: yes
    #
  out: ''
  root: { pug: [[\core/index.pug, \index.html ]] }
  src: void
  statiq: []
  watching: no
  chok: {}