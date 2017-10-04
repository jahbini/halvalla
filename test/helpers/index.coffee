
module.exports.react =
  render: (template, args...) ->
    element = template(args...)
    if typeof element is 'string' then element
    else ReactDOM.renderToStaticMarkup(element)

M = require 'Mithril'
#renderer = require 'mithril-node-render'

module.exports =
  render: (template, args...) ->
    try
      element = template(args...)
      if typeof element is 'string' then element
      else renderer(element,{ strict: false })
    catch badDog
      #console.warn 'ungood render', badDog
      throw badDog
