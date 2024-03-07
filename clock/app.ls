`` import { qSel, LocalStorage } from '../utils/esm.ls' ``

# UTILS ######################################

get-pt = (d, a, o, i = no) ->
  #x = Math.cos(a) * d
  #y = Math.sin(a) * d
  #if i then [o.0 - x, o.1 - y] else [x + o.0, y + o.1]
  [Math.cos(a) * d + o.0, Math.sin(a) * d + o.1]

to-rad = (a) -> a * Math.PI / 180

needle = (center, dg, cfg) !->
  npt = (tr) -> get-pt (center * tr), (to-rad dg), [center, center], no
  [ox, oy] = npt cfg.origin
  [ex, ey] = npt cfg.size
  pth = new Path2D!
    ..moveTo ox, oy
    ..lineTo ex, ey
  App.ctx
    ..strokeStyle = cfg.color
    ..lineWidth = cfg.thick
    ..stroke pth

# CONFIG #####################################

Config =
  #
  # TODO
  #
  hours:
    needle:
      active: yes
      color: \darkgray
      origin: 0
      size: 0.5
      thick: 7
  mins:
    needle:
      active: yes
      color: \black
      origin: 0
      size: 0.6
      thick: 4
  secs:
    needle:
      active: yes
      color: \black
      origin: 0.2
      size: 0.8
      thick: 2
  back: \white

tmp = {}

# CORE #######################################

App =
  cfg: no
  ctx: void
  cvs: void
  hgt: 0
  ls: void
  size: 0
  timer: void
  # methods
  #
  rop: (deg) ->
    #
    a = get-pt 100, (to-rad deg), [0, 0], no
    #
    #console.log a
    a
  #
  config: !->
    #
    # TODO
    #
    document.body.style.setProperty \--back-col, Config.back
  draw: !->
    #
    # TODO
    #
    #console.log App.ctx
    #
    #console.log 'draw the clock'
    #
    dte = new Date!
    center = App.size / 2
    # background
    App.ctx.fillStyle = Config.back
    App.ctx.fillRect 0, 0, App.size, App.size
    #
    # hours
    #
    if Config.hours.needle.active
      needle center, ((dte.getHours! % 12) * 30 - 90), Config.hours.needle
    #
    # mins
    #
    #
    if Config.mins.needle.active
      needle center, (dte.getMinutes! * 6 - 90), Config.mins.needle
    #
    # seconds
    #
    if Config.secs.needle.active
      needle center, (dte.getSeconds! * 6 - 90), Config.secs.needle
  init: !->
    @cvs = q-sel \#clock
    @ctx = @cvs.getContext \2d
    @ls = new LocalStorage \clk
    #
    # TODO: get back the config
    #
    @config!
    window.addEventListener \resize, App.resize
    @resize yes
    @tick!
  resize: (force = no) !->
    chg = no
    ns =
      if App.cfg
        [size, ns] =
          if window.innerWidth <= 700
            document.body.style.justifyContent = 'normal'
            ['calc(100vw - 20px)', window.innerWidth - 20]
          else if (window.innerWidth - 400) < window.innerHeight
            ['calc(100vw - 350px)', window.innerWidth - 350]
          else
            document.body.style.justifyContent = ''
            ['100vh', window.innerHeight]
        App.cvs.style.width = size
        App.cvs.style.height = size
        ns
      else
        [size, vx, mt] =
          if window.innerWidth > window.innerHeight
            unless App.hgt is 0 then chg = yes;App.hgt = 1
            [window.innerHeight, 'vh']
          else
            if App.hgt is 1 then chg = yes;App.hgt = 0
            [window.innerWidth, 'vw']
        if chg or force
          App.cvs.style.width ="100#vx"
          App.cvs.style.height = "100#vx"
        size
    App.cvs.setAttribute \width, ns
    App.cvs.setAttribute \height, ns
    App.size = ns
    App.draw!
  tick: !->
    unless App.cfg
      delay = 1000 - (new Date!getMilliseconds!)
      App.timer = window.setTimeout App.tick, delay
      App.draw!
  toggle: !->
    disconf =
      if @cfg
        @cfg = no
        document.body.style.justifyContent = ''
        @tick!
        'none'
      else
        @cfg = yes
        window.clearTimeout @timer
        ''
    q-sel \#config .style.display = disconf
    @resize yes

# OUTPUTS ####################################

window.App = App