###
plugins for mitril test cases mocha
###

expect = require 'expect.js'
teacup = require '../lib/halvalla-mithril'

describe 'plugins', ->
  it 'are applied via use', ->
    expect(teacup.use).to.be.a 'function'
