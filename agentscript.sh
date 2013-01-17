#!/bin/bash

files="\
  util.coffee \
  shapes.coffee \
  agentset.coffee \
  agentsets.coffee \
  model.coffee \
"

echo "cat .coffee files to agentscript.coffee"
cat $files > agentscript.coffee
echo "uglify agentscript.js"
uglifyjs agentscript.js -c -m > agentscript.min.js
#echo "zip agentscript/"
#cd ..
#zip -r agentscript.zip agentscript
