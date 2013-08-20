should      = require 'should'
PhraseGraph = require '../../lib/graph/phrase_graph'

describe 'PhraseGraph', -> 

    root  = undefined
    Graph = undefined
    graph = undefined

    before -> 

        root = context: notice: use: ->
        Graph = PhraseGraph.createClass root
        graph = new Graph

    context 'general', ->

        it 'has a uuid', (done) -> 

            should.exist graph.uuid
            done()

        it 'has a version', (done) -> 

            should.exist graph.version
            done()


        it 'is added to the graphs collection on the root context', (done) -> 

            g = new Graph
            g.should.equal root.context.graphs.list[ g.uuid ]
            done()


        it 'most recently created graph is set as latest in the graphs collection', (done) -> 

            one = new Graph
            root.context.graphs.latest.touch1 = 1
            two = new Graph
            root.context.graphs.latest.touch2 = 2

            should.exist one.touch1
            should.exist two.touch2
            should.not.exist one.touch2

            done()


        it 'provides access to vertices and edges lists', (done) -> 

            graph.vertices.should.eql {}
            graph.edges.should.eql {}
            done()


    context 'assembler middleware', -> 

        before -> 

            @Graph = PhraseGraph.createClass context: notice: use: (@middleware) =>


        it 'registers on the message bus', (done) -> 

                # 
                # odd... Seems like a function returned by a property
                #        no longer appears to have a the same prototype
                #        instance as the function itself.
                # 
                # middleware.should.equal Graph.assembler
                # console.log middleware is Graph.assembler
                #

                @middleware.toString().should.equal @Graph.assembler.toString()
                done()          # 
                                # marginally pointless...
                                # 



        context 'registerEdge()', ->


            it 'is called by the assember at phrase::edge:create', (done) -> 

                graph = new @Graph

                graph.registerEdge = -> done()

                @Graph.assembler

                    context: title: 'phrase::edge:create'
                    ->


            it 'creates vertices', (done) -> 

                graph = new @Graph

                graph.registerEdge 

                    #
                    # mock 'phrase::edge:create' message
                    #

                    context: title: 'phrase::edge:create'
                    vertices: [
                        { uuid: 'UUID1', key: 'value1' }
                        { uuid: 'UUID2', key: 'value2' }
                    ]

                    -> 

                        graph.vertices.should.eql 

                            UUID1: uuid: 'UUID1', key: 'value1'
                            UUID2: uuid: 'UUID2', key: 'value2'
                        
                        done()


            it 'creates edges' , (done) ->

                graph = new @Graph

                graph.registerEdge 

                    #
                    # mock 'phrase::edge:create' message
                    #

                    context: title: 'phrase::edge:create'
                    vertices: [
                        { uuid: 'UUID1', key: 'value1' }
                        { uuid: 'UUID2', key: 'value2' }
                    ]

                    -> 

                        graph.edges.should.eql 

                            UUID1: [ { to: 'UUID2' } ]
                            UUID2: [ { to: 'UUID1' } ]
                        
                        done()


            it 'allows multiple edges per vertex', (done) -> 

                graph = new @Graph

                graph.registerEdge vertices: [
                        { uuid: 'UUID1', key: 'value1' }
                        { uuid: 'UUID2', key: 'value2' }
                    ],  ->

                graph.registerEdge vertices: [
                        { uuid: 'UUID1', key: 'value1' }
                        { uuid: 'UUID3', key: 'value3' }
                    ],  ->

                graph.edges.should.eql 

                    UUID1: [   { to: 'UUID2' }, { to: 'UUID3' }   ]
                    UUID2: [   { to: 'UUID1' }                    ]
                    UUID3: [   { to: 'UUID1' }                    ]

                
                done()

            it 'stores parent and child relations (if tree)', (done) -> 

                graph = new @Graph

                graph.registerEdge type: 'tree', vertices: [
                    { uuid: 'UUID1', key: 'value1' }
                    { uuid: 'UUID2', key: 'value2' }
                ],  ->

                graph.registerEdge type: 'tree', vertices: [
                        { uuid: 'UUID1', key: 'value1' }
                        { uuid: 'UUID3', key: 'value3' }
                    ],  ->


                graph.parent.should.eql 

                    UUID3: 'UUID1'
                    UUID2: 'UUID1'

                graph.children.should.eql 

                    UUID1: ['UUID2', 'UUID3']


                done()


            it 'stores a list of leaves if tree', (done) -> 

                #
                # vertices are flagged a leaf by the PhraseRecursor
                #

                graph.registerEdge type: 'tree', vertices: [
                        { uuid: 'UUID1', key: 'value1' }
                        { uuid: 'UUID2', key: 'value2', leaf: true }
                    ],  ->

                graph.registerEdge type: 'tree', vertices: [
                        { uuid: 'UUID1', key: 'value1' }
                        { uuid: 'UUID3', key: 'value3' }
                    ],  ->

                graph.registerEdge type: 'tree', vertices: [
                        { uuid: 'UUID3', key: 'value3' }
                        { uuid: 'UUID4', key: 'value4', leaf: true }
                    ],  ->

                graph.leaves.should.eql ['UUID2', 'UUID4']

                done()



    context 'register leaf', -> 


        it 'is called by the assember at phrase::edge:create', (done) -> 

            graph = new @Graph

            graph.registerLeaf = -> done()

            @Graph.assembler

                context: title: 'phrase::leaf:create' 
                ->



        it 'stores registered leaves and provides access to the list via tree.leaves', (done) ->

            graph = new @Graph

            graph.registerLeaf 

                uuid: 'UUID3'
                path: ['UUID1', 'UUID2']

                -> 

            graph.tree.leaves.UUID3.should.eql 

                uuid: 'UUID3'
                path: ['UUID1', 'UUID2']

            done()


    context 'leavesOf(uuid)', -> 

        it 'returns the vertex at uuid if it is a leaf', (done) -> 

            graph = new @Graph

            graph.registerEdge type: 'tree', vertices: [
                    { uuid: 'UUID1', key: 'value1' }
                    { uuid: 'UUID2', arbkey: 'arbvalue', leaf: true }
                ],  ->

            graph.leavesOf( 'UUID2' )[0].arbkey.should.equal 'arbvalue'
            done()


        it 'returns array of leaf vertices nested (any depth) in the vertex at uuid', (done) -> 

            #
            # assemble tree
            # 
            #   1: 
            #      2: leaf
            #      3: 
            #         4: 
            #            6: leaf
            #            7: leaf
            #         5: leaf
            #      8: leaf
            # 
            #

            graph = new @Graph

            graph.registerEdge type: 'tree', vertices: [
                    { uuid: 'UUID1', key: 'value1' }
                    { uuid: 'UUID2', key: 'value2', leaf: true }
                ],  ->
            graph.registerEdge type: 'tree', vertices: [
                    { uuid: 'UUID1', key: 'value1' }
                    { uuid: 'UUID3', key: 'value3' }
                ],  ->
            graph.registerEdge type: 'tree', vertices: [
                    { uuid: 'UUID3', key: 'value3' }
                    { uuid: 'UUID4', key: 'value4' }
                ],  ->
            graph.registerEdge type: 'tree', vertices: [
                    { uuid: 'UUID3', key: 'value3' }
                    { uuid: 'UUID5', key: 'value5', leaf: true }
                ],  ->
            graph.registerEdge type: 'tree', vertices: [
                    { uuid: 'UUID4', key: 'value4' }
                    { uuid: 'UUID6', key: 'value6', leaf: true }
                ],  ->
            graph.registerEdge type: 'tree', vertices: [
                    { uuid: 'UUID4', key: 'value4' }
                    { uuid: 'UUID7', key: 'value7', leaf: true }
                ],  ->
            graph.registerEdge type: 'tree', vertices: [
                    { uuid: 'UUID1', key: 'value1' }
                    { uuid: 'UUID8', key: 'value8', leaf: true }
                ],  ->


            graph.leavesOf( 'UUID4' ).should.eql [ 
                { uuid: 'UUID6', key: 'value6', leaf: true }
                { uuid: 'UUID7', key: 'value7', leaf: true }
            ]

            graph.leavesOf( 'UUID3' ).should.eql [ 
                { uuid: 'UUID6', key: 'value6', leaf: true }
                { uuid: 'UUID7', key: 'value7', leaf: true }
                { uuid: 'UUID5', key: 'value5', leaf: true } 
            ]

            graph.leavesOf( 'UUID1' ).should.eql [ 
                { uuid: 'UUID2', key: 'value2', leaf: true }
                { uuid: 'UUID6', key: 'value6', leaf: true }
                { uuid: 'UUID7', key: 'value7', leaf: true }
                { uuid: 'UUID5', key: 'value5', leaf: true } 
                { uuid: 'UUID8', key: 'value8', leaf: true }
            ]

            done()


    context 'createIndexes', -> 

        xit 'creates paths index and appends it onto phrase::recurse:end for token.ready event', (done) -> 

            i = 1
            Date.now = -> i++

            Phrase = require '../../lib/phrase_root'

            phrase = Phrase.createRoot

                title: 'Test'
                uuid:  'UUID'

                (token, notice) -> 

                    token.on 'ready', (data) -> 

                        #console.log JSON.stringify data, null, 2

                        data.walk.should.eql 

                            startedAt: 1
                            first:     true
                            duration:  1

                        should.exist data.tokens[  "/Test/outer phrase"   ].uuid
                        should.exist data.tokens[  "/Test/outer phrase/nested/inner phrase 1"   ].uuid
                        should.exist data.tokens[  "/Test/outer phrase/nested/inner phrase 1/deep1/deeper phrase"   ].uuid
                        should.exist data.tokens[  "/Test/outer phrase/nested/inner phrase 1/deep1/deeper phrase/deep2/even deeper"   ].uuid
                        should.exist data.tokens[  "/Test/outer phrase/nested/inner phrase 2"   ].uuid

                        done()


            phrase 'outer phrase', (nested) ->

                nested 'inner phrase 1', (deep1) -> 

                    deep1 'deeper phrase', (deep2) ->

                        deep2 'even deeper', (end) -> 

                        #
                        # THING HERE....
                        #
                        # nested 'overlapping', (end) ->
                        # 

                nested 'inner phrase 2', (end) -> 


    context 'change set', ->

        it 'is created ahead of graph update'

        it 'informs messenger of readyness to swich version'

        it 'enables rolling version forward and back'

                
    context 'update()', -> 

        it 'creates a new ChangeSet', -> 

        # 
        #  and move this next test, and make it an actual test'
        # 
        
        before (done) -> 

            @root = require('../../lib/phrase_root').createRoot

                title: 'Test'
                uuid:  'UUID'

                (@token, @notice) => 

                    @token.on 'ready', -> done()

            @root 'root phrase', (nested) -> 

                nested 'nested phrase 1', (end) -> 

                    'ORIGINAL UNCHANGED 1'
                    end()

                nested 'nested phrase 2', (end) -> 

                    'ORIGINAL 2'
                    end()

                nested 'nested phrase 3', (end) -> 

                    'DELETED 3'
                    end()

                nested 'nested phrase 5', (end) -> 

                    'CHANGED BECAUSE OF TIMEOUT ON LEAF'
                    end()

                nested 'nested phrase 6 (changed for timeout)', timeout: 5001, (deeper) -> 

                    deeper 'deeper 6', (end) -> 

                        end()


                nested 'nested phrase 7 (changed for hook on branch vertex)', (deeper) -> 

                    #
                    # since entering @root() the hooks registrars before() and after()
                    # no longer refer to mocha's before(All) and after(All), the have
                    # been overridden by phrase hook registrars
                    #

                    before each: -> 'UNCHANGED'
                    after  each: -> 'ORIGINAL AFTER EACH'

                    deeper 'deeper 7', (end) -> 

                        end()


                

        after -> 

            @token.removeAllListeners()


        it 'transmits events on the message bus', (done) -> 

            #
            # 'graph::compare:start', null
            # 

            MESSAGES = {}

            @notice.use (msg, next) -> 

                MESSAGES[msg.context.title] = msg

                if msg.context.title == 'graph::compare:end'
                
                    should.exist MESSAGES['graph::compare:start']
                    changes = MESSAGES['graph::compare:end'].changes

                    console.log JSON.stringify changes, null, 2 

                    #
                    # deleted
                    #
                    
                    console.log DELETED: changes.deleted['/Test/root phrase/nested/nested phrase 3']


                    #
                    # updated
                    #

                    console.log FROM: changes.updated['/Test/root phrase/nested/nested phrase 2'].fn.from.toString()
                    console.log TO: changes.updated['/Test/root phrase/nested/nested phrase 2'].fn.to.toString()
                    console.log changes.updated['/Test/root phrase/nested/nested phrase 5'].timeout


                    console.log changed_timeout: changes.updated['/Test/root phrase/nested/nested phrase 6 (changed for timeout)'].timeout
                    console.log inherited_changed_timeout: changes.updated['/Test/root phrase/nested/nested phrase 6 (changed for timeout)/deeper/deeper 6'].timeout

                    console.log changed_hooks: changes.updated['/Test/root phrase/nested/nested phrase 7 (changed for hook on branch vertex)']


                    #
                    # created
                    #

                    console.log CREATED: changes.created['/Test/root phrase/nested/nested phrase 4']

                    done()

                next()


            @root 'root phrase', (nested) -> 

                nested 'nested phrase 1', (deeper) ->

                    deeper 'deeper phrase 2', (end) -> 

                        'ORIGINAL UNCHANGED 1'
                        end()

                    deeper 'deeper phrase 3', (end) -> 

                        'ORIGINAL UNCHANGED 1'
                        end()

                nested 'nested phrase 2', (end) -> 

                    'UPDATED 2'
                    end()

                nested 'nested phrase 4', (end) -> 

                    'CREATED 4'
                    end()

                nested 'nested phrase 5', timeout: 5000, (end) -> 

                    'CHANGED BECAUSE OF TIMEOUT ON LEAF'
                    end()


                nested 'nested phrase 6 (changed for timeout)', (deeper) -> 
                                                        #
                                                        # back to default
                                                        #

                    deeper 'deeper 6', (end) -> 

                        end()


                nested 'nested phrase 7 (changed for hook on branch vertex)', (deeper) -> 

                    before each: -> 'UNCHANGED'
                    after  each: -> 'CHANGED AFTER EACH'

                    deeper 'deeper 7', (end) -> 

                        end()



