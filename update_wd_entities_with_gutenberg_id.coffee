#!/usr/bin/env coffee

wdk = require 'wikidata-sdk'
fs = require 'fs'
request = require 'request'
require 'colors'

sparqlPath = './wd_entity_with_gutenberg_id.rq'
resultPath = './wd_entity_with_gutenberg_id.json'

fs.readFile sparqlPath, {encoding: 'utf-8'}, (err, file)->
  if err?
    console.log 'err'.red, err
    return

  url = wdk.sparqlQuery file
  console.log 'url'.grey, url

  # streaming directly to the file system
  # as buffering with promises was producing an error:
  # "segmentation fault (core dumped)"
  write = fs.createWriteStream resultPath

  request url
  .pipe write
  .on 'close', -> console.log 'updated!'.green, resultPath
