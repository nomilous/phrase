should               = require 'should'
PhraseGraphChangeSet = require '../../lib/graph/phrase_graph_change_set'
PhraseGraph          = require '../../lib/graph/phrase_graph'
PhraseToken          = require '../../lib/phrase_token'
PhraseNode           = require '../../lib/phrase_node'
PhraseRecursor       = require '../../lib/phrase/phrase_recursor'
Notice               = require 'notice'
also                 = require 'also'

describe 'PhraseGraphChangeSet', -> 

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

    context 'general', ->

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


        context 'detecting changes', ->


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

                        done()
                    

        context 'applying changes (A-B)', -> 

            it 'applies changes into graphA and preserves vertex uuid', (done) ->

                Test

                    phrase1: (nested) -> 
                        nested 'nested phrase 1', uuid: 1111,               (end) -> 1
                        nested 'nested phrase 2', uuid: 2222, timeout: 100, (end) -> 1

                    phrase2: (nested) -> 
                        nested 'nested phrase 1',               (end) -> 'NEW'
                        nested 'nested phrase 2', timeout: 200, (end) -> 2

                    (graphA, graphB) -> 

                        set = new ChangeSet graphA, graphB

                        set.AtoB().then -> 

                            graphA.vertices[1111].fn().should.equal 'NEW'
                            graphA.vertices[2222].timeout.should.equal 200
                            done()


            it 'preserves vertex order'

            context 'updates indexes', -> 



        context 'applying changes (B-A)', -> 

            #
            # later...
            #

            it 'can undo the  changes applies in A-B'



    context 'collection', -> 

        it 'removes old changesets from the collection'


