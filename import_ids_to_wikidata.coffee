#!/usr/bin/env coffee

# a script to create claims on Wikidata entities
# with the P2034 (gutenberg ebook id) property
# by posting to a local Wikidata Agent https://github.com/maxlath/wikidata-agent

data = require './pg_wikipedia_with_titles_consolidated.json'
breq = require 'bluereq'
require 'colors'
wdAgentHost = 'http://localhost:4115'

addOne = ->
  el = data.pop()

  gutId = el["Project Gutenberg ID"]
  console.log 'gutId', gutId
  unless typeof gutId is 'number' then gutId is null

  wdId = el["wikidata ID"]
  console.log 'wdId', wdId
  unless /^Q[0-9]+$/.test wdId then wdId is null

  # pass to the next if already existing
  if el.existing
    console.log 'existing: passed'.grey, el.wdId, gutId
    addOne()
    return

  if gutId? and wdId?
    post wdId, 'P2034', gutId
    setTimeout addOne, 1000
  else
    console.log 'passed'.grey, wdId, gutId
    addOne()


# posting it to a local instance of wikidata-agent
# http://github.com/maxlath/wikidata-agent
post = (wdId, wdProp, gutId)->
  breq.post "#{wdAgentHost}/edit",
    entity: wdId
    property: wdProp
    value: gutId

ping = -> breq.get "#{wdAgentHost}/ping"

ping()
.then addOne
.catch (err)->
  console.log """
    Wikidata Agent (https://github.com/maxlath/wikidata-agent) couldn't be reached.
    It is expected to run on localhost:4115.
    """.yellow
