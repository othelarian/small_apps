# UTILS ######################################

function q-sel s, a = no
  if a then document.querySelectorAll s
  else document.querySelector s

# CORE #######################################

App =
  select: !->
    seld = q-sel \#selector .value
    lk = "http://#{document.location.host}/crunchy/fiches/#seld"
    a = q-sel \#link
    a.innerText = lk
    a.setAttribute \href, lk
    q-sel \#frame .setAttribute \src, lk

# OUTPUTS ####################################

window.App = App
