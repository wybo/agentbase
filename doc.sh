#!/bin/bash


cat template.html | sed '
  1,/text\/coffeescript/d
  /<\/script>/,$d
  s/^    //
' > /tmp/6-template.coffee

files="\
  util.coffee \
  shapes.coffee \
  agentset.coffee \
  agentsets.coffee \
  model.coffee \
"
i=1
files1=""
for file in $files; do
  name="/tmp/$i-$file"
  cp $file $name
  files1="$files1 $name"
  ((i++))
done

docco $files1 /tmp/6-template.coffee -o docs

# rm template.coffee