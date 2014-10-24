# AgentBase is Free Software, available under GPL v3 or any later version.
# Original AgentScript code @ 2013, 2014 Owen Densmore and RedfishGroup LLC.
# AgentBase (c) 2014, Wybo Wiersma.

gulp = require 'gulp'
concat = require 'gulp-concat'
coffee = require 'gulp-coffee'
docco = require 'gulp-docco'
rename = require 'gulp-rename'
shell = require 'gulp-shell'
sourcemaps = require 'gulp-sourcemaps'
uglify = require 'gulp-uglify'
lazypipe = require 'lazypipe'
taskList = require 'gulp-task-listing'
fs = require 'fs'
path = require 'path'

readFilePaths = (sourceDir, firstFiles) ->
  fileNames = firstFiles.concat(fs.readdirSync(sourceDir)
  .filter (file) -> file not in firstFiles)
  fileNames.map (name) ->
    sourceDir + name

FilePaths = readFilePaths 'src/',
  'util util_array array util_shapes set breed_set'
    .split(' ').map (n) -> n + '.coffee'

SpecFilePaths = readFilePaths 'spec/', ['shared.coffee']
 
# Create "macro" pipes.  Note 'pipe(name,args)' not 'pipe(name(args))'
# https://github.com/OverZealous/lazypipe
jsTasks = lazypipe() # write .js and .min.js into lib/
  .pipe gulp.dest, 'lib/'
  .pipe rename, {suffix: '.min'}
  .pipe uglify
  .pipe gulp.dest, 'lib/'

coffeeTasks = lazypipe()
  .pipe gulp.dest, 'lib/' # .coffee files used by specs
#  .pipe sourcemaps.init # Currently not working, wait for sourcemaps update
  .pipe coffee
#  .pipe sourcemaps.write, '.'
  .pipe jsTasks

gulp.task 'all', ['build', 'docs']

# Build tasks:
gulp.task 'build-agentbase', ->
  return gulp.src(FilePaths)
  .pipe concat('agentbase.coffee')
  .pipe coffeeTasks()

gulp.task 'build-specs', ->
  return gulp.src(SpecFilePaths)
  .pipe concat('spec.coffee')
  .pipe coffeeTasks()

gulp.task 'build', ['build-agentbase', 'build-specs']

# Watch tasks
# TODO make build as well
gulp.task 'watch', ['build'], ->
  gulp.watch 'src/*.coffee',
    ['build-agentbase']

  gulp.watch 'spec/*.coffee',
    ['build-specs']

gulp.task 'docs', ->
  return gulp.src('')
  .pipe shell("./node_modules/codo/bin/codo src")

# Default: list out tasks
gulp.task 'default', taskList
