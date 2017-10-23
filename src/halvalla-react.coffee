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
    getChildren: (element)->element.props.children
    propertyName: 'props'
    getName: (element)->element.tagName || element.type
{Halvalla} = require '../lib/halvalla'
C=new Halvalla Oracle
module.exports= C.tags()
module.exports.Halvalla =Halvalla
