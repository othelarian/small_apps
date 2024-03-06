# REQUIRES ###################################

require! {
  '../../utils/basics': { q-sel }
  './utils'
}

# INTERNALS ##################################

toggle-title = !->
  utils.toggle '#cs-title span'
  utils.toggle '#cs-title button'
  utils.toggle '#cs-title input'

# EXPORTED ###################################

export class Editor
  data: void
  store: void
  edit: (k, opts = '') !->
    switch k
      | \title
        if opts is \cancel
          #
          # TODO
          #
          toggle-title!
          q-sel '#cs-title input' .value = @data.title
          #
        else if @store.title
          inp = q-sel '#cs-title input'
          if inp.value.length is 0
            alert 'Please put at least 1 letter in the title!'
          else
            @data.title = inp.value
            @store.title = no
            toggle-title!
            App.update!
        else
          toggle-title!
          @store.title = yes
    #
    #
    # TODO
    #
  init:(@data, @store) !-> void