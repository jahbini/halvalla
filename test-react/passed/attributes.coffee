expect = require 'expect.js'
{a, br, div,render} = require '../lib/halvalla-react'

describe 'Attributes', ->

  describe 'with a hash', ->
    it 'renders the corresponding HTML attributes', ->
      template = ->
          a href: '/', title: 'Home'
      debugger
      expect(render template).to.equal '<a href="/" title="Home"></a>'

  describe 'data attribute', ->
    it 'expands attributes', ->
      template = -> br data: { name: 'Name', value: 'Value' }
      expect(render template).to.equal '<br data-name="Name" data-value="Value"/>'

  describe 'nested hyphenated attribute', ->
    it 'renders', ->
      template = ->
        div 'data-on-x': 'beep', ->
          div 'data-on-y': 'boop'
      expect(render template).to.equal '<div data-on-x="beep"><div data-on-y="boop"></div></div>'
