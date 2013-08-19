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

                #
                # walking is flagged by recursor/before_all 
                #

                walking: startedAt: 1
                notice: event: (title, payload) -> 

                    title.should.equal 'phrase::recurse:end'
                    
                    payload.should.eql 

                        walk:
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


    context 'walk history', -> 

        before ->

            @root = 
                context: 
                    stack: []
                    walking: startedAt: 1
                    notice: event: -> then: (fn) -> fn()
                    graph:  version: 1, vertices: {}
                    graphs: latest: version: 2, vertices: {}

            @hook = RecursorAfterAll.create @root, {}

            @hook (->), {}

            @first = @root.context.firstWalk
        

        it 'remembers the first walk', (done) -> 

            @root.context.walking = startedAt: 2
            @hook (->), {}
            @root.context.firstWalk.should.equal @first
            done()


        it 'keeps a limited length history with most recent in front', (done) -> 

            @root.context.walks = undefined

            @root.context.walking = startedAt: 2
            @hook (->), {}

            @root.context.walking = startedAt: 4
            @hook (->), {}

            @root.context.walking = startedAt: 6
            @hook (->), {}

            @root.context.walking = startedAt: 8
            @hook (->), {}

            @root.context.walking = startedAt: 10
            @hook (->), {}

            @root.context.walking = startedAt: 12
            @hook (->), {}

            @root.context.walking = startedAt: 14, mark: 'MOST RECENT'
            @hook (->), {}

            @root.context.walks.length.should.equal 5   # arb choice
            @root.context.walks[0].mark.should.equal 'MOST RECENT'

            done()