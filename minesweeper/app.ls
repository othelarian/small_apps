# REQUIRES ###################################

require! {
  '../utils/basics': { c-elt, q-sel }
  '../utils/cookies': { Cookie }
  '../utils/local-storage': { LS }
}

# UTILS ######################################

function rand2 m then Math.floor (Math.random! * m)

# AUDIO ######################################

Audio =
  audio: {}
  init: !->
    for elt in <[ explosion flag reveal success unflag ]>
      Audio.audio[elt] = q-sel "\#aud-#elt"
      Audio.audio[elt].volume = 0.5
  play: (sound) !-> if Settings.currsound is 1 then Audio.audio[sound].play!

# GAME MENU ##################################

Menu =
  end: !-> q-sel \#time-play .style.display = \none
  fail: !-> @end!; q-sel \#state-fail .style.display = ''
  pause: !->
    tp = q-sel \#time-play .innerText =
      (if Timer.paused then 'Pause' else 'Continue')
  start: (nb) !->
    tp = q-sel \#time-play
    tp.style.display = ''
    tp.innerText = 'Pause'
    q-sel \#left .innerText = nb
    q-sel \#total .innerText = nb
    for elt in <[#state-fail #state-success]>
      q-sel elt .style.display = \none
    q-sel \#state-play .style.display = ''
  success: !->
    @end!
    q-sel \#state-play .style.display = \none
    q-sel \#time-play .style.display = \none
    q-sel \#state-success .style.display = ''
  update: (nb) !-> q-sel \#left .innerText = nb

# SETTINGS ###################################

Settings =
  currsound: 1
  currtheme: 1
  sound: (mode) !->
    if typeof mode is \string then mode = parseInt mode
    if mode isnt Settings.currsound
      q-sel \#set-sound-c .setAttribute \cx, (if mode is 0 then 10 else 33)
      Settings.currsound = mode
      Cookie.set \sound, mode
  theme: (mode) !->
    if typeof mode is \string then mode = parseInt mode
    [alt-a-col, base-col, inv-col, cx] = switch mode
      | 0 => [\#777, \#333, \white, 10]
      | 1 => [\#ddd, \white, \#333, 33]
    if mode isnt Settings.currtheme
      stl = document.body.style
      stl.setProperty \--alt-a-col, alt-a-col
      stl.setProperty \--base-col, base-col
      stl.setProperty \--inv-col, inv-col
      q-sel \#set-theme-c .setAttribute \cx, cx
      Settings.currtheme = mode
    Cookie.set \theme, mode

# TIMER ######################################

Timer =
  base: 0
  paused: no
  timer: void
  pause: !->
    if @paused then @run!
    else
      window.clearTimeout @timer
      App.cfg.timer[App.cfg.timer.length - 1].push(new Date!.valueOf!)
      @paused = yes
  run: !->
    @paused = no
    reft = App.cfg.timer
    nt = new Date!.valueOf!
    if reft.length is 0 then @base = nt
    else
      inr = reft.reduce ((acc, elt) -> acc + (elt[1] - elt[0])), 0
      @base = nt - inr
    App.cfg.timer.push [nt]
    @timer = window.setTimeout Timer.update, 10
  update: !->
    curr = new Date!.valueOf!
    ect = curr - Timer.base
    unless Timer.paused
      Timer.timer = window.setTimeout Timer.update, (1000 - (ect % 1000))
    tt = Math.floor (ect / 1000)
    ts = tt % 60
    ts = if ts < 10 then "0#ts" else ts
    tm = Math.floor tt / 60
    q-sel \#time-curr .innerText = "#tm:#ts"

# CORE #######################################

App =
  cfg: {rows: 15, columns: 10, mines: 40, running: no, tofind: 0}
  # methods
  cancel: !->
    LS.clean \game
    @cfg.running = no
    q-sel \#load-save .style.display = \none
    q-sel \#config .style.display = \grid
    delete @cfg.tmp
  cfgbase: -> {b: [], f: {}, h: [], timer: []}
  close: !->
    if @cfg.running
      unless Timer.paused then Timer.pause!
      @save!
  config: (show = no) ->
    check = (acc, elt) ->
      unless acc then acc
      else
        v = q-sel "\#form-#elt" .value
        if isNaN v or v < 1
          if show then alert "You entered a bad value for the #elt!"
          no
        else if v >= (if elt is \mines then 9999 else 100)
          if show then alert "You entered a value too high for the #elt!"
          no
        else App.cfg[elt] = v;yes
    r = <[rows columns mines]>.reduce check, yes
    if r
      cof = {rows: @cfg.rows, columns: @cfg.columns, mines: @cfg.mines}
      LS.save \config, (JSON.stringify cof)
    r
  flag: (x, y, evt) !->
    evt.preventDefault!
    key = "#{x}-#y"
    cell = q-sel "\#cell-#key"
    if @cfg.running and not cell.classList.contains \revealed
      if @cfg.f.hasOwnProperty "f-#key"
        delete @cfg.f["f-#key"]
        cell.innerHTML = ''
        Audio.play \unflag
      else
        @cfg.f["f-#key"] = yes
        cell.innerHTML = "<svg><use href='\#flag'/></svg>"
        Audio.play \flag
      #@cfg.h.push {t: \f, x, y} # -> no need, just have to get the list
      Menu.update(@cfg.mines - Object.keys(@cfg.f).length)
      @save!
  init: !->
    @cfg <<<< @cfgbase!
    Audio.init!
    if LS.check \config
      try
        for key, val of (JSON.parse (LS.get \config ))
          @cfg[key] = val
          q-sel "\#form-#key" .value = val
      catch e
        void
    LS.init \ms
    if LS.check \game
      try
        tmp = JSON.parse (LS.get \game)
        if tmp.timer[tmp.timer.length - 1].length is 1 then LS.clean \game
        else
          q-sel \#config .style.display = \none
          q-sel \#load-save .style.display = \block
          @cfg.tmp = tmp
      catch e
        LS.clean \game
    Cookie.init \ms
    cks = Cookie.check!
    for key in <[ theme sound ]>
      if cks.hasOwnProperty "ms-#key" then Settings[key] cks["ms-#key"]
  load: !->
    may-add = (x, y) -> if App.cfg.b[x][y] is -1 then 1 else 0
    thegrid = q-sel \#thegrid
    while thegrid.firstChild? then thegrid.removeChild thegrid.firstChild
    for x til @cfg.rows then for y til @cfg.columns
      if @cfg.b[x][y] isnt -1
        g = 0
        py = y isnt 0
        ay = y isnt (@cfg.columns - 1)
        if x isnt 0
          if py then g += may-add (x - 1), (y - 1)
          g += may-add (x - 1), y
          if ay then g += may-add (x - 1), (y + 1)
        if py then g += may-add x, (y - 1)
        if ay then g += may-add x, (y + 1)
        if x isnt (@cfg.rows - 1)
          if py then g += may-add (x + 1), (y - 1)
          g += may-add (x + 1), y
          if ay then g += may-add (x + 1), (y + 1)
        @cfg.b[x][y] = g
      attrs =
        style: "grid-column-start:#{y+1}"
        id: "cell-#x-#y"
        onclick: "App.reveal(#x, #y)"
        oncontextmenu: "App.flag(#x, #y, event)"
      thegrid.appendChild c-elt \button, attrs
      /* this code show the mines and numbers
      val = switch @cfg.b[x][y]
        | -1 => \*
        | 0  => ''
        | _  => @cfg.b[x][y]
      thegrid.appendChild c-elt \button, attrs, val
      */
    @cfg.tofind = @cfg.rows * @cfg.columns - @cfg.mines
    @cfg.running = yes
    Menu.start @cfg.mines
    q-sel \#config .style.display = \none
    q-sel \#mines .style.display = \block
  pause: !->
    [gridst, pausest] =
      if Timer.paused then ['', \none ] else [\none, \flex ]
    q-sel \#thegrid .style.display = gridst
    q-sel \#pause-veil .style.display = pausest
    Menu.pause!
    Timer.pause!
  play: !->
    if @config yes
      if @cfg.mines >= (@cfg.rows * @cfg.columns)
        alert "There's too many mines for the zone!"
      else
        @cfg <<<< @cfgbase!
        mr = @cfg.rows * @cfg.columns
        b = [0 for til mr]
        o = 0
        while o < @cfg.mines
          nv = rand2 mr
          if b[nv] isnt -1
            b[nv] = -1
            o += 1
        for x til @cfg.rows
          @cfg.b.push b.slice (x*@cfg.columns), ((x+1)*@cfg.columns)
        @config!
        @load!
        Timer.run!
        @save!
  quit: !->
    LS.clean \game
    @cfg.running = no
    q-sel \#mines .style.display = \none
    q-sel \#config .style.display = \grid
  reload: !->
    q-sel \#load-save .style.display = \none
    @cfg <<<< @cfg.tmp
    delete @cfg.tmp
    @load!
    for act in @cfg.h
      switch act.t
        | \r => @reveal act.x, act.y, no, no
    for flg in Object.keys @cfg.f
      [_, x, y] = flg.split \-
      q-sel "\#cell-#{x}-#y" .innerHTML = "<svg><use href='\#flag'/></svg>"
    @cfg.running = yes
    Timer.run!
    @save!
  reveal: (x, y, force = no, sound = yes) !->
    if @cfg.running and not @cfg.f.hasOwnProperty "f-#{x}-#y"
      tst = switch @cfg.b[x][y]
        | -1
          @cfg.running = no
          Timer.pause!
          Menu.fail!
          for fx til @cfg.rows then for fy til @cfg.columns
            [st, cls, href] =
              if fx is x and fy is y then [yes, 'explode', 'sun']
              else if "f-#{fx}-#fy" of @cfg.f
                if @cfg.b[fx][fy] is -1 then [yes, 'goodflag', 'flag']
                else [yes, 'badflag', 'flagOff']
              else if @cfg.b[fx][fy] is -1 then [yes, '', 'bomb']
              else [no]
            if st
              elt = q-sel "\#cell-#{fx}-#fy"
              elt.innerHTML = "<svg><use class='#cls' href='\##href'/></svg>"
              elt.classList.add \revealed
          LS.clean \game
          Audio.play \explosion
          no
        | 0
          elt = q-sel "\#cell-#{x}-#y"
          unless elt.classList.contains \revealed
            elt.classList.add \revealed
            elt.innerText = ''
            py = y isnt 0
            ay = y isnt (@cfg.columns - 1)
            if x isnt 0
              if py then @reveal (x - 1), (y - 1), yes
              @reveal (x - 1), y, yes
              if ay then @reveal (x - 1), (y + 1), yes
            if py then @reveal x, (y - 1), yes
            if ay then @reveal x, (y + 1), yes
            if x isnt (@cfg.rows - 1)
              if py then @reveal (x + 1), (y - 1), yes
              @reveal (x + 1), y, yes
              if ay then @reveal (x + 1), (y + 1), yes
            if not force and sound then Audio.play \reveal
            yes
          else no
        | _
          elt = q-sel "\#cell-#{x}-#y"
          unless elt.classList.contains \revealed
            elt.classList.add \revealed
            a = @cfg.b[x][y]
            elt.innerHTML = "<span class='c#a'>#a</span>"
            if not force and sound then Audio.play \reveal
            yes
          else no
      if tst
        unless force then @cfg.h.push {t: \r, x, y}
        @cfg.tofind = @cfg.tofind - 1
        if @cfg.tofind is 0
          Timer.pause!
          @cfg.running = no
          Menu.success!
          Audio.play \success
  save: !->
    savr = (acc, elt) -> acc[elt] = App.cfg[elt]; acc
    saver = <[rows columns mines b f h timer]>.reduce savr, {}
    LS.save \game, (JSON.stringify saver)
  settings: (entry, mode) !-> Settings[entry] mode

# OUTPUTS ####################################

window.App = App