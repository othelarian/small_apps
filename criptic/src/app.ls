# UTILS ####################################################

q-sel = (e) -> document.querySelector e

fill-samples = !->
  cont = q-sel \#samples
  for snd, smp of dict
    g = document.createElement \div
      ..innerHTML = "<b>#snd :</b>&nbsp;#{smp.sample}"
    cont.appendChild g

parsing-txt = (txt) ->
  #
  # TODO
  #
  ctt = []
  #
  for wrd in txt.split(' ')
    #
    #
    void
    #
  #
  ctt
  #

toggle-cont = (container) !->
  q-sel "##{app.page}" .classList.add \hidden
  q-sel "\#btn-#{app.page}" .classList
    ..remove \active
    ..add \inactive
  q-sel "##{container}" .classList.remove \hidden
  q-sel "\#btn-#{container}" .classList
    ..remove \inactive
    ..add \active
  app.page = container

# DATA #####################################################

dict =
  a:
    sample: 'p<u>a</u>tte'
    path: [[]]
  b:
    sample: '<u>b</u>am<u>b</u>ou'
    path: [[]]
  ch:
    sample: '<u>ch</u>ant'
    path: [[]]
  p:
    sample: '<u>p</u>lo<u>p</u>'
    pth: [[]]

# APP ######################################################

app =
  # attributes
  ctx: void
  cvs: void
  page: \home
  # methods
  dl: !->
    a = document.createElement \a
      ..download = 'criptic.png'
      ..href = app.cvs.toDataURL!
    a.click!
  init: !->
    @in = q-sel '#txt-in'
    @cvs = q-sel '#txt-out'
    @ctx = @cvs.getContext \2d
    @ctx.fillStyle = \none
    @ctx.lineWidth = 3
    fill-samples!
    @update!
  show: (container) !-> if container isnt app.page then toggle-cont container
  update: !->
    #
    # TODO: get the text from the textarea, and convert it into the canvas
    #
    #App.ctx.fillStyle = Config.back
    #App.ctx.fillRect 0, 0, App.size, App.size
    #
    parsed = parsing-txt app.in.value
    #
    console.log parsed
    #
    pth = new Path2D!
      ..moveTo 10 10
      ..lineTo 40 60
    #
    app.ctx.stroke pth
    #
    #

# WINDOW EXPORT ############################################

window.app = app