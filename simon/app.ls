# REQUIRES ###################################

require! {
  '../utils/basics': {q-sel}
  '../utils/ls-class': {LocalStorage}
}

# UTILS ######################################

toggle = (id) !-> q-sel id .classList.toggle \hidden

# AUDIO ######################################

class Audio
  audio-ctx: void
  sd: [1 to 4]
  init: !->>
    @audio-ctx = new AudioContext!
    for i in [1 to 4]
      sd = await fetch "statiq/sound_#i.mp3"
      buf = await sd.arrayBuffer!
      @sd[i - 1] = await @audio-ctx.decodeAudioData buf
  play: (sound) !->
    src = @audio-ctx.createBufferSource!
    src.buffer = @sd[sound]
    src.connect @audio-ctx.destination
    src.start 0.1, 0.1

# SETTINGS ###################################

class Settings
  !->
    if ls.check \sound then @sound(ls.get \sound)
    if ls.check \theme then @theme(ls.get \theme)
  currsound: 1
  currtheme: 1
  sound: (mode) !->
    if typeof mode is \string then mode = parseInt mode
    if mode isnt @currsound
      a = q-sel \#set-sound-c
      q-sel \#set-sound-c .setAttribute \cx, (if mode is 0 then 10 else 33)
      @currsound = mode
      ls.save \sound, mode
  theme: (mode) !->
    if typeof mode is \string then mode = parseInt mode
    [alt-a-col, base-col, inv-col, cx] = switch mode
      | 0 => [\#777, \#333, \white, 10]
      | 1 => [\#ddd, \white, \#333, 33]
    if mode isnt @currtheme
      stl = document.body.style
      stl.setProperty \--alt-a-col, alt-a-col
      stl.setProperty \--base-col, base-col
      stl.setProperty \--inv-col, inv-col
      q-sel \#set-theme-c .setAttribute \cx, cx
      @currtheme = mode
    ls.save \theme, mode

# SINGLETONS #################################

audio    = void
ls       = void
settings = void

# CORE #######################################

App =
  bestscore: 0
  init-audio: no
  order: <[upleft upright downright downleft]>
  #
  sound: (id) !-> audio.play id
  #
  active: (v) !->
    #
    # TODO
    #
    idx = App.order.indexOf v
    console.log idx
    #
    audio.play idx
    #
  init: !->
    audio    := new Audio!
    ls       := new LocalStorage \simon
    settings := new Settings!
    if ls.check \bestscore
      App.bestscore = ls.get \bestscore
      q-sel '#bestscore span.value' .innerText = App.bestscore
      toggle \#bestscore
    toggle \#welcome
  play: !->>
    unless App.init-audio then await audio.init!; App.init-audio = yes
    #
    # TODO
    #
    toggle \#welcome
    toggle \#game
    #
  settings: (entry, mode) !-> settings[entry] mode

# OUTPUTS ####################################

window.App = App