#
React=require 'react'
ReactDom = require 'react-dom/server'

Oracle =
    summoner: React
    name: 'React'
    isValidElement: React.isValidElement
    Component: React.Component
    createElement: React.createElement
    conjurer: ReactDom.renderToString
    getProp: (element)->element.props
    getName: (element)->element.tagName
{Halvalla} = require '../src/halvalla.coffee'
C=new Halvalla Oracle
module.exports= C.tags()
module.exports.Halvalla =Halvalla
