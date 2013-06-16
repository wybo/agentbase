# Our build process uses shelljs, which is npm installed globally.
# https://github.com/arturadib/shelljs
# To avoid having the module in our project, as described by
# https://npmjs.org/doc/folders.html#DESCRIPTION .. we use:
# export NODE_PATH="/usr/local/lib/node_modules"

fs     = require 'fs'
{exec} = require 'child_process'
shell  = require 'shelljs'

srcDir = "src/"
srcNames = "util shapes agentset agentsets model".split(" ")
srcPaths = ("#{srcDir}#{f}.coffee" for f in srcNames)
appPath = 'agentscript.coffee'

task 'all', 'Compile, minify, create docs', ->
  invoke 'build'
  invoke 'minify'
  invoke 'doc'
  invoke 'wc'
  
task 'build', 'Compile single application file from source files', ->
  invoke 'cat'
  console.log "Compiling #{appPath}"
  shell.exec "coffee --map --compile #{appPath}"
  
task 'cat', 'Concatenate source files', ->
  console.log "Concatenating source files -> #{appPath}"
  shell.cat(srcPaths).to(appPath)

task 'csup', 'Update coffee-script.js', ->
  url = "http://jashkenas.github.io/coffee-script/extras/coffee-script.js"
  shell.exec "curl #{url} -O", -> console.log shell.grep(/^ \* /, "coffee-script.js")

task 'doc', 'Create documentation from source files', ->
  tmpfiles = ("/tmp/#{i+1}-#{f}.coffee" for f,i in srcNames)
  shell.cp('-f', f, tmpfiles[i]) for f,i in srcPaths
  template = "/tmp/#{i+1}-template.coffee"
  shell.grep('-v', /^ *</, 'template.html').to(template)
  tmpfiles.push template
  shell.exec "docco #{tmpfiles.join(" ")} -o docs",-> # async ok, sync fails sometimes

task 'minify', 'Create minified version of coffeescript.js', ->
  console.log "uglify agentscript.js -> agentscript.min.js"
  shell.exec 'uglifyjs agentscript.js -c -m -o agentscript.min.js'
  
task 'watch', 'Watch for source file updates, invoke build', ->
  invoke 'build'
  console.log "Watching source directory"
  for path in srcPaths then do (path) ->
    fs.watchFile path, (curr, prev) ->
      if +curr.mtime isnt +prev.mtime
        console.log "#{path}: #{curr.mtime}"
        invoke 'build'

wcCode = (file) ->
  shell.grep('-v',/^ *[#/]|^ *$|^ *root|setRootVars/, file).split('\n').length
task 'wc', 'Count the lines of coffeescript & javascript', ->
  console.log "code: agentscript.coffee: #{wcCode('agentscript.coffee')}"
  console.log "code: agentscript.js: #{wcCode('agentscript.js')}"



task 'test', 'Testing 1,2,3...', ->
  console.log shell.cat(appPath).split('\n').length
  console.log shell.grep('-v',/^ *[#/]|^ *$/,appPath).split('\n').length




