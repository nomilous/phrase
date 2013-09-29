Process    = require './core/process'
Graph      = require './core/graph'
PhraseRoot = require './phrase/root'

require( 'also' ) exports, {}, (core) -> 

    Graph.create core

    process = new Process core

    createRoot: (opts, linkFn) -> 

        root = process.root opts.uuid

        PhraseRoot.createClass( root ).createRoot opts, linkFn
