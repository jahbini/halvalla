#
React=require 'react'
ReactDom = require 'react-dom/server'
Oracle =
    summoner: React
    name: 'React'
    isValidElement: React.isValidElement
    Component: React.Component
    Element: {}
    createElement: React.createElement
    createComponent: React.createComponent
    conjurer: ReactDom.renderToStaticMarkup
    preInstantiate: false
    getProp: (element)->element.props
    propertyName: 'props'
    getName: (element)->element.tagName || element.type
{Halvalla} = require '../src/halvalla.coffee'
C=new Halvalla Oracle
module.exports= C.tags()
module.exports.Halvalla =Halvalla
