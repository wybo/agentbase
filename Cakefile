fs     = require 'fs'
{exec} = require 'child_process'

appFiles = [
  'util.coffee'
  'shapes.coffee'
  'agentset.coffee'
  'agentsets.coffee'
  'model.coffee'
]
files="util.coffee
 shapes.coffee
 agentset.coffee
 agentsets.coffee
 model.coffee"

appFile = 'agentscript.coffee'

task 'build', 'Build single application file from source files', ->
  console.log "building: #{appFile} file"
  appContents = new Array(remaining = appFiles.length)
  for file, index in appFiles then do (file, index) ->
    fs.readFile file, 'utf8', (err, fileContents) ->
      throw err if err
      appContents[index] = fileContents
      process() if --remaining is 0
  process = ->
    fs.writeFile appFile, appContents.join('\n\n'), 'utf8', (err) ->
      throw err if err
      exec "echo #{appFile}; cat #{appFile}"
      # exec 'coffee --compile lib/app.coffee', (err, stdout, stderr) ->
      #   throw err if err
      #   console.log stdout + stderr
      #   fs.unlink 'lib/app.coffee', (err) ->
      #     throw err if err
      #     console.log 'Done.'

task 'cat', 'concatenate the app files', ->
  exec "cat #{files} > #{appFile}"