#
React=require 'react'
ReactDom = require 'react-dom/server'
debugger
Oracle =
    summoner: React
    name: 'React'
    isValidElement: React.isValidElement
    Component: React.Component
    createElement: React.createElement
    createComponent: React.createComponent
    conjurer: ReactDom.renderToStaticMarkup
    preInstantiate: true
    instantiateChildFunction: true # React don't like functions. Halvalla will cope
    getProp: (element)->element.props
    propertyName: 'props'
    getName: (element)->element.tagName || element.type
{Halvalla} = require '../src/halvalla.coffee'
C=new Halvalla Oracle
module.exports= C.tags()
module.exports.Halvalla =Halvalla
