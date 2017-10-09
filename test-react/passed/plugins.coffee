expect = require 'expect.js'
halvalla = require '../src/halvalla-react'

describe 'plugins', ->
  it 'are applied via use', ->
    expect(halvalla.use).to.be.a 'function'
