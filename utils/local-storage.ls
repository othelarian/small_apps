export LS =
  init: (prefix) !~> @prefix = prefix
  check: (key) ~>
    try
      localStorage.hasOwnProperty "#{@prefix}-#key"
    catch
      no
  clean: (key) !~> localStorage.removeItem "#{@prefix}-#key"
  get: (key) ~> localStorage.getItem "#{@prefix}-#key"
  save: (key, value) !~> localStorage.setItem "#{@prefix}-#key", value