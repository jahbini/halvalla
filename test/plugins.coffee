expect = require 'expect.js'
chalice = require '../src/chalice'

describe 'plugins', ->
  it 'are applied via use', ->
    expect(chalice.use).to.be.a 'function'
