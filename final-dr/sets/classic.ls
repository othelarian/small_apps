export class ClassicSet
  curr-advdis: 0
  advdis: (set) !->
    startv = App.tog-val 3, @curr-advdis
    tranf = [{cx: "#{startv}px"}, {cx: "#{App.tog-val 3, set}"}]
    App.toggle \#classic-advdis, tranf
    @curr-advdis = set
  roll: (v) !->
    if v is \s
      v = q-sel \#classic-special .value |> parseInt
      if isNaN v then alert 'Please enter a number'; return
      else if v < 1
        alert 'Please select a positive value AND ABOVE 2'; return
    r =
      if @curr-advdis is 0 then "d#v: <b>#{App.rand2 v}</b>"
      else
        r1 = App.rand2 v
        r2 = App.rand2 v
        [chk, aord] =
          if @curr-advdis is -1 then [r1 <= r2, \dis] else [r1 >= r2, \adv]
        br =
          if chk then r1 = "<b>#{r1}</b>"; r1
          else r2 = "<b>#{r2}</b>"; r2
        "d#v with #aord: [#{r1}, #{r2}] => #br"
    App.roll r
