expect = require 'expect.js'
halvalla = require '../lib/halvalla-react'

describe 'plugins', ->
  it 'are applied via use', ->
    expect(halvalla.use).to.be.a 'function'
