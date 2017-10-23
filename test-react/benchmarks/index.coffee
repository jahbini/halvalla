{Suite} = require 'benchmark'
React = require 'react'
{crel} = require '../../lib/halvalla-react'
{render} = require '../helpers'

new Suite()
  .add 'native', ->
    render ->
      React.createElement('div', {className: 'foo'},
        React.createElement 'div', {className: 'bar'}
      )

  .add 'halvalla', ->
    render ->
      crel 'div', '.foo', ->
        crel 'div', '.bar'

  .on 'cycle', (event) ->
    console.log String event.target

  .on 'complete', ->
    console.log "Fastest is #{@filter('fastest').pluck('name')}"

  .run async: true
