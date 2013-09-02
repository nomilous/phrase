Process    = require './core/process'
PhraseRoot = require './phrase/root'

require( 'also' ) exports, {}, (core) -> 

    process = new Process core

    createRoot: (opts, linkFn) -> 

        root = process.root opts.uuid

        PhraseRoot.createClass( root ).createRoot opts, linkFn
