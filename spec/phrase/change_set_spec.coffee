should           = require 'should'
ChangeSetFactory = require '../../lib/phrase/change_set'
PhraseTree       = require '../../lib/phrase/tree'
PhraseRoot       = require '../../lib/phrase/root'
Process          = require '../../lib/core/process'
also             = require 'also'

describe 'ChangeSet', -> 

    it 'can do the changes in reverse'

    it 'detects renamed branch vertices (token.name/text)'

                #
                # instead of reporting deleted and created for all nested vertices
                # with the resulting new path.
                # 
                # later...
                #


    beforeEach -> 

        @root = 
            util: also.util
            context: 
                notice: 
                    event: ->
                    use: ->

        @ChangeSet  = ChangeSetFactory.createClass @root
        @Tree      = PhraseTree.createClass @root
        @treeA     = new @Tree
        @treeB     = new @Tree

    context 'general', ->

        it 'creates a changeSet with uuid', (done) -> 

            set1 = new @ChangeSet @treeA, @treeB
            set2 = new @ChangeSet @treeA, @treeB

            should.exist set1.changes.uuid
            should.exist set2.changes.uuid
            set1.changes.uuid.should.not.equal set2.changes.uuid
            done()

        it 'can have no changes', (done) -> 

            set1 = new @ChangeSet @treeA, @treeB

            should.not.exist set1.changes.created
            should.not.exist set1.changes.updated
            should.not.exist set1.changes.deleted

            done()


    context 'change', -> 

        #
        # some laziness here (building tree by hand is laborious)
        # these tests depend heavilly on functionlity of the rest of the system
        # 

        ChangeSet = undefined
        Test      = undefined
        ROOTUUID  = undefined

        before (done) -> 

            seq  = 0

            Test = (phrases, compare) => 

                {phrase1, phrase2} = phrases

                ROOTUUID = "ROOT#{seq++}"

                #
                # assemble tree pair from each phrase
                #

                opts1 = 
                    title:   'TEST'
                    uuid:    ROOTUUID
                    leaf:    ['end']
                    timeout: 2000

                process   = new Process also
                root1     = process.root opts1.uuid

                recursor1 = PhraseRoot.createClass( root1 ).createRoot opts1, (token, notice) -> 

                    notice.use (msg, next) -> 
                        msg.skipChange = true
                        next()


                recursor1( 'phrase', phrase1 ).then -> 

                    recursor1( 'phrase', phrase2 ).then -> 

                        ChangeSet = ChangeSetFactory.createClass root1
                        compare( 
                            root1.context.tree
                            root1.context.trees.latest
                        )
                        
                


            done()

        context 'collection', -> 

            it 'removes old changesets from the collection', (done) -> 

                Test

                    phrase1: (nested) -> 
                        nested 'nested phrase 1', (end) -> 
                            end()
                        nested 'deletes this', (end) -> 
                            end()

                    phrase2: (nested) -> 
                        nested 'nested phrase 1', (end) -> 
                            end()


                    (treeA, treeB) -> 

                        set1 = new ChangeSet treeA, treeB
                        set2 = new ChangeSet treeA, treeB
                        set3 = new ChangeSet treeA, treeB
                        set4 = new ChangeSet treeA, treeB
                        set5 = new ChangeSet treeA, treeB

                        set6 = new ChangeSet treeA, treeB

                        ChangeSet.applyChanges( set5.uuid, 'AtoB' ).then(

                                                #
                                                # set5 was removed when set6 was created:
                                                # (historyLength hardcoded to 1 for now)
                                                # 

                            (result) ->
                            (error) -> 
                                error.should.match /has no set with uuid/

                                #
                                # set6 should still be in there
                                #

                                ChangeSet.applyChanges( set6.uuid, 'AtoB' ).then (result) -> 

                                    #
                                    # resolved ok
                                    # 

                                    done()

                        )


        xcontext 'detecting changes', ->

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


                    (treeA, treeB) -> 

                        set = new ChangeSet treeA, treeB
                        should.exist set.changes.deleted['/TEST/phrase/nested/deletes this']
                        done()


            it 'detects leaf becoming branch vertex', (done) -> 

                Test

                    phrase1: (nested) -> 
                        nested 'nested phrase 1', (end) -> 
                            end()

                    phrase2: (nested) -> 
                        nested 'nested phrase 1', (more) -> 
                            more 'more', (end) ->


                    (treeA, treeB) -> 

                        set = new ChangeSet treeA, treeB
                        should.exist set.changes.updated['/TEST/phrase/nested/nested phrase 1']
                        set.changes.updated['/TEST/phrase/nested/nested phrase 1'].type.should.eql 

                            from: 'leaf'
                            to: 'vertex'

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


                    (treeA, treeB) -> 

                        set = new ChangeSet treeA, treeB

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

                    (treeA, treeB) -> 

                        set = new ChangeSet treeA, treeB
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


                    (treeA, treeB) -> 

                        set = new ChangeSet treeA, treeB
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

                    (treeA, treeB) -> 

                        set = new ChangeSet treeA, treeB
                        
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


                    (treeA, treeB) -> 

                        set = new ChangeSet treeA, treeB

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


                    (treeA, treeB) -> 

                        set = new ChangeSet treeA, treeB

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


                    (treeA, treeB) -> 

                        set = new ChangeSet treeA, treeB
                        updates = set.changes.updated
                        updates['/TEST/phrase/nested/updates this'].hooks.should.eql
                            beforeAll:
                                timeout: 
                                    from: 100
                                    to: 200

                        #GREP2 
                        should.exist updates['/TEST/phrase/nested/updates this'].target
                        done()
                    

        xcontext 'applying changes (A-B)', -> 

            it 'applies changes into treeA and preserves vertex uuid', (done) ->

                Test

                    phrase1: (nested) -> 
                        nested 'nested phrase 1', uuid: 1111,               (end) -> 1
                        nested 'nested phrase 2', uuid: 2222, timeout: 100, (end) -> 1

                    phrase2: (nested) -> 
                        nested 'nested phrase 1',               (end) -> 'NEW'
                        nested 'nested phrase 2', timeout: 200, (end) -> 2

                    (treeA, treeB) -> 


                        set = new ChangeSet treeA, treeB

                        set.AtoB()

                        treeA.vertices[1111].fn().should.equal 'NEW'
                        treeA.vertices[2222].timeout.should.equal 200
                        done()


            it 'applies hook changes to all affected vertexes', (done) -> 

                Test

                    phrase1: (nested) -> 

                        before all: -> 1

                        nested 'nested phrase 1', uuid: 1111, (end) -> 
                        nested 'nested phrase 2', uuid: 2222, (end) -> 

                    phrase2: (nested) -> 

                        before all: -> 'UPDATED'

                        nested 'nested phrase 1', (end) -> 
                        nested 'nested phrase 2', (end) -> 

                    (treeA, treeB) -> 

                        set = new ChangeSet treeA, treeB

                        set.AtoB()

                        treeA.vertices[1111].hooks.beforeAll.fn().should.equal 'UPDATED'
                        treeA.vertices[2222].hooks.beforeAll.fn().should.equal 'UPDATED'
                        done()

                
            it 'created hooks are assigned uuid, timeout, fn and copied into all children', (done) -> 

                Test

                    phrase1: (nested) -> 


                        nested 'nested phrase 1', uuid: 1111, (end) -> 
                        nested 'nested phrase 2', uuid: 2222, (end) -> 

                    phrase2: (nested) -> 

                        before all: -> 'NEW'

                        nested 'nested phrase 1', (end) -> 
                        nested 'nested phrase 2', (end) -> 

                    (treeA, treeB) -> 

                        set = new ChangeSet treeA, treeB

                        set.AtoB() 

                        # console.log treeA.vertices[1111].hooks.beforeAll
                        # console.log treeA.vertices[2222].hooks.beforeAll
                        treeA.vertices[1111].hooks.beforeAll.fn().should.equal 'NEW'
                        treeA.vertices[2222].hooks.beforeAll.should.equal treeA.vertices[2222].hooks.beforeAll
                        done()


            it 'deletes vertices (leaf)', (done) -> 


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

                    (treeA, treeB) -> 

                        set = new ChangeSet treeA, treeB
                        set.AtoB()
                        should.not.exist treeA.vertices[1111]
                        should.not.exist treeA.vertices[9999]
                        treeA.vertices[2222].fn().should.equal 'not allowing uuid re-assign for now'
                        done()


            it 'deletes vertices (branch)', (done) -> 

                Test

                    phrase1: (nested) -> 

                        nested 'nested phrase 1', uuid: 1111, (end) -> 
                        nested 'nested phrase 2', uuid: 2222, (deeper) ->
                            deeper 'one', uuid: 3333, (end) ->
                            deeper 'two', uuid: 4444, (end) ->  

                    phrase2: (nested) -> 

                        nested 'nested phrase 1', (end) -> 

                    (treeA, treeB) -> 

                        set = new ChangeSet treeA, treeB

                        set.AtoB()

                        should.exist     treeA.vertices[1111]
                        should.not.exist treeA.vertices[2222]
                        should.not.exist treeA.vertices[3333]
                        should.not.exist treeA.vertices[4444]
                        done()


            it 'creates vertices (leaf)', (done) -> 

                Test

                    phrase1: (nested) -> 

                        nested 'nested phrase 1', uuid: 1111, (end) -> 0
                        

                    phrase2: (nested) -> 

                        nested 'nested phrase 1',             (end) -> 1
                        nested 'nested phrase 2', uuid: 2222, (end) -> 2


                    (treeA, treeB) -> 

                        set = new ChangeSet treeA, treeB
                        set.AtoB()
                        treeA.vertices[1111].fn().should.equal 1
                        treeA.vertices[2222].fn().should.equal 2
                        done()


            it 'creates vertices (branch)', (done) -> 

                Test

                    phrase1: (nested) -> 

                        nested 'nested phrase 1', uuid: 1111, (end) -> 
                        

                    phrase2: (nested) -> 

                        nested 'nested phrase 1', (end) -> 
                        nested 'nested phrase 2', uuid: 2222, (deeper) ->
                            deeper 'one', uuid: 3333, (end) ->
                            deeper 'two', uuid: 4444, (end) ->  

                    (treeA, treeB) -> 

                        set = new ChangeSet treeA, treeB
                        set.AtoB()

                        should.exist     treeA.vertices[1111]
                        should.exist     treeA.vertices[2222]
                        should.exist     treeA.vertices[3333]
                        should.exist     treeA.vertices[4444]
                        done()


            it 'creates vertices into ex leaf (leaf flag becomes false)', (done) -> 

                Test

                    phrase1: (nested) -> 

                        nested 'nested phrase 1', uuid: 1111, (end) -> 


                    phrase2: (nested) -> 

                        nested 'nested phrase 1', (deeper) ->
                            deeper 'one', uuid: 2222, (end) ->
                            deeper 'two', uuid: 3333, (end) ->  

                    (treeA, treeB) -> 

                        set = new ChangeSet treeA, treeB
                        set.AtoB()
                        treeA.vertices[1111].token.type.should.equal 'vertex'
                        done()


            it 'deletes vertices from ex branch (leaf flag becomes true)', (done) -> 

                Test

                    phrase1: (nested) -> 

                        nested 'nested phrase 1', uuid: 1111, (deeper) -> 
                            deeper 'one', uuid: 2222, (end) ->
                            deeper 'two', uuid: 3333, (end) ->  


                    phrase2: (nested) -> 

                        nested 'nested phrase 1', (end) ->

                    (treeA, treeB) -> 

                        set = new ChangeSet treeA, treeB
                        set.AtoB()
                        treeA.vertices[1111].token.type.should.equal 'leaf'
                        should.not.exist treeA.vertices[2222]
                        should.not.exist treeA.vertices[3333]
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

                    (treeA, treeB) -> 

                        set = new ChangeSet treeA, treeB
                        set.AtoB()

                        should.not.exist treeA.path2uuid['/TEST/phrase/nested/nested phrase 1/deeper/deleted']
                        should.not.exist treeA.uuid2path['deleted']

                        treeA.path2uuid.should.eql 

                            '/TEST/phrase': ROOTUUID
                            '/TEST/phrase/nested/nested phrase 1': 1111
                            '/TEST/phrase/nested/nested phrase 2': 2222
                            '/TEST/phrase/nested/nested phrase 2/deeper/one': 3333
                            '/TEST/phrase/nested/nested phrase 2/deeper/two': 4444

                            '/TEST/phrase/nested/nested phrase 2/deeper/created': 9999

                        treeA.uuid2path[ROOTUUID].should.equal '/TEST/phrase'
                        treeA.uuid2path['1111'].should.equal '/TEST/phrase/nested/nested phrase 1'
                        treeA.uuid2path['2222'].should.equal '/TEST/phrase/nested/nested phrase 2'
                        treeA.uuid2path['3333'].should.equal '/TEST/phrase/nested/nested phrase 2/deeper/one'
                        treeA.uuid2path['4444'].should.equal '/TEST/phrase/nested/nested phrase 2/deeper/two'
                        treeA.uuid2path['9999'].should.equal '/TEST/phrase/nested/nested phrase 2/deeper/created'                   
                        
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

                    (treeA, treeB) -> 

                        set = new ChangeSet treeA, treeB
                        set.AtoB()

                        children = {}
                        for parent of treeA.children
                            children[parent] = []
                            for child in treeA.children[parent]
                                children[parent].push child

                        children[ROOTUUID].should.eql  [ 1111, 2222       ]
                        children['2222'].should.eql    [ 9999, 3333, 4444 ]

                                                    #
                                                    # preserved child vertex order
                                                    #   

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

                    (treeA, treeB) -> 

                        set = new ChangeSet treeA, treeB
                        set.AtoB()

                        treeA.parent.should.eql 

                            '1111': ROOTUUID
                            '2222': ROOTUUID
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

                    (treeA, treeB) -> 

                        set = new ChangeSet treeA, treeB
                        set.AtoB()

                        treeA.leaves.should.eql [ 1111, 9999, 3333, 4444 ]
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

                    (treeA, treeB) -> 

                        set = new ChangeSet treeA, treeB
                        set.AtoB()
                        treeA.edges.should.eql 

                        treeA.edges['1111'  ].should.eql [ { to: ROOTUUID }, { to: 'kept' }                           ]
                        treeA.edges['2222'  ].should.eql [ { to: ROOTUUID }, { to: 3333 }, { to: 4444 }, { to: 9999 } ]
                        treeA.edges['3333'  ].should.eql [ { to: 2222 }                                             ]
                        treeA.edges['4444'  ].should.eql [ { to: 2222 }                                             ]
                        treeA.edges['9999'  ].should.eql [ { to: 2222 }                                             ]
                        treeA.edges[ROOTUUID].should.eql [ { to: 1111 }, { to: 2222 }                               ]
                        treeA.edges.kept.should.eql    [ { to: 1111 }                                             ]

                        
                        done()


