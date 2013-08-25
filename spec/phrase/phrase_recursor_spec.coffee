should              = require 'should'
PhraseRecursor      = require '../../lib/phrase/phrase_recursor'
PhraseRecursorHooks = require '../../lib/recursor/control/hooks'
PhraseNode          = require '../../lib//phrase_node'
PhraseGraph         = require '../../lib/graph/phrase_graph'

describe 'PhraseRecursor', -> 

    context 'create()', -> 

        root   = undefined
        opts   = undefined
        swap1  = undefined
        EVENTS = undefined

        asyncInjectionFn = ->


        beforeEach ->

            swap1  = PhraseRecursorHooks.bind
            
            EVENTS = {}
            root   = require 'also'
            root.context = 
                stack:  []
                notice: 
                    event: -> then: (fn) -> fn()
                    info:  -> then: (fn) -> fn()
                    use:   -> 
                token: emit: (event, args...) ->

                    EVENTS[event] = args

            root.context.PhraseNode = PhraseNode.createClass root
            root.context.PhraseGraph = PhraseGraph.createClass root

            opts = 
                title: 'Title'
                uuid:  '00000'
                leaf: ['end']
                timeout: 1000

        afterEach -> 

            PhraseRecursorHooks.bind = swap1


        it 'creates recursion control hooks with root context and parent control', (done) -> 

            PhraseRecursorHooks.bind = (rooot, parent) -> 

                rooot.should.equal root
                done()
                throw 'go no further'

            try PhraseRecursor.walk root, opts


        it 'creates root graph only once', (done) -> 

            delete root.context.graph
            PhraseRecursor.walk root, opts, 'phrase string', (nest) ->
            graph = root.context.graph
            should.exist graph

            PhraseRecursor.walk root, opts, 'phrase string', (nest) ->
            graph.should.equal root.context.graph
            done()


        it 'creates an orphaned graph on subsequent calls', (done) -> 

            delete root.context.graph
            PhraseRecursor.walk root, opts, 'phrase string', (nest) ->
            rootGraph = root.context.graph

            PhraseRecursor.walk root, opts, 'phrase string', (nest) ->
            newGraph = root.context.graphs.latest

            should.exist newGraph
            newGraph.should.not.equal rootGraph
            done()


        it 'assigns root token name and uuid from branch title', (done) -> 

            PhraseRecursorHooks.bind = (rooot, parent) -> 

                parent.phraseToken.name.should.equal 'Title'
                parent.phraseToken.uuid.should.equal '00000'
                done()
                throw 'go no further'

            try PhraseRecursor.walk root, opts, 'phrase string', (nest) ->


        it 'emits "error" onto the root token at invalid phrase text', (done) -> 

            PhraseRecursor.walk( root, opts, 'phra/se string', (nest) -> ).then( 

                ->
                -> EVENTS.error.should.match /NVALID text/; done()
                ->

            )
                

        it 'assigns access to registered phrase hooks', (done) -> 
   
            PhraseRecursor.walk root, opts, 'phrase string', (nest) ->
            before each: -> done()
            root.context.hooks.beforeEach[0].fn()


        # it 'TEMPORARY provides assess to stack', (done) -> 
            
        #     PhraseRecursor.walk root, opts, 'phrase', (nested) -> 

        #         nested.stack.should.equal root.context.stack
        #         done()


        it 'recurses via the injector', (done) -> 

            CALLS = []

            root.inject.async = (Preparator, decoratedFn) -> -> 

                CALLS.push arguments
                args = [arguments[0], arguments[1], arguments[2]]
                args[2] = args[1] unless args[2]?
                decoratedFn.apply this, args

            PhraseRecursor.walk root, opts, 'outer phrase string', (nested) ->

                nested 'nested phrase string', {}, (deeper) -> 

                    deeper '...', {}, ->

                        CALLS[0][0].should.equal 'outer phrase string'
                        CALLS[1][0].should.equal 'nested phrase string'
                        CALLS[2][0].should.equal '...'

                        done()


