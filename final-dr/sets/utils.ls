function keep n, fn, rolls
  red = (acc, cv, idx) ->
    if acc.ids.length is 0 then acc.ids.push idx; acc.values.push cv
    else
      fnd = no
      for b, id in acc.values
        if fn cv, b
          acc.ids.splice id, 0, idx
          acc.values.splice id, 0, cv
          fnd = yes
          break
      if not fnd and acc.values.length < n
        acc.ids.push idx; acc.values.push cv
      else if acc.values.length > n
        acc.ids.pop!; acc.values.pop!
    acc
  rolls.reduce red, { ids: [], values: [] }

exports <<<
  bold: (ids, rolls) ->
    for r, id in rolls then if id in ids then "<b>#r</b>" else r
  kh: (n, rolls) -> keep n, ((a, b) -> a > b), rolls
  kl: (n, rolls) -> keep n, ((a, b) -> a < b), rolls