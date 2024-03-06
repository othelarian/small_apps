`` import { qSel, LocalStorage } from '../utils/esm.ls' ``

# CONFIG #####################################

Config =
  #
  # TODO
  #
  tt: \plop
  #

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
  draw: !->
    #
    # TODO
    #
    #console.log App.ctx
    #
    #console.log 'draw the clock'
    #
    dte = new Date!
    #
    App.ctx.fillStyle = 'red'
    App.ctx.fillRect 0, 0, App.size, App.size
    #
    #
  init: !->
    @cvs = q-sel \#clock
    @ctx = @cvs.getContext \2d
    @ls = new LocalStorage \clk
    #
    # TODO: get back the config
    #
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