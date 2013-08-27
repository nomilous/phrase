ProcessToken = require './token/process_token'
PhraseRoot   = require './phrase/root'

require( 'also' ) exports, {}, (core) -> 

    process = new ProcessToken core

    createRoot: (opts, linkFn) -> 

        root = process.root opts.uuid

        PhraseRoot.createClass( root ).createRoot opts, linkFn
