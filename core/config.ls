# DEFAULT SRC #####################
code =
  brew: [[ \app.ls, \bundle.js, [ \app.ls ]]]
  default:
    ls: [[ \app.ls, \app.js ]]
    pug: [[ \index.pug, \index.html ]]
    sass: [[ \style.sass, \style.css ]]
  roll: [[\app.ls, \bundle.js, [\app.ls ]]]

# UPDATED SRC #####################

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

roll = ->
  out = {}
  out <<<< code.default
  delete out.ls
  out.roll = code.roll
  out

# SPECIFIC SRC ####################

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

cs-src =
  roll: [[\scripts/app.ls, \app , [\scripts/app.ls, \scripts/editor.ls ]]]
  carlin: [[\index.pug, \index.html, [\index.pug ], \CSHtml ]]
  sass: [[\style.sass, \style ]]

# EXPORTED CONFIG #################

export cfg =
  dest: ''
  dest_path: { debug: \dist, release: \out, github: \docs }
  dir: ''
  id: 0
  list:
    # 54 Deck ################
    * active: yes
      name: '54 cards deck'
      path: \54_deck
      src: code.default
    # Criptic ################
    * active: yes
      name: 'Criptic'
      path: \criptic
      src: code.default
      cmds:
        copy: 'copy the criptic files from trancode'
    # Crunchy Cortex #########
    * active: no
      name: 'Crunchy Cortex'
      path: 'crunchy'
      font: [\crunchy/index.pug ]
      server: yes
      src: crunchy-src
      statiq: yes
      views: yes
    # CS #####################
    * active: no
      name: 'Cereal Killers'
      path: 'CS'
      font: [\CS/index.pug ]
      mono: yes
      data: \data.ls
      server: yes
      src: cs-src
    # The Clock ##############
    * active: no
      name: 'The Clock'
      path: \clock
      src: roll!
    # Final DR ###############
    * active: yes
      name: \final-diceroller
      path: \final-dr
      src: dr-src!
      cmds:
        bookmark: 'generate the bookmark code'
      version: 1.6
    # MineSweeper ############
    * active: yes
      name: \minesweeper
      path: \minesweeper
      src: brew!
      statiq: yes
      font: [ \minesweeper/index.pug ]
    # Simon's ################
    * active: no
      name: 'Simon\'s game'
      path: \simon
      font: [\simon/index.pug ]
      statiq: yes
      src: brew!
    # Test WASM ##############
    * active: no
      name: \wasm_test
      path: \wasm_test
      src: { pug: [[ \index.pug, \index.html ]] }
      wasm: yes
  out: ''
  root: { pug: [[\core/index.pug, \index.html ]] }
  # functional part
  chok: {}
  data: void
  fonts: void
  mono: void
  server: {}
  src: void
  statiq: []
  version: 0
  views: []
  watching: no