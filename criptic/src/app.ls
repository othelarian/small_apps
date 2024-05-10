# UTILS ####################################################

q-sel = (e) -> document.querySelector e

# APP ######################################################

app =
  # attributes
  cvs: void
  page: \home
  # methods
  dl: !->
    #
    # TODO: download the result of the text
    #
    console.log 'trying to dl'
    #
  init: !->
    #
    # TODO: init the canvas
    #
    app.cvs = q-sel '#txt-out'
    #
    #
    #
  show: (container) !-> if container isnt app.page
    q-sel "##{app.page}" .classList.add \hidden
    q-sel "\#btn-#{app.page}" .classList
      ..remove \active
      ..add \inactive
    q-sel "##{container}" .classList.remove \hidden
    q-sel "\#btn-#{container}" .classList
      ..remove \inactive
      ..add \active
    app.page = container
  update: !->
    #
    # TODO: get the text from the textarea, and convert it into the canvas
    #
    v = q-sel '#txt-in'
    #
    console.log v
    #
    void
    #

# WINDOW EXPORT ############################################

window.app = app