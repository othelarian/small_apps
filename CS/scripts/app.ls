# REQUIRES ###################################

require! {
  '../../utils/basics': { c-elt, q-sel }
  '../../utils/quine': { Quine }
}

# INITIATORS #################################

saver = new Quine

# STORE & DATA ###############################

Data = {}

Store =
  server: no

# CORE #######################################

App =
  activate: (evt) !->
    nk = not evt.altKey and not evt.shiftKey and not evt.metaKey
    if evt.ctrlKey and nk and evt.key is \m
      removeEventListener \keydown, App.activate
      for elt in q-sel(\.deactive, yes) then elt.classList.toggle \deactive
  data: ->
    #
    # TODO: exporting some data
    #
    Data
    #
  download: (j = no) !->
    ext = if j then \json else \html
    saver.download (App.data!), "CS_#{App.fmt-date!}.#ext", j
  fmt-date: ->
    two-digit = (v) -> a = v.toString!; if a.length is 1 then "0#a" else a
    date = new Date!
    year = date.getFullYear!toString!substring 2
    month = date.getMonth! |> (+ 1) |> two-digit
    day = date.getDate! |> two-digit
    hours = date.getHours! |> two-digit
    mins = date.getMinutes! |> two-digit
    "#{year}-#{month}-#{day}_#{hours}-#{mins}"
  import: !-> saver.load App.load
  init: !->>
    for elt in q-sel(\.font, yes) then elt.setAttribute \viewBox '0 0 24 24'
    Data <<<< saver.init CSHtml
    Store.server = await saver.detect!
    if Store.server then q-sel \#cs-sync .style.display = ''
    addEventListener \keydown, App.activate
  json: !-> App.download yes
  load: (data) !->
    #
    # TODO
    #
    data-keys = Object.keys Data
    #
    try
      rep = JSON.parse data
      rep-keys = Object.keys rep
      rest = Object.keys rep-keys .filter (d) -> d not in data-keys
      #
      console.log rep-keys
      console.log rest
      #
      if rest.length isnt 0
        alert 'The JSON contains keys that does not match'
        console.log "rest: #{rest.toString!}"
      else
        #
        d
        #
        console.log 'plop'
        #
      #
      #
    catch e
      alert 'Something went wrong with the import (look at the log)'
      console.error e
  sync: !->>
    #
    # TODO: doing something with the sync return
    #
    a = await saver.sync <| App.data!
    console.log a

# OUTPUTS ####################################

window.App = App