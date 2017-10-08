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
{Chalice} = require '../src/chalice.coffee'
C=new Chalice Oracle
module.exports= C.tags()
module.exports.Chalice =Chalice
