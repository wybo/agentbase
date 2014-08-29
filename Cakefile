# Our build process uses shelljs, docco, uglifyjs, and coffeescript,
# all of which can be installed locally by running `npm install`.

fs = require 'fs'
path = require 'path'
{exec} = require 'child_process'
shell = require 'shelljs'
readline = require 'readline'
optparse = require 'optparse'
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
specDir = "spec/"
extrasDir = "extras/"
toolsDir = 'tools/'
libDir = 'lib/'

firstFileNames = ['util.coffee', 'util_array.coffee', 'array.coffee',
  'util_shapes.coffee', 'set.coffee', 'breed_set.coffee']

FileNames = firstFileNames.concat(fs.readdirSync(srcDir)
  .filter (file) -> file not in firstFileNames)
FilePaths = ("#{srcDir}#{file}" for file in FileNames)
MergedPath = "#{libDir}agentscript.coffee"

specCopiedFilename = 'shared.spec.coffee'

SpecCopyPaths = ["#{specDir}#{specCopiedFilename}",
  "#{libDir}#{specCopiedFilename}"]
SpecFileNames = fs.readdirSync(specDir)
  .filter (file) -> file isnt specCopiedFilename
SpecFilePaths = ("#{specDir}#{file}" for file in SpecFileNames)
SpecMergedPath = "#{libDir}spec.coffee"

ExtrasNames = "data mouse fbui".split(" ")
ExtrasJSNames = "as.dat.gui data.tile".split(" ")
ExtrasFilePaths = ("#{extrasDir}#{f}.coffee" for f in ExtrasNames)
  .concat("#{extrasDir}#{f}.js" for f in ExtrasJSNames)
JSNames = ExtrasNames.concat(ExtrasJSNames, ["agentscript"])

task 'all', 'Compile coffee, minify js, create docs', ->
  invoke 'build'
  invoke 'minify'
  invoke 'wc'
  invoke 'doc'

compileFile = (path) ->
  console.log "Compiling #{path}"
  if (/.coffee$/.test(path))
    compileCoffee(path)
  else
    compileJS(path)

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
  invoke 'merge:agentscript'
  compileFile MergedPath

task 'build:spec', 'Compile spec from source files', ->
  invoke 'merge:spec'
  compileFile SpecMergedPath
  compileFile SpecCopyPaths[1]

task 'build:extras', 'Compile all libraries from their source file', ->
  compileFile name for name in ExtrasFilePaths

task 'merge:agentscript', 'Concatenate agentscript files', ->
  console.log "Merging #{MergedPath}"
  shell.cat(FilePaths).to(MergedPath)

task 'merge:spec', 'Concatenate spec files', ->
  console.log "Merging #{SpecMergedPath}"
  shell.cat(SpecFilePaths).to(SpecMergedPath)
  console.log "Copying #{SpecCopyPaths[1]}"
  shell.cp('-f', SpecCopyPaths...)

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
    docco #{ExtrasFilePaths.join(" ")} -o docs
  """, -> #{silent:true}, (code, output) -> console.log output

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
  coffeeFiles = FilePaths.concat(ExtrasFilePaths).join(' ')
  diffFiles = "Cakefile README.md #{coffeeFiles} models sketches"
  exec "git diff #{diffFiles} | #{editor}"

task 'git:diffhead', 'git diff staged/head core, extras, models', ->
  coffeeFiles = FilePaths.concat(ExtrasFilePaths).join(' ')
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

watchPaths = (paths, callTask) ->
  invoke callTask

  for path in paths then do (path) ->
    fs.watchFile path, (curr, prev) ->
      if +curr.mtime isnt +prev.mtime
        console.log "#{path}: #{curr.mtime}"
        invoke callTask

task 'watch', 'Watch for source file updates, invoke builds', ->
  console.log "Watching source directory"

  watchPaths(FilePaths, 'build:agentscript')
  watchPaths(SpecFilePaths, 'build:spec')
  watchPaths([SpecCopyPaths[0]], 'build:spec')
  watchPaths(ExtrasFilePaths, 'build:extras')

wcCode = (file) ->
  shell.grep('-v', /^ *[#/]|^ *$|^ *root|setRootVars|^ *console/, file).split('\n').length

task 'wc', 'Count the lines of coffeescript & javascript', ->
  jsPath = MergedPath.replace("#{srcDir}", "#{libDir}").replace('coffee', 'js')
  console.log "code: #{MergedPath}: #{wcCode(MergedPath)}"
  console.log "code: #{jsPath}: #{wcCode(jsPath)}"

prompt = (q, f) ->
  rl = readline.createInterface {input: process.stdin, output: process.stdout}
  rl.question q, (ans) ->
    rl.close()
    f(ans)

option '-f', '--file [DIR]', 'Path to test file or test file name'
task 'test', 'Testing code', (options) ->
  file = 'spec/'
  if options.file
    name = options.file.replace /spec\//, ''
    name = name.replace /\.spec.coffee/, ''
    file += name + '.spec.coffee'

  shell.exec "./node_modules/jasmine-node/bin/jasmine-node --coffee " +
    "--verbose --captureExceptions " + file, async: true
