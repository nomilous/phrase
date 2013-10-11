should             = require 'should'
RecursorAfterAll   = require '../../../lib/recursor/control/after_all'

describe 'RecursorAfterAll', -> 

    
    it 'resolves the parent phrase', (done) -> 

        root = 
            context: stack: [

                deferral: resolve: done

            ]

        hook = RecursorAfterAll.create root, {}
        hook (->), {}


    it 'generates the phrase::recurse::end event if there is no parent', (done) -> 

        Date.now = -> 10
        root = 
            uuid: 'ROOTUUID'
            context: 
                stack: []

                #
                # walking is flagged by recursor/before_all 
                #

                walking: startedAt: 1
                notice: phrase: (title, payload) -> 

                    title.should.equal 'phrase::recurse:end'
                    
                    payload.should.eql 

                        root: uuid: 'ROOTUUID'
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

        beforeEach ->
            @updated = 0
            @root = 
                context: 
                    stack: []
                    walking: startedAt: 1
                    notice: phrase: -> then: (fn) -> fn()
                    tree:  version: 1, vertices: {}, update: => then: (done) => @updated++; done()
                    trees: latest: version: 2, vertices: {}

            @hook = RecursorAfterAll.create @root, {}

            @hook (->), {}

            @first = @root.context.firstWalk
        

        xit 'remembers the first walk', (done) -> 

            @root.context.walking = startedAt: 2
            @hook (->), {}
            @root.context.firstWalk.should.equal @first
            done()

        it 'does not call update() on the root tree on first walk', (done) -> 

            @root.context.walks = undefined
            @root.context.walking = startedAt: 2
            @hook (=>

                @updated.should.equal 0
                done()

            ), {}

        it 'calls update on each subsequent walk', (done) -> 

            @root.context.walks = undefined
            @root.context.walking = startedAt: 2
            @hook (->), {}

            @root.context.walking = startedAt: 4
            @hook (->), {}

            @root.context.walking = startedAt: 6
            @hook (=>

                @updated.should.equal 2
                done()

            ), {}

        it 'afterAll hook waits for update', (done) -> 

            recurseDone = false
            @root.context.tree.update = -> then: (resolve) -> 

                process.nextTick -> 

                    recurseDone.should.equal false
                    resolve()

                    process.nextTick -> 

                        recurseDone.should.equal true
                        done()

            @root.context.walking = startedAt: 2
            @hook (->

                recurseDone = true

            ), {}



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