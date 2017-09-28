# setup.js
'use strict';

jsdom =require 'jsdom'
exposedProperties = ['window','navigator','document']

# Define some html to be our basic document
# JSDOM will consume this and act as if we were in a browser
DEFAULT_HTML = '<html><body></body></html>';

# Define some variables to make it look like we're a browser
# First, use JSDOM's fake DOM as the document
global.document = jsdom.jsdom(DEFAULT_HTML);

# Set up a mock window
global.window = document.defaultView
for key,val of document.defaultView
    if typeof global[key] == 'undefined'
        exposedProperties.push val
# Allow for things like window.location
global.navigator = userAgent: 'node.js' 
