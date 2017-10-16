expect = require 'expect.js'
{div, img,render} = require '../src/halvalla-react'
#{render} = require './helpers'

describe 'CSS Selectors', ->
  describe 'id selector', ->
    it 'sets the id attribute', ->
      template = -> div '#myid', 'foo'
      expect(render template).to.equal '<div id="myid">foo</div>'

    it 'must be greater than length 1', ->
      template = -> div '#'
      expect(render template).to.equal '<div>#</div>'

  describe 'one class selector', ->
    it 'adds an html class', ->
      template = -> div '.myclass', 'foo'
      expect(render template).to.equal '<div class="myclass">foo</div>'

    describe 'and a class attribute', ->
      it 'prepends the selector class', ->
        template = -> div '.myclass', 'className': 'myattrclass', 'foo'
        expect(render template).to.equal '<div class="myclass myattrclass">foo</div>'

  describe 'multi-class selector', ->
    it 'adds all the classes', ->
      template = -> div '.myclass.myclass2.myclass3', 'foo'
      expect(render template).to.equal '<div class="myclass myclass2 myclass3">foo</div>'

  describe 'with an id and classes, separated by spaces', ->
    it 'adds ids and classes with minimal whitespace', ->
      template = -> div '#myid.myclass1 .myclass2 '
      expect(render template).to.equal '<div id="myid" class="myclass1 myclass2"></div>'

  describe 'without contents', ->
    it 'still adds attributes', ->
      template = -> img '#myid.myclass', src: '/pic.png'
      # the order of src, id and myclass may change from react version to...
      expect(render template).to.contain '<img src="/pic.png" id="myid" class="myclass"/>'
