# UTILS ######################################

function q-sel s, a = no
  if a then document.querySelectorAll s
  else document.querySelector s

# CORE #######################################

App =
  init: !->
    colors = q-sel '#colors' .textContent |> JSON.parse
    stl = document.body.style
    for key in Object.keys colors
      stl.setProperty "--#{key}-col", colors[key]

# OUTPUTS ####################################

window.App = App
