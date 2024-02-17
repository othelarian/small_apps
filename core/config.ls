code =
  default:
    ls: [[ \app.ls, \app.js ]]
    pug: [[ \index.pug, \index.html ]]
    sass: [[ \style.sass, \style.css ]]

brew = ->
  out = {}
  out <<<< code.default
  out.brew = out.ls
  out.brew[0].push [ \app.js ]
  delete out.ls
  out

export cfg =
  dest: ''
  dest_path: { debug: \dist, release: \out, github: \docs }
  dir: ''
  id: 0
  fonts: void
  list:
    * active: yes
      name: '54 cards deck'
      path: \54_deck
      src: code.default
    * active: no
      name: 'The Clock'
      path: \clock
      src: code.default
    * active: yes
      name: \final-diceroller
      path: \final-dr
      src: code.default
      cmd: (cmd) !-> require! '../final-dr/cmds': module; module[cmd]!
      cmds:
        bookmark: 'generate the bookmark code'
    * active: yes
      name: \minesweeper
      path: \minesweeper
      src: brew!
      statiq: yes
      font: [ \minesweeper/index.pug ]
    * active: no
      name: 'Simon\'s game'
      path: \simon
      src: code.default
    * active: no
      name: \wasm_test
      path: \wasm_test
      src: { pug: [[ \index.pug, \index.html ]] }
      wasm: yes
  out: ''
  root: { pug: [[\core/index.pug, \index.html ]] }
  src: void
  statiq: []
  watching: no
  chok: {}