# Our build process uses shelljs, which is npm installed globally.
# https://github.com/arturadib/shelljs
# To avoid having the module in our project, as described by
# https://npmjs.org/doc/folders.html#DESCRIPTION .. we use:
# export NODE_PATH="/usr/local/lib/node_modules"

fs     = require 'fs'
{exec} = require 'child_process'
shell  = require 'shelljs'

srcDir = "src/"
extrasDir = "extras/"
toolsPath = 'tools/'
libPath = 'lib/'
ASNames = "util shapes agentset agentsets model".split(" ")
ASPaths = ("#{srcDir}#{f}.coffee" for f in ASNames)
ASPath = "#{srcDir}agentscript.coffee"
XNames = "data".split(" ")
XPaths = ("#{extrasDir}#{f}.coffee" for f in XNames)
JSNames = XNames.concat ["agentscript"]

task 'all', 'Compile, minify, create docs', ->
  invoke 'build'
  invoke 'doc'
  #invoke 'map:off'
  console.log "checking models for map use" # until maps work correctly
  shell.exec "grep '\\.\\./agentscript.js' models/*.html"
  invoke 'wc'
  invoke 'minify'
  
compileFile = (path) -> # Until map works: compile to top level dir then cp js/map to lib
  console.log "Compiling #{path}"
  coffeeName = path.replace /^.*\//, ''
  baseName = coffeeName.replace /.coffee/, ''
  shell.exec """
    cp #{path} .
    coffee --map --compile #{coffeeName}
    cp #{baseName}.js #{baseName}.map #{libPath}
  """, ->

task 'build', 'Compile agentscript and libraries from source files', ->
  invoke 'build:agentscript'
  invoke 'build:extras'

task 'build:agentscript', 'Compile agentscript from source files', ->
  invoke 'cat'
  compileFile ASPath

task 'build:extras', 'Compile all libraries from their source file', ->
  compileFile name for name in XPaths

task 'cat', 'Concatenate agentscript files', ->
  # console.log "Concatenating source files -> #{ASPath}"
  shell.cat(ASPaths).to(ASPath)

task 'doc', 'Create documentation from source files', ->
  tmpfiles = ("/tmp/#{i+1}-#{f}.coffee" for f,i in ASNames)
  template = "/tmp/#{i+1}-template.coffee"
  cpfiles = ("cp #{f} #{tmpfiles[i]}" for f,i in ASPaths).join "; "
  tmpfiles.push template
  shell.exec """
    rm /tmp/*.coffee docs/*.html
    grep -v '^ *<' < models/template.html > #{template}
    #{cpfiles}
    docco #{tmpfiles.join(" ")} -o docs
  """, ->

task 'map:off', 'Map disable: Remove top level lib/src/extras files', ->
  coffeeFiles = (f.replace(/^[^ ]*\//,'') for f in XPaths.concat(ASPath)).join(" ")
  libFiles = shell.ls("lib/*").join(" ").
    replace(/lib\/[^ ]*min\.js/g,'').replace(/lib\//g,'')
  shell.exec "rm #{coffeeFiles} #{libFiles}", ->  
task 'map:on', 'Map enable: Copy lib/src/extras to top level', ->
  coffeeFiles = XPaths.concat(ASPath).join " "
  libFiles = shell.ls("lib/*").join(" ").replace(/lib\/[^ ]*min\.js/g,'')
  shell.exec "cp #{coffeeFiles} .;cp #{libFiles} .", ->

task 'minify', 'Create minified version of coffeescript.js', ->
  console.log "uglify javascript files"
  for file in JSNames
    shell.exec "uglifyjs #{libPath}#{file}.js -c -m -o #{libPath}#{file}.min.js", ->
  
task 'update:cs', 'Update coffee-script.js', ->
  url = "http://jashkenas.github.io/coffee-script/extras/coffee-script.js"
  shell.exec "cd tools; curl #{url} -O", 
    -> console.log shell.grep(/^ \* /, "tools/coffee-script.js")

task 'watch', 'Watch for source file updates, invoke builds', ->
  invoke 'build:agentscript'
  console.log "Watching source directory"
  for path in ASPaths then do (path) ->
    fs.watchFile path, (curr, prev) ->
      if +curr.mtime isnt +prev.mtime
        console.log "#{path}: #{curr.mtime}"
        invoke 'build:as'
  invoke 'build:extras'
  for path in XPaths then do (path) ->
    fs.watchFile path, (curr, prev) ->
      if +curr.mtime isnt +prev.mtime
        console.log "#{path}: #{curr.mtime}"
        compileFile path
wcCode = (file) ->
  shell.grep('-v',/^ *[#/]|^ *$|^ *root|setRootVars/, file).split('\n').length
task 'wc', 'Count the lines of coffeescript & javascript', ->
  console.log "code: agentscript.coffee: #{wcCode('agentscript.coffee')}"
  console.log "code: agentscript.js: #{wcCode('agentscript.js')}"


  
task 'test', 'Testing 1,2,3...', ->
  coffeeFiles = XPaths.concat(ASPath).join " "
  libFiles = shell.ls("lib/*").join(" ").replace /lib\/[^ ]*min\.js/g,''

  # coffeeFiles = (p.replace(/^.*\//, '') for p in coffeePaths)
  # 
  # libFiles = (p.replace /^.*\//, 'lib/' for p in coffeePaths)
  # libFiles = shell.ls("lib/*").join(" ").replace /lib\/[^ ]*min\.js/g,''
  # libFiles = []
  # for s in ["js", "map"]
  #   for f in coffeeFiles
  #     libFiles.push(f.replace(/coffee/,s).replace(/^/,"lib/"))
  # libFiles =
  #   for s in ["js", "map"]
  #     for f in coffeeFiles
  #       f.replace(/coffee/,s).replace(/^/,"lib/")
        
  # libFiles = coffeePaths.replace /extras/g, 'lib'
  
  shell.exec """
    cp #{coffeeFiles} .
    cp #{libFiles} .
  """, ->
  



# task 'doc', 'Create documentation from source files', ->
#   tmpfiles = ("/tmp/#{i+1}-#{f}.coffee" for f,i in ASNames)
#   template = "/tmp/#{i+1}-template.coffee"
#   shell.rm('docs/*.html', '/tmp/*.coffee')
#   shell.cp('-f', f, tmpfiles[i]) for f,i in ASPaths
#   shell.grep('-v', /^ *</, 'models/template.html').to(template)
#   tmpfiles.push template
#   shell.exec "docco #{tmpfiles.join(" ")} -o docs",-> # async ok, sync fails sometimes

# shell.exec([
#   "cp #{path} ."
#   "coffee --map --compile #{coffeeName}"
#   "cp #{baseName}.* #{libPath}"
# ].join(' && '))
