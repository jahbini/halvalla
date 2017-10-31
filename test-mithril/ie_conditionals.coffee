###
Test Internet Exploder conditional inclusion -- mithril mocha
###
expect = require 'expect.js'
{render, ie, link} = require '../lib/halvalla-mithril'

describe 'IE conditionals', ->
  it 'renders conditional comments', ->
    template = -> 
      ie 'gte IE8', -> 
        link href: 'ie.css', rel: 'stylesheet'
    expect(render template).to.equal '<!--[if gte IE8]><link href="ie.css" rel="stylesheet" /><![endif]-->'
