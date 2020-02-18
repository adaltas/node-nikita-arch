
config = require './config'
run = require './run'

(->
  try
    await config()
    await run()
  catch e
    process.stdout.write e.stack
)()
