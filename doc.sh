#!/bin/bash

files="\
  util.coffee \
  shapes.coffee \
  agentset.coffee \
  agentsets.coffee \
  model.coffee \
"
docco $files -o docs