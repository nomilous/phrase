PhraseRoot = require './phrase/root'

require( 'also' ) exports, {}, (core) -> 

    createRoot: (opts, linkFn) -> 

        phraseRoot = PhraseRoot.createClass core
        phraseRoot.createRoot opts, linkFn
