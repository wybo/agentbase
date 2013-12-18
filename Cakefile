# Our build process uses shelljs, which is npm installed globally.
# https://github.com/arturadib/shelljs
# To avoid having the module in our project, as described by
# https://npmjs.org/doc/folders.html#DESCRIPTION .. we use:
# export NODE_PATH="/usr/local/lib/node_modules"

fs     = require 'fs'
{exec} = require 'child_process'
shell  = require 'shelljs'

editor= shell.exec("git config --get core.editor",{silent:true}).output

srcDir = "src/"
extrasDir = "extras/"
toolsDir = 'tools/'
libDir = 'lib/'
# modelsDir = 'models/'
ASNames = "util shapes agentset agentsets model".split(" ")
ASPaths = ("#{srcDir}#{f}.coffee" for f in ASNames)
ASPath = "#{srcDir}agentscript.coffee"
XNames = "data mouse fbui".split(" ")
XPaths = ("#{extrasDir}#{f}.coffee" for f in XNames)
JSNames = XNames.concat ["agentscript"]

task 'all', 'Compile, minify, create docs', ->
  invoke 'build'
  invoke 'minify'
  invoke 'wc'
  invoke 'doc'

compileFile = (path) ->
  console.log "Compiling #{path}"
  coffeeName = path.replace /^.*\//, ''
  coffeeDir = path.replace /\/[^/]*$/, ''
  shell.exec """
    cd #{coffeeDir}
    coffee --map --compile --output ../#{libDir} #{coffeeName}
  """ , ->
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
    docco #{XPaths.join(" ")} -o docs
  """, -> #{silent:true}, (code,output) -> console.log output
# task 'xdoc', 'Create documentation for addons', ->
#   shell.exec """
#     docco #{XPaths.join(" ")} -o docs
#   """, ->

task 'git:prep', 'cake all; git add/status', ->
  # Looks like I can't cake all w/o async problems
  # invoke 'all'
  # shell.exec """
  #   git add .
  #   git status
  # """ #, (code,output)->console.log output
  shell.exec "git add ."
  # sometimes the git status does not appear, use callback instead
  shell.exec "git status", {silent:true}, (code,output)->console.log output


task 'git:diff', 'git diff the core and extras .coffee files', ->
  coffeeFiles = ASPaths.concat(XPaths).join(' ')
  exec "git diff #{coffeeFiles} | #{editor}"

task 'git:diffmodels', 'git diff the sample models', ->
  exec "git diff models sketches | #{editor}"
  # exec "git diff #{modelsDir}*html | #{editor}"

task 'minify', 'Create minified version of coffeescript.js', ->
  console.log "uglify javascript files"
  for file in JSNames
    console.log file
    shell.exec "uglifyjs #{libDir}#{file}.js -c -m -o #{libDir}#{file}.min.js", ->
  
task 'update:cs', 'Update coffee-script.js', ->
  url = "http://jashkenas.github.io/coffee-script/extras/coffee-script.js"
  shell.exec "cd #{toolsDir}; curl #{url} -O", 
    -> console.log shell.grep(/^ \* /, "tools/coffee-script.js")

task 'watch', 'Watch for source file updates, invoke builds', ->
  invoke 'build:agentscript'
  console.log "Watching source directory"
  for path in ASPaths then do (path) ->
    fs.watchFile path, (curr, prev) ->
      if +curr.mtime isnt +prev.mtime
        console.log "#{path}: #{curr.mtime}"
        invoke 'build:agentscript'
  invoke 'build:extras'
  for path in XPaths then do (path) ->
    fs.watchFile path, (curr, prev) ->
      if +curr.mtime isnt +prev.mtime
        console.log "#{path}: #{curr.mtime}"
        compileFile path

wcCode = (file) ->
  shell.grep('-v',/^ *[#/]|^ *$|^ *root|setRootVars|^ *console/, file).split('\n').length
task 'wc', 'Count the lines of coffeescript & javascript', ->
  jsPath = ASPath.replace("#{srcDir}","#{libDir}").replace('coffee','js')
  console.log "code: #{ASPath}: #{wcCode(ASPath)}"
  console.log "code: #{jsPath}: #{wcCode(jsPath)}"


  
task 'test', 'Testing 1,2,3...', ->
  # shell.exec "git add ."
  # shell.exec("git status").output
  shell.exec("git add . && git status", (code,output)->console.log output)

  # coffeeFiles = XPaths.concat(ASPath).join " "
  # libFiles = shell.ls("lib/*").join(" ").replace /lib\/[^ ]*min\.js/g,''

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
  
  # shell.exec """
  #   cp #{coffeeFiles} .
  #   cp #{libFiles} .
  # """, ->

  # coffeeFiles = ASPaths.concat(XPaths).join(' ')
  # exec """
  #   git diff #{coffeeFiles} | #{editor}
  # """
  
  



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
#   "cp #{baseName}.* #{libDir}"
# ].join(' && '))
