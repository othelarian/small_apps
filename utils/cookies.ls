export Cookie =
  init: (prefix) !~> @prefix = prefix
  check: ~>
    cookies = {}
    for elt in document.cookie.split '; '
      t = elt.split \=; cookies[t[0]] = t[1]
    cookies
  set: (key, value) !~> document.cookie = "#{@prefix}-#key=#value"
