#!/bin/bash

cat template.html | sed '
  1,/text\/coffeescript/d
  /<\/script>/,$d
  s/^    //
' > template.coffee

files="\
  util.coffee \
  shapes.coffee \
  agentset.coffee \
  agentsets.coffee \
  model.coffee \
"
docco $files template.coffee -o docs

rm template.coffee