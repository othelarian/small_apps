require! express

export serve = (cb) !->
  console.log 'launching dev server...'
  app = express!
  app.use express.static \./dist
  app.listen 5001
  console.log 'dev server running on port 5001'