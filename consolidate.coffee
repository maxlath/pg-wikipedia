#!/usr/bin/env coffee

# a script to add data already exisiting in Wikidata
# to what pg-wikipedia produced to, later, avoid re-adding exiting data

_ = require 'lodash'
require 'colors'
fs = require 'fs'

localData = require './pg_wikipedia_with_titles.json'
localDataIndex = _.keyBy localData, "wikidata ID"

wdData = require './wd_entity_with_gutenberg_id.json'

wdData.results.bindings.map (el)->
  wdId = el.book.value.replace 'http://www.wikidata.org/entity/', ''
  label = el.bookLabel.value
  # console.log wdId, label
  if localDataIndex[wdId]?
    console.log 'existing'.green, wdId
    localDataIndex[wdId].existing = true
  else
    console.log 'missing'.yellow, wdId
    localDataIndex[wdId] =
      missing: true
      'Wikidata label': label
      'wikidata ID': wdId


consolidated = _.values localDataIndex
  .map (el)->
    if el['Project Gutenberg title'] is '?'
      el['Project Gutenberg title'] = null

    return el

json = JSON.stringify consolidated, null, 2
fs.writeFile './pg_wikipedia_with_titles_consolidated.json', json
