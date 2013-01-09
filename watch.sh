#!/bin/bash

files="\
  util.coffee \
  shapes.coffee \
  agentset.coffee \
  agentsets.coffee \
  model.coffee \
"


coffee -wj agentscript.js -c $files &