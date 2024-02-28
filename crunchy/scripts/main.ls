# REQUIRES ###################################

require! {
  '../../utils/basics': { c-elt, q-sel }
  './dr': { DR }
  './river': { River }
}

# CORE #######################################

App =
  # objects #########
  dr: new DR
  river: new River
  # attributes ######
  stories: void
  # methods #########
  init: !->>
    for ft in q-sel('.font, .dice', yes) then ft.setAttribute \viewBox '0 0 24 24'
    r = await fetch \/crunchy/stories
    App.stories = await r.json!
    #
    # TODO: server will send a new format
    #
    story-select = q-sel \#story-select
    #
    #
    for story, idx in App.stories
      story-select.appendChild(c-elt \option, {value: idx}, story)
    q-sel \#welcome .style.display = \block
  select: !->
    #
    # TODO
    #
    v = q-sel \#story-select .value
    console.log v
    #
    q-sel \#story-title .innerText = App.stories[v]
    #

# OUTPUTS ####################################

window.App = App
