PhraseRoot = require './phrase/root'

require( 'also' ) exports, {}, (core) -> 
    
    #
    # leave room for multiple phrase trees per process
    # ------------------------------------------------
    #
    # * for nez objective
    # 

    core.root1 = core

    PhraseRoot.createClass core.root1
