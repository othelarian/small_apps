``
import { qSel, Quine } from '../../utils/esm.ls'
import { Editor } from './editor.ls'
``

# INITIATORS #################################

saver = new Quine
editor = new Editor

# STORE & DATA ###############################

Data = {}

Store =
  title: no
  server: no
  updated: yes

# CORE #######################################

App =
  activate: (evt) !->
    nk = not evt.altKey and not evt.shiftKey and not evt.metaKey
    if evt.ctrlKey and nk and evt.key is \m
      removeEventListener \keydown, App.activate
      for elt in q-sel(\.deactive, yes) then elt.classList.toggle \deactive
  data: -> Data
  download: (j = no) !->
    ext = if j then \json else \html
    saver.download (App.data!), "CS_#{App.fmt-date!}.#ext", j
  edit: (k, o) !-> editor.edit k, o
  fill: !->
    #
    # TODO: fill the interface with the data
    #
    q-sel '#cs-title span' .innerText = Data.title
    q-sel '#cs-title input' .value = Data.title
    #
    #
    #
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
    App.fill!
    editor.init Data, Store
  json: !-> App.download yes
  load: (data) !->
    data-keys = Object.keys Data
    try
      rep = JSON.parse data
      rep-keys = Object.keys rep
      rest = rep-keys .filter (d) -> d not in data-keys
      if rest.length isnt 0
        alert 'The JSON contains keys that does not match'
        console.log "rest: [#{rest.toString!}]"
      else
        rest = data-keys .filter (d) -> d not in data-keys
        if rest.length isnt 0
          alert 'The JSON does not contains all the required keys'
          console.log "rest: [#{rest.toString!}]"
        else
          unless (rep-keys.every (d) -> (typeof! Data[d]) is (typeof! rep[d]))
            alert 'The JSON does not contains valid data'
          else
            Data <<<< rep
            App.fill!
    catch e
      alert 'Something went wrong with the import (look at the log)'
      console.error e
  store: !-> Store
  sync: !->>
    a = await saver.sync <| App.data!
    unless a
      alert 'Oups! Something went wrong when trying to sync with the server'
    else
      q-sel \#cs-sync .setAttribute \disabled ''
      Store.updated = no
  update: !->
    if Store.server
      Store.updated = yes
      q-sel \#cs-sync .removeAttribute \disabled

# OUTPUTS ####################################

window.App = App