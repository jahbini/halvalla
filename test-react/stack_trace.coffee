expect = require 'expect.js'
{div, p,render} = require '../src/halvalla-react'
#{render} = require './helpers'

describe 'stack trace', ->
  it 'should contain crel names', ->
    template = ->
      div ->
        p ->
          throw new Error()
    try
      render template
    catch error
      expect(error.stack).to.contain 'div'
      expect(error.stack).to.contain 'p'
