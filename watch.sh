#!/bin/bash

files="util.coffee shapes.coffee agentset.coffee agentsets.coffee model.coffee"
coffee --watch --map --join agentscript.coffee --compile $files &

exit

coffee --map --join agentscript.js --compile $files 
{
  "version": 3,
  "file": "agentscript.js",
  "sourceRoot": "",
  "sources": [
    "agentscript.js"
  ],
  "names": [],
  "mappings": ....
coffee --map --join agentscript.coffee --compile $files 
{
  "version": 3,
  "file": "agentscript.js",
  "sourceRoot": "",
  "sources": [
    "agentscript.coffee"
  ],
  "names": [],
  "mappings": ....

coffee --watch --map --join agentscript.js --compile $files &


files="util.coffee shapes.coffee agentset.coffee agentsets.coffee model.coffee"
coffee  -cwlj agentscript.coffee -c $files

FILES="foo.coffee bar.coffee"
coffee  -cwlj baz.coffee -c $FILES



# coffee -mj agentscript.js -c $files