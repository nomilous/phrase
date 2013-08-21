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


    context 'change detection', -> 

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
                    timeout: 1000

                #
                # load runtime
                #

                root                     = also
                root.timeout             = 1000
                root.context             = {}
                root.context.stack       = []
                root.context.notice      = Notice.create opts.uuid
                root.context.PhraseGraph = PhraseGraph.createClass root
                root.context.PhraseNode  = PhraseNode.createClass root
                root.context.token       = PhraseToken.create root
                ChangeSet               = PhraseGraphChangeSet.createClass root
                graph1                   = undefined

                root.context.notice.use (msg, next) -> 

                    return next() unless msg.context.title == 'phrase::recurse:end'

                    if graph1?

                        graph2 = root.context.graphs.latest
                        compare graph1, graph2
                        return
                            
                    graph1 = root.context.graphs.latest 
                    next()

                    

                PhraseRecursor.walk( root, opts, 'phrase', phrase1 ).then ->
                
                    PhraseRecursor.walk root, opts, 'phrase', phrase2


            done()




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


                (graph1, graph2) -> 

                    set = new ChangeSet graph1, graph2
                    should.exist set.changes.deleted['/TEST/phrase/nested/deletes this']
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

                (graph1, graph2) -> 

                    set = new ChangeSet graph1, graph2
                    should.exist set.changes.created['/TEST/phrase/nested/creates this']
                    done()



        it 'detects updated leaves', (done) -> 

            Test

                phrase1: (nested) -> 
                    nested 'nested phrase 1', (end) -> 
                        end()

                phrase2: (nested) -> 
                    nested 'nested phrase 1', (end) ->
                        end() + 1

                (graph1, graph2) -> 

                    set = new ChangeSet graph1, graph2
                    should.exist set.changes.updated['/TEST/phrase/nested/nested phrase 1']
                    done()
                    


    context 'collection', -> 

        it 'removes old changesets from the collection'


