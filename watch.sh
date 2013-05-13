#!/bin/bash

files="\
  util.coffee \
  shapes.coffee \
  agentset.coffee \
  agentsets.coffee \
  model.coffee \
"

# cat $files > agentscript.coffee

# coffee --watch --map --join agentscript.js --compile $files &
coffee --watch --join agentscript.js --compile $files &

# coffee -mj agentscript.js -c $files