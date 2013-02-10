#!/bin/bash

files="\
  util.coffee \
  shapes.coffee \
  agentset.coffee \
  agentsets.coffee \
  model.coffee \
"

cat $files > agentscript.coffee

coffee -wj agentscript.js -c $files &