# UTILS ######################################

function c-elt tag, attrs, txt, html
  elt = document.createElement tag
  for k, v of attrs then elt.setAttribute k, v
  if txt? then elt.innerText = txt
  else if html? then elt.innerHTML = html
  elt

function q-sel s, a = no
  if a then document.querySelectorAll s
  else document.querySelector s

function rand2 m then Math.floor (Math.random! * m)

# LS #########################################

LS =
  check: ->
    tryit = 'try_lstest'
    try
      localStorage.setItem tryit, tryit
      localStorage.getItem tryit
      localStorage.removeItem tryit
      true
    catch
      false
  del: (key) !-> localStorage.removeItem "ms-#key"
  get: (key) -> localStorage.getItem "ms-#key"
  prop: (prop) -> localStorage.hasOwnProperty "ms-#prop"
  set: (key, value) !-> localStorage.setItem "ms-#key", value

# CORE #######################################

App =
  cfg: { rows: 15, columns: 10, mines: 40, b: [], h: [] }
  init: !->
    if LS.check!
      #
      console.log 'LS available'
      #
      if LS.get \game
        #
        console.log 'there is a game!'
        #
        #
        #
      #
    #
    # TODO: check for localStorage ?
    #
    console.log 'init app'
    #
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
      #thegrid.appendChild c-elt \div, attrs
      #
      # TODO: just for test purpose, remove later
      #
      val = switch @cfg.b[x][y]
        | -1 => \*
        | 0  => ''
        | _  => @cfg.b[x][y]
      #
      thegrid.appendChild c-elt \div, attrs, val
      #
    q-sel \#quit .innerText = \Cancel
    q-sel \#left .innerText = @cfg.mines
    q-sel \#total .innerText = @cfg.mines
    for elt in <[#state-fail #state-success #state-end #config]>
      q-sel elt .style.display = \none
    q-sel \#state-play .style.display = \inline-block
    q-sel \#mines .style.display = \block
  play: !->
    check = (acc, elt) ->
      if not acc then acc
      else
        v = q-sel "##elt" .value
        if isNaN v or v < 1
          alert "You entered a bad balue for the #{elt.slice 5}"
          no
        else
          App.cfg[elt.slice 5] = v
          true
    if [\form-rows, \form-columns, \form-mines ].reduce check, yes
      if @cfg.mines >= (@cfg.rows * @cfg.columns)
        alert "There's too many mines for the zone!"
      else
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
        @cfg.h = []
        LS.set \game, JSON.stringify { b: @cfg.b, h: [] }
        @load!
  flag: (x, y, evt) !->
    evt.preventDefault!
    #
    # TODO: show a flag and switch to block
    #
    q-sel "\#cell-#x-#y"
    |> console.log
    #
    #
  quit: !->
    q-sel \#mines .style.display = \none
    q-sel \#config .style.display = \grid
  reveal: (x, y) !->
    switch @cfg.b[x][y]
      | -1
        #
        # TODO: you failed
        #
        console.log 'you failed'
        #
        q-sel \#quit .innerText = \Quit
        #
      | 0
        #
        # TODO: reveal other block
        #
        console.log 'reveal 0 value block'
        #
      | _
        #
        # TODO: reveal a block with a number
        #
        console.log 'oups'
        #

# OUTPUTS ####################################

window.App = App