expect = require 'expect.js'
teacup = require '../src/halvalla'

describe 'plugins', ->
  it 'are applied via use', ->
    expect(teacup.use).to.be.a 'function'
