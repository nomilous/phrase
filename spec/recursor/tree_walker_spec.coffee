should          = require 'should'
TreeWalker      = require '../../lib/recursor/tree_walker'
RecursorControl = require '../../lib/recursor/control'
PhraseNode      = require '../../lib/phrase/node'
PhraseTree      = require '../../lib/phrase/tree'
BoundryHandler  = require '../../lib/recursor/boundry_handler'

describe 'TreeWalker', -> 

    context 'create()', -> 

        root   = undefined
        opts   = undefined
        swap1  = undefined
        EVENTS = undefined

        asyncInjectionFn = ->


        beforeEach ->

            swap1  = RecursorControl.bindControl
            
            EVENTS = {}
            root   = require 'also'
            root.context = 
                stack:  []
                notice: 
                    event: -> then: (fn) -> fn()
                    info:  -> then: (fn) -> fn()
                    use:   -> 
                token: emit: (event, args...) ->

            root.context.PhraseNode = PhraseNode.createClass root
            root.context.PhraseTree = PhraseTree.createClass root

            opts = 
                title:   'Title'
                uuid:    '00000'
                leaf:    ['end']
                boundry: ['edge']
                timeout: 1000

        afterEach -> 

            RecursorControl.bindControl = swap1


        it 'creates recursion control hooks with root context and parent control', (done) -> 

            RecursorControl.bindControl = (rooot, parent) -> 

                rooot.should.equal root
                done()
                throw 'go no further'

            try TreeWalker.walk root, opts


        it 'creates root tree only once', (done) -> 

            delete root.context.tree
            TreeWalker.walk root, opts, 'phrase string', (nest) ->
            tree = root.context.tree
            should.exist tree

            TreeWalker.walk root, opts, 'phrase string', (nest) ->
            tree.should.equal root.context.tree
            done()


        it 'creates an orphaned tree on subsequent calls', (done) -> 

            delete root.context.tree
            TreeWalker.walk root, opts, 'phrase string', (nest) ->
            rootTree = root.context.tree

            TreeWalker.walk root, opts, 'phrase string', (nest) ->
            newTree = root.context.trees.latest

            should.exist newTree
            newTree.should.not.equal rootTree
            done()


        it 'assigns root token name and uuid from branch title', (done) -> 

            RecursorControl.bindControl = (rooot, parent) -> 

                parent.phraseToken.signature.should.equal 'Title'
                parent.phraseToken.uuid.should.equal '00000'
                done()
                throw 'go no further'

            try TreeWalker.walk root, opts, 'phrase string', (nest) ->


        it 'emits "error" onto the root token at invalid phrase title', (done) -> 

            root.context.token.emit = (event, error) ->

                error.should.match /INVALID title/
                done()

            TreeWalker.walk root, opts, 'phra/se string', (nest) -> 
                

        it 'assigns access to registered phrase hooks', (done) -> 
   
            TreeWalker.walk root, opts, 'phrase string', (nest) ->
            before each: -> done()
            root.context.hooks.beforeEach[0].fn()


        it 'recurses via the injector', (done) -> 

            CALLS = []

            root.inject.async = (Preparator, decoratedFn) -> -> 

                CALLS.push arguments
                args = [arguments[0], arguments[1], arguments[2]]
                args[2] = args[1] unless args[2]?
                decoratedFn.apply this, args

            TreeWalker.walk root, opts, 'outer phrase string', (nested) ->

                nested 'nested phrase string', {}, (deeper) -> 

                    deeper '...', {}, ->

                        CALLS[0][0].should.equal 'outer phrase string'
                        CALLS[1][0].should.equal 'nested phrase string'
                        CALLS[2][0].should.equal '...'

                        done()


        # it 'enables linking to other Phrase Trees', (done) -> 

        #     BoundryHandler.link = (root, opts) -> 

        #         root.should.equal root
        #         opts.should.eql directory: './path/to/more'
        #         done()

        #     TreeWalker.walk root, opts, 'outer phrase string', (nested) ->

        #         nested 'inner phrase', (boundry) -> 
                
        #             boundry.link directory: './path/to/more'


