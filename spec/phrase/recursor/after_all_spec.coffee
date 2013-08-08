should             = require 'should'
RecursorAfterAll   = require '../../../lib/phrase/recursor/after_all'

describe 'RecursorAfterAll', -> 

    
    it 'resolves the parent phrase', (done) -> 

        root = context: stack: [

            deferral: resolve: done

        ]

        hook = RecursorAfterAll.create root, {}
        
        hook (->), {}

