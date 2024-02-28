code =
  brew: [[ \app.ls, \bundle.js, [ \app.ls ]]]
  default:
    ls: [[ \app.ls, \app.js ]]
    pug: [[ \index.pug, \index.html ]]
    sass: [[ \style.sass, \style.css ]]

brew = ->
  out = {}
  out <<<< code.default
  delete out.ls
  out.brew = code.brew
  out

dr-src = ->
  out = brew!
  sets = <[classic cortex utils others]>
  for set in sets then out.brew[0][2].push "sets/#set.ls"
  out

crunchy-src =
  brew: [
    [\scripts/main.ls, \scripts/main.js,
      [\scripts/main.ls, \scripts/dr.ls ]
    ]
  ]
  ls:
    [\scripts/fiche.ls, \scripts/fiche.js ]
    [\scripts/persos.ls, \scripts/persos.js ]
  pug: [[\index.pug, \index.html ]]
  sass:
    [\styles/fiche.sass, \styles/fiche.css ]
    [\styles/main.sass, \styles/main.css ]

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
      name: 'Crunchy Cortex'
      path: 'crunchy'
      font: [\crunchy/index.pug ]
      server: yes
      src: crunchy-src
      statiq: yes
      views: yes
    * active: no
      name: 'Cereal Killers'
      path: 'CS'
      mono: yes
      server: yes
      #
      # TODO: finalizing the config for CS
      #
      src: []
      #
    * active: no
      name: 'The Clock'
      path: \clock
      src: code.default
    * active: yes
      name: \final-diceroller
      path: \final-dr
      src: dr-src!
      cmd: (cmd) !-> require! '../final-dr/cmds': module; module[cmd]!
      cmds:
        bookmark: 'generate the bookmark code'
      version: 1.6
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
  server: {}
  src: void
  statiq: []
  version: 0
  views: []
  watching: no
  chok: {}