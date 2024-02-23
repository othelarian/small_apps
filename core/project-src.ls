lsSrc = '''
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

# CORE #######################################

App =
  init: !->
    #
    #
    console.log 'init app'
    #

# OUTPUTS ####################################

window.App = App
'''

sassSrc = '''
// here the sass
'''

pugSrc = (name) ->
  """
  doctype html
  html
    head(lang='en')
      title #name
      meta(charset='utf-8')
      meta(name='viewport', content='width=device-width,initial-scale=1')
      link(rel='stylesheet', href='style.css')
      script(type='text/javascript', src='app.js')
    body(onload='App.init()')
      //
      //
  """

export names =
  ls: 'app.ls'
  pug: 'index.pug'
  sass: 'style.sass'

export printout = (name, path) ->
  """
    {
      active: yes
      name: '#name'
      path: '#path'
      src: code.default
    }
  """

export srcs = (selected, name) ->
  switch selected
    | \ls   => lsSrc
    | \pug  => pugSrc name
    | \sass => sassSrc
