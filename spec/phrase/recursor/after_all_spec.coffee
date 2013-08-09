should             = require 'should'
RecursorAfterAll   = require '../../../lib/phrase/recursor/after_all'

describe 'RecursorAfterAll', -> 

    
    it 'resolves the parent phrase', (done) -> 

        root = context: stack: [

            deferral: resolve: done

        ]

        hook = RecursorAfterAll.create root, {}
        hook (->), {}


    it 'generates the phrase::recurse::end event if there is no parent', (done) -> 

        root = 
            context: 
                stack: []
                notice: event: (title) -> 

                    title.should.equal 'phrase::recurse::end'
                    done()

        hook = RecursorAfterAll.create root, {}
        hook (->), {}