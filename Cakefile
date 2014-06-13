# Our build process uses shelljs, docco, uglifyjs, and coffeescript,
# all of which can be installed locally by running `npm install`.

fs = require 'fs'
path = require 'path'
{exec} = require 'child_process'
shell = require 'shelljs'
readline = require 'readline'
# Note: try https://github.com/mgutz/execSync

node_modules = path.join(path.dirname(fs.realpathSync(__filename)), '/node_modules/.bin')
shell.env['PATH'] = node_modules + ":" + shell.env['PATH']

editori = shell.exec("git config --get core.editor", {silent:true}).output
prompt = (qstring, f) -> # prompt w/ question, respond with f(ans)
  rl = readline.createInterface {input:process.stdin, output:process.stdout}
  rl.question qstring, (ans) ->
    rl.close()
    f(ans)

srcDir = "src/"
extrasDir = "extras/"
toolsDir = 'tools/'
libDir = 'lib/'

TestCommand = "./node_modules/jasmine-node/bin/jasmine-node --coffee spec/"

firstFileNames = ['util.coffee', 'set.coffee']
FileNames = firstFileNames.concat(
  fs.readdirSync(srcDir).filter (file) -> file not in firstFileNames)
FilePaths = ("#{srcDir}#{file}" for file in FileNames)
MergedPath = "#{libDir}agentscript.coffee"

XNames = "data mouse fbui".split(" ")
XJSNames = "as.dat.gui data.tile".split(" ")
XPaths = ("#{extrasDir}#{f}.coffee" for f in XNames)
  .concat("#{extrasDir}#{f}.js" for f in XJSNames)
JSNames = XNames.concat(XJSNames, ["agentscript"])

task 'all', 'Compile coffee, minify js, create docs', ->
  invoke 'build'
  invoke 'minify'
  invoke 'wc'
  invoke 'doc'

compileFile = (path) ->
  console.log "Compiling #{path}"
  if (/.coffee$/.test(path))
  then compileCoffee(path)
  else compileJS(path)
compileCoffee = (path) ->
  coffeeName = path.replace /^.*\//, ''
  coffeeDir = path.replace /\/[^/]*$/, ''
  shell.exec """
    cd #{coffeeDir}
    coffee --map --compile --output ../#{libDir} #{coffeeName}
  """ , ->
compileJS = (path) ->
  shell.exec """
    cp #{path} #{libDir}
  """, ->
task 'build', 'Compile agentscript and libraries from source files', ->
  invoke 'build:agentscript'
  invoke 'build:extras'
task 'build:agentscript', 'Compile agentscript from source files', ->
  invoke 'cat'
  compileFile MergedPath
task 'build:extras', 'Compile all libraries from their source file', ->
  compileFile name for name in XPaths

task 'cat', 'Concatenate agentscript files', ->
  shell.cat(FilePaths).to(MergedPath)

task 'doc', 'Create documentation from source files', ->
  tmpfiles = ("/tmp/#{i + 1}-#{file}" for file, i in FileNames)
  template = "/tmp/#{i + 1}-template.coffee"
  cpfiles = ("cp #{f} #{tmpfiles[i]}" for f, i in FilePaths).join "; "
  tmpfiles.push template
  shell.exec """
    rm /tmp/*.coffee docs/*.html
    grep -v '^ *<' < models/template.html > #{template}
    #{cpfiles}
    docco #{tmpfiles.join(" ")} -o docs  &&
    docco #{XPaths.join(" ")} -o docs
  """, -> #{silent:true}, (code,output) -> console.log output
# task 'xdoc', 'Create documentation for addons', ->
#   shell.exec """
#     docco #{XPaths.join(" ")} -o docs
#   """, ->

task 'git:prep', 'master: cake all; git add/status', ->
  # call doc task from shell .. async problems otherwise
  shell.exec """
    git checkout master
    cake 'all'
    git add .
    git status
  """, ->
task 'git:commit', 'master: commit, push to github', ->
  shell.exec """
    git checkout master
    git commit
    git push origin master
  """, ->
task 'git:pages', 'gh-pages: merge master, push to github gh-page', ->
  console.log """
  This will checkout the gh-pages branchs, making your working
  directory completely changed, causing "watch" tasks and editors with
  project files open to potentially behave incorrectly.
  """
  prompt "OK to proceed!?! [y or CR / n or Ctl-C] ", (ans) ->
    if ans.match(/[yY]|^$/) # default is yes, CR OK
      shell.exec """
        git checkout gh-pages
        git merge master 
        git push origin gh-pages
        git checkout master
      """, ->
task 'git:diff', 'git diff the core and extras .coffee files', ->
  coffeeFiles = FilePaths.concat(XPaths).join(' ')
  diffFiles = "Cakefile README.md #{coffeeFiles} models sketches"
  exec "git diff #{diffFiles} | #{editor}"
task 'git:diffhead', 'git diff staged/head core, extras, models', ->
  coffeeFiles = FilePaths.concat(XPaths).join(' ')
  diffFiles = "Cakefile README.md #{coffeeFiles} models sketches"
  exec "git diff --staged #{diffFiles} | #{editor}"

task 'minify', 'Create minified version of coffeescript.js', ->
  console.log "uglify javascript files"
  for file in JSNames
    shell.exec "uglifyjs #{libDir}#{file}.js -c -m -o #{libDir}#{file}.min.js", ->
  
task 'update:cs', 'Update coffee-script.js', ->
  url = "http://jashkenas.github.io/coffee-script/extras/coffee-script.js"
  shell.exec "cd #{toolsDir}; curl #{url} -O", 
    -> console.log shell.grep(/^ \* /, "tools/coffee-script.js")

task 'watch', 'Watch for source file updates, invoke builds', ->
  invoke 'build:agentscript'
  console.log "Watching source directory"
  for path in FilePaths then do (path) ->
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
  shell.grep('-v', /^ *[#/]|^ *$|^ *root|setRootVars|^ *console/, file).split('\n').length
task 'wc', 'Count the lines of coffeescript & javascript', ->
  jsPath = MergedPath.replace("#{srcDir}","#{libDir}").replace('coffee','js')
  console.log "code: #{MergedPath}: #{wcCode(MergedPath)}"
  console.log "code: #{jsPath}: #{wcCode(jsPath)}"

prompt = (q,f) ->
  rl=readline.createInterface {input:process.stdin, output:process.stdout}
  rl.question q, (ans) ->
    rl.close()
    f(ans)
task 'test', 'Testing code', ->
  shell.exec TestCommand, async: true
