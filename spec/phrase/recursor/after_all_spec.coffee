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

        Date.now = -> 10
        root = 
            context: 
                stack: []
                'first walk': startedAt: 1
                notice: event: (title, payload) -> 

                    title.should.equal 'phrase::recurse:end'
                    
                    payload.should.eql 

                        startedAt: 1
                        duration:  9

                    then: ->

                        #
                        # and it pends calling final done
                        # till after the message traverses 
                        # all middleware
                        #

                        done()

        hook = RecursorAfterAll.create root, {}
        hook (->), {}