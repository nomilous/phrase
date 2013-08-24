should               = require 'should'
PhraseGraphChangeSet = require '../../lib/graph/phrase_graph_change_set'
PhraseGraph          = require '../../lib/graph/phrase_graph'
PhraseToken          = require '../../lib/phrase_token'
PhraseNode           = require '../../lib/phrase_node'
PhraseRecursor       = require '../../lib/phrase/phrase_recursor'
Notice               = require 'notice'
also                 = require 'also'

describe 'PhraseGraphChangeSet', -> 

    context 'collection', -> 

        # 
        # IMPORTANT
        # 

        it 'removes old changesets from the collection'



    beforeEach -> 

        @root = 
            context: 
                notice: 
                    event: ->
                    use: ->

        @ChangeSet  = PhraseGraphChangeSet.createClass @root
        @Graph      = PhraseGraph.createClass @root
        @Node       = PhraseNode.createClass @root
        @graphA     = new @Graph
        @graphB     = new @Graph

    xcontext 'general', ->

        it 'creates a changeSet with uuid', (done) -> 

            set1 = new @ChangeSet @graphA, @graphB
            set2 = new @ChangeSet @graphA, @graphB

            should.exist set1.changes.uuid
            should.exist set2.changes.uuid
            set1.changes.uuid.should.not.equal set2.changes.uuid
            done()

        it 'can have no changes', (done) -> 

            set1 = new @ChangeSet @graphA, @graphB

            should.not.exist set1.changes.created
            should.not.exist set1.changes.updated
            should.not.exist set1.changes.deleted

            done()


    context 'change', -> 

        #
        # some laziness here (building graph by hand is laborious)
        # these tests depend heavilly on functionlity of the rest of the system
        # 

        # console.log before.toString()
        ChangeSet = undefined
        Test      = undefined

        before (done) -> 


            Test = (phrases, compare) => 

                {phrase1, phrase2} = phrases

                #
                # assemble graph pair from each phrase
                #

                opts = 
                    title:   'TEST'
                    uuid:    '0001'
                    leaf:    ['end']
                    timeout: 2000

                #
                # load runtime
                #

                root                     = also
                root.context             = {}
                root.context.notice      = Notice.create opts.uuid
                root.context.PhraseGraph = PhraseGraph.createClass root
                root.context.PhraseNode  = PhraseNode.createClass root
                root.context.token       = PhraseToken.create root
                ChangeSet                = PhraseGraphChangeSet.createClass root

                PhraseRecursor.walk( root, opts, 'phrase', phrase1 ).then ->

                    previousGraph = root.context.graphs.latest
                
                    PhraseRecursor.walk( root, opts, 'phrase', phrase2 ).then -> 

                        compare previousGraph, root.context.graphs.latest


            done()


        xcontext 'detecting changes', ->

            it 'detects renamed branch vertices (token.name/text)'

                #
                # instead of reporting deleted and created for all nested vertices
                # with the resulting new path.
                # 
                # later...
                #


            it 'detects removed leaves', (done) -> 

                Test

                    phrase1: (nested) -> 
                        nested 'nested phrase 1', (end) -> 
                            end()
                        nested 'deletes this', (end) -> 
                            end()

                    phrase2: (nested) -> 
                        nested 'nested phrase 1', (end) -> 
                            end()


                    (graphA, graphB) -> 

                        set = new ChangeSet graphA, graphB
                        should.exist set.changes.deleted['/TEST/phrase/nested/deletes this']
                        done()


            it 'detectes removed branches', (done) -> 

                Test

                    phrase1: (nested) -> 
                        nested 'nested phrase 1', (end) -> 
                            end()


                        nested 'deletes this', (more) -> 
                            more '1', (end) ->
                            more '2', (end) ->


                    phrase2: (nested) -> 
                        nested 'nested phrase 1', (end) -> 
                            end()


                    (graphA, graphB) -> 

                        set = new ChangeSet graphA, graphB
                        should.exist set.changes.deleted['/TEST/phrase/nested/deletes this']
                        should.exist set.changes.deleted['/TEST/phrase/nested/deletes this/more/1']
                        should.exist set.changes.deleted['/TEST/phrase/nested/deletes this/more/2']
                        done()




            it 'detects created leaves', (done) -> 

                Test

                    phrase1: (nested) -> 
                        nested 'nested phrase 1', (end) -> 
                            end()

                    phrase2: (nested) -> 
                        nested 'nested phrase 1', (end) -> 
                            end()
                        nested 'creates this', (end) -> 
                            end()

                    (graphA, graphB) -> 

                        set = new ChangeSet graphA, graphB
                        should.exist set.changes.created['/TEST/phrase/nested/creates this']
                        done()

            it 'detectes created branches', (done) -> 

                Test

                    phrase1: (nested) -> 
                        nested 'nested phrase 1', (end) -> 
                            end()

                    phrase2: (nested) -> 
                        nested 'nested phrase 1', (end) -> 
                            end()

                        nested 'created this', (more) -> 
                            more '1', (end) ->
                            more '2', (end) ->


                    (graphA, graphB) -> 

                        set = new ChangeSet graphA, graphB
                        should.exist set.changes.created['/TEST/phrase/nested/created this']
                        should.exist set.changes.created['/TEST/phrase/nested/created this/more/1']
                        should.exist set.changes.created['/TEST/phrase/nested/created this/more/2']
                        done()



            it 'detects updated leaves', (done) -> 

                Test

                    phrase1: (nested) -> 
                        nested 'nested phrase 1', (end) -> 1

                    phrase2: (nested) -> 
                        nested 'nested phrase 1', (end) -> 2

                    (graphA, graphB) -> 

                        set = new ChangeSet graphA, graphB
                        
                        update = set.changes.updated['/TEST/phrase/nested/nested phrase 1']
                        update.fn.from().should.equal 1
                        update.fn.to(  ).should.equal 2
                        done()


            it 'detects changed hooks as parent vertex', (done) -> 

                Test

                    phrase1: (nested) -> 
                        nested 'nested phrase 1', (end) -> 
                            end()

                        nested 'updates this', (more) ->
                            before each: -> 1
                            more '1', (end) ->
                            more '2', (end) ->

                    phrase2: (nested) -> 
                        nested 'nested phrase 1', (end) -> 
                            end()

                        nested 'updates this', (more) ->
                            before each: -> 2
                            after  all:  -> 3
                            more '1', (end) ->
                            more '2', (end) ->


                    (graphA, graphB) -> 

                        set = new ChangeSet graphA, graphB

                        update = set.changes.updated['/TEST/phrase/nested/updates this']
                        update.hooks.beforeEach.fn.from().should.equal 1
                        update.hooks.beforeEach.fn.to(  ).should.equal 2

                        should.not.exist update.hooks.afterAll.fn.from
                        update.hooks.afterAll.fn.to().should.equal 3
                        done()


            it 'timeout changes all affected', (done) -> 

                Test

                    phrase1: (nested) -> 
                        nested 'nested phrase 1', (end) -> 
                            end()

                        nested 'updates this', timeout: 10000, (more) ->
                            more '1', (end) ->  #
                            more '2', (end) ->  # local timeout override on branch
                                                #

                    phrase2: (nested) -> 
                        nested 'nested phrase 1', (end) -> 
                            end()

                        nested 'updates this', (more) ->
                            more '1', (end) ->  #
                                                # timeouts return to default
                                                #

                            more '2',  timeout: 10000, (end) ->
                                                #
                                                # more focussed local override
                                                # leaves leaf unchanged
                                                #


                    (graphA, graphB) -> 

                        set = new ChangeSet graphA, graphB

                        updates = set.changes.updated
                        should.not.exist updates['/TEST/phrase/nested/updates this/more/2']
                        updates['/TEST/phrase/nested/updates this'].timeout.should.eql        from: 10000, to: 2000
                        updates['/TEST/phrase/nested/updates this/more/1'].timeout.should.eql from: 10000, to: 2000
                        done()



            it 'timeout on hook changes all affected', (done) -> 


                Test

                    phrase1: (nested) -> 
                        nested 'nested phrase 1', (end) -> 
                            end()

                        nested 'updates this', (more) ->
                            before timeout: 100, all: (done) ->
                            more '1', (end) -> 
                            more '2', (end) -> 

                    phrase2: (nested) -> 
                        nested 'nested phrase 1', (end) -> 
                            end()

                        nested 'updates this', (more) ->
                            before timeout: 200, all: (done) ->
                            more '1', (end) -> 
                            more '2', (end) -> 


                    (graphA, graphB) -> 

                        set = new ChangeSet graphA, graphB
                        updates = set.changes.updated
                        updates['/TEST/phrase/nested/updates this'].hooks.should.eql
                            beforeAll:
                                timeout: 
                                    from: 100
                                    to: 200

                        #GREP2 
                        should.exist updates['/TEST/phrase/nested/updates this'].target
                        done()
                    

        context 'applying changes (A-B)', -> 

            xit 'applies changes into graphA and preserves vertex uuid', (done) ->

                Test

                    phrase1: (nested) -> 
                        nested 'nested phrase 1', uuid: 1111,               (end) -> 1
                        nested 'nested phrase 2', uuid: 2222, timeout: 100, (end) -> 1

                    phrase2: (nested) -> 
                        nested 'nested phrase 1',               (end) -> 'NEW'
                        nested 'nested phrase 2', timeout: 200, (end) -> 2

                    (graphA, graphB) -> 


                        set = new ChangeSet graphA, graphB

                        set.AtoB()

                        graphA.vertices[1111].fn().should.equal 'NEW'
                        graphA.vertices[2222].timeout.should.equal 200
                        done()


            xit 'applies hook changes to all affected vertexes', (done) -> 

                Test

                    phrase1: (nested) -> 

                        before all: -> 1

                        nested 'nested phrase 1', uuid: 1111, (end) -> 
                        nested 'nested phrase 2', uuid: 2222, (end) -> 

                    phrase2: (nested) -> 

                        before all: -> 'UPDATED'

                        nested 'nested phrase 1', (end) -> 
                        nested 'nested phrase 2', (end) -> 

                    (graphA, graphB) -> 

                        set = new ChangeSet graphA, graphB

                        set.AtoB()

                        graphA.vertices[1111].hooks.beforeAll.fn().should.equal 'UPDATED'
                        graphA.vertices[2222].hooks.beforeAll.fn().should.equal 'UPDATED'
                        done()

                
            xit 'created hooks are assigned uuid, timeout, fn and copied into all children', (done) -> 

                Test

                    phrase1: (nested) -> 


                        nested 'nested phrase 1', uuid: 1111, (end) -> 
                        nested 'nested phrase 2', uuid: 2222, (end) -> 

                    phrase2: (nested) -> 

                        before all: -> 'NEW'

                        nested 'nested phrase 1', (end) -> 
                        nested 'nested phrase 2', (end) -> 

                    (graphA, graphB) -> 

                        set = new ChangeSet graphA, graphB

                        set.AtoB() 

                        # console.log graphA.vertices[1111].hooks.beforeAll
                        # console.log graphA.vertices[2222].hooks.beforeAll
                        graphA.vertices[1111].hooks.beforeAll.fn().should.equal 'NEW'
                        graphA.vertices[2222].hooks.beforeAll.should.equal graphA.vertices[2222].hooks.beforeAll
                        done()


            xit 'deletes vertices (leaf)', (done) -> 


                Test

                    phrase1: (nested) -> 

                        nested 'nested phrase 1', uuid: 1111, (end) -> 
                        nested 'nested phrase 2', uuid: 2222, (end) -> 

                    phrase2: (nested) -> 

                        nested 'nested phrase 2', uuid: 9999, (end) -> 'not allowing uuid re-assign for now'
                                                         #
                                                         # consider allowing reassignment of uuid
                                                         # on existing phrase,
                                                         # this one is already uuid: 2222
                                                         # 

                    (graphA, graphB) -> 

                        set = new ChangeSet graphA, graphB
                        set.AtoB()
                        should.not.exist graphA.vertices[1111]
                        should.not.exist graphA.vertices[9999]
                        graphA.vertices[2222].fn().should.equal 'not allowing uuid re-assign for now'
                        done()


            xit 'deletes vertices (branch)', (done) -> 

                Test

                    phrase1: (nested) -> 

                        nested 'nested phrase 1', uuid: 1111, (end) -> 
                        nested 'nested phrase 2', uuid: 2222, (deeper) ->
                            deeper 'one', uuid: 3333, (end) ->
                            deeper 'two', uuid: 4444, (end) ->  

                    phrase2: (nested) -> 

                        nested 'nested phrase 1', (end) -> 

                    (graphA, graphB) -> 

                        set = new ChangeSet graphA, graphB

                        set.AtoB()

                        should.exist     graphA.vertices[1111]
                        should.not.exist graphA.vertices[2222]
                        should.not.exist graphA.vertices[3333]
                        should.not.exist graphA.vertices[4444]
                        done()


            xit 'creates vertices (leaf)', (done) -> 

                Test

                    phrase1: (nested) -> 

                        nested 'nested phrase 1', uuid: 1111, (end) -> 0
                        

                    phrase2: (nested) -> 

                        nested 'nested phrase 1',             (end) -> 1
                        nested 'nested phrase 2', uuid: 2222, (end) -> 2


                    (graphA, graphB) -> 

                        set = new ChangeSet graphA, graphB
                        set.AtoB()
                        graphA.vertices[1111].fn().should.equal 1
                        graphA.vertices[2222].fn().should.equal 2
                        done()


            xit 'creates vertices (branch)', (done) -> 

                Test

                    phrase1: (nested) -> 

                        nested 'nested phrase 1', uuid: 1111, (end) -> 
                        

                    phrase2: (nested) -> 

                        nested 'nested phrase 1', (end) -> 
                        nested 'nested phrase 2', uuid: 2222, (deeper) ->
                            deeper 'one', uuid: 3333, (end) ->
                            deeper 'two', uuid: 4444, (end) ->  

                    (graphA, graphB) -> 

                        set = new ChangeSet graphA, graphB
                        set.AtoB()

                        should.exist     graphA.vertices[1111]
                        should.exist     graphA.vertices[2222]
                        should.exist     graphA.vertices[3333]
                        should.exist     graphA.vertices[4444]
                        done()


            it 'creates vertices into ex leaf (leaf flag becomes false)', (done) -> 

                Test

                    phrase1: (nested) -> 

                        nested 'nested phrase 1', uuid: 1111, (end) -> 


                    phrase2: (nested) -> 

                        nested 'nested phrase 1', (deeper) ->
                            deeper 'one', uuid: 2222, (end) ->
                            deeper 'two', uuid: 3333, (end) ->  

                    (graphA, graphB) -> 

                        set = new ChangeSet graphA, graphB
                        set.AtoB()
                        graphA.vertices[1111].leaf.should.equal false
                        done()


            it 'deletes vertices from ex branch (leaf flag becomes true)', (done) -> 

                Test

                    phrase1: (nested) -> 

                        nested 'nested phrase 1', uuid: 1111, (end) -> 
                            deeper 'one', uuid: 2222, (end) ->
                            deeper 'two', uuid: 3333, (end) ->  


                    phrase2: (nested) -> 

                        nested 'nested phrase 1', (end) ->

                    (graphA, graphB) -> 

                        set = new ChangeSet graphA, graphB
                        set.AtoB()
                        graphA.vertices[1111].leaf.should.equal true
                        done()


        xcontext 'updates indexes', -> 

            it 'ammends path2uuid and uuid2path indexes (not in order)', (done) ->

                Test

                    phrase1: (nested) -> 

                        nested 'nested phrase 1', uuid: 1111, (deeper) -> 

                            #
                            # deletes first vertex in phrase 1
                            #

                            deeper 'deleted',  uuid: 'deleted', (end) ->

                        nested 'nested phrase 2', uuid: 2222, (deeper) ->
                            deeper 'one', uuid: 3333, (end) ->
                            deeper 'two', uuid: 4444, (end) ->  
                        

                    phrase2: (nested) -> 

                        nested 'nested phrase 1', (end) -> 
                        nested 'nested phrase 2', (deeper) -> 

                            #
                            # new first vertex in phrase 2
                            #

                            deeper 'created', uuid: 9999, (end) -> 
                            deeper 'one',                 (end) ->
                            deeper 'two',                 (end) ->  

                    (graphA, graphB) -> 

                        set = new ChangeSet graphA, graphB
                        set.AtoB()

                        should.not.exist graphA.path2uuid['/TEST/phrase/nested/nested phrase 1/deeper/deleted']
                        should.not.exist graphA.uuid2path['deleted']

                        graphA.path2uuid.should.eql 

                            '/TEST/phrase': '0001',
                            '/TEST/phrase/nested/nested phrase 1': 1111
                            '/TEST/phrase/nested/nested phrase 2': 2222
                            '/TEST/phrase/nested/nested phrase 2/deeper/one': 3333
                            '/TEST/phrase/nested/nested phrase 2/deeper/two': 4444

                            '/TEST/phrase/nested/nested phrase 2/deeper/created': 9999

                        graphA.uuid2path.should.eql 

                            '0001': '/TEST/phrase'
                            '1111': '/TEST/phrase/nested/nested phrase 1'
                            '2222': '/TEST/phrase/nested/nested phrase 2'
                            '3333': '/TEST/phrase/nested/nested phrase 2/deeper/one'
                            '4444': '/TEST/phrase/nested/nested phrase 2/deeper/two'

                            '9999': '/TEST/phrase/nested/nested phrase 2/deeper/created'                   
                        
                        done()


            it 'updates children index and preserves vertex order', (done) -> 

                Test

                    phrase1: (nested) -> 

                        nested 'nested phrase 1', uuid: 1111, (deeper) -> 

                            deeper 'deleted',  uuid: 'deleted', (end) ->

                        nested 'nested phrase 2', uuid: 2222, (deeper) ->
                            deeper 'one', uuid: 3333, (end) ->
                            deeper 'two', uuid: 4444, (end) ->  
                        

                    phrase2: (nested) -> 

                        nested 'nested phrase 1', (end) -> 
                        nested 'nested phrase 2', (deeper) -> 

                            deeper 'created', uuid: 9999, (end) -> 
                            deeper 'one',                 (end) ->
                            deeper 'two',                 (end) ->  

                    (graphA, graphB) -> 

                        set = new ChangeSet graphA, graphB
                        set.AtoB()

                        children = {}
                        for parent of graphA.children
                            children[parent] = []
                            for child in graphA.children[parent]
                                children[parent].push child

                        children.should.eql 

                                        #
                                        # preserved child vertex order
                                        #

                            '0001': [ 1111, 2222 ]
                            '2222': [ 9999, 3333, 4444 ]

                        should.not.exist children[1111] # no longer a parent


 
                        done()


            it 'updates parents index', (done) -> 

                Test

                    phrase1: (nested) -> 

                        nested 'nested phrase 1', uuid: 1111, (deeper) -> 

                            deeper 'deleted',  uuid: 'deleted', (end) ->

                        nested 'nested phrase 2', uuid: 2222, (deeper) ->
                            deeper 'one', uuid: 3333, (end) ->
                            deeper 'two', uuid: 4444, (end) ->  
                        

                    phrase2: (nested) -> 

                        nested 'nested phrase 1', (end) -> 
                        nested 'nested phrase 2', (deeper) -> 

                            deeper 'created', uuid: 9999, (end) -> 
                            deeper 'one',                 (end) ->
                            deeper 'two',                 (end) ->  

                    (graphA, graphB) -> 

                        set = new ChangeSet graphA, graphB
                        set.AtoB()

                        graphA.parent.should.eql 

                            '1111': '0001'
                            '2222': '0001'
                            '3333': 2222
                            '4444': 2222
                            '9999': 2222

                        done()

            it 'preserves vertex order in leaves array', (done) ->

                Test

                    phrase1: (nested) -> 

                        nested 'nested phrase 1', uuid: 1111, (deeper) -> 

                            deeper 'deleted',  uuid: 'deleted', (end) ->

                        nested 'nested phrase 2', uuid: 2222, (deeper) ->
                            deeper 'one', uuid: 3333, (end) ->
                            deeper 'two', uuid: 4444, (end) ->  
                        

                    phrase2: (nested) -> 

                        nested 'nested phrase 1', (end) -> 
                        nested 'nested phrase 2', (deeper) -> 

                            deeper 'created', uuid: 9999, (end) -> 
                            deeper 'one',                 (end) ->
                            deeper 'two',                 (end) ->  

                    (graphA, graphB) -> 

                        set = new ChangeSet graphA, graphB
                        set.AtoB()

                        graphA.leaves.should.eql [ 1111, 9999, 3333, 4444 ]
                        done()


            it 'preserves vertex edges', (done) -> 

                Test

                    phrase1: (nested) -> 

                        nested 'nested phrase 1', uuid: 1111, (deeper) -> 

                            deeper 'deleted', uuid: 'deleted', (end) ->
                            deeper 'kept',    uuid: 'kept', (end) ->

                        nested 'nested phrase 2', uuid: 2222, (deeper) ->
                            deeper 'one', uuid: 3333, (end) ->
                            deeper 'two', uuid: 4444, (end) ->  
                        

                    phrase2: (nested) -> 

                        nested 'nested phrase 1', (deeper) -> 
                            deeper 'kept',    uuid: 'kept', (end) ->

                        nested 'nested phrase 2', (deeper) -> 

                            deeper 'created', uuid: 9999, (end) -> 
                            deeper 'one',                 (end) ->
                            deeper 'two',                 (end) ->  

                    (graphA, graphB) -> 

                        set = new ChangeSet graphA, graphB
                        set.AtoB()
                        graphA.edges.should.eql 

                            '1111': [ { to: '0001' }, { to: 'kept' }                           ]
                            '2222': [ { to: '0001' }, { to: 3333 }, { to: 4444 }, { to: 9999 } ]
                            '3333': [ { to: 2222 }                                             ]
                            '4444': [ { to: 2222 }                                             ]
                            '9999': [ { to: 2222 }                                             ]
                            '0001': [ { to: 1111 }, { to: 2222 }                               ]
                            kept:   [ { to: 1111 }                                             ]

                        
                        done()



        context 'applying changes (B-A)', -> 

            #
            # later...
            #

            it 'can do the changes in reverse'




