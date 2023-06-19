code = {
  default: {
    ls: [['app.ls', 'app.js']]
    pug: [['index.pug', 'index.html']]
    sass: [['style.sass', 'style.css']]
  }
}

exports.cfg = {
  dest: ''      # release mode dir
  dest_path: {  # paths list, depends on the mode
    debug: 'dist'
    release: 'out'
    github: 'docs'
  }
  dir: ''       # code input dir
  id: 0         # current compiling project id
  list: [
    {
      active: no
      name: 'Zombicide Decks Handler'
      path: 'zombicide_decks'
      src: code.default
    }
    {
      active: yes
      name: '54 cards deck'
      path: '54_deck'
      src: code.default
    }
    {
      active: yes
      name: 'final-diceroller'
      path: 'final-dr'
      src: code.default
    }
    {
      active: no
      name: 'bookmarks'
      path: 'bookmarks'
      src: {
        ls: ['']
      }
    }
  ]
  out: ''       # code output dir
  src: null     # how is handle the sources
  watching: no  # to activate chokidar/server
  chok: {}
}
