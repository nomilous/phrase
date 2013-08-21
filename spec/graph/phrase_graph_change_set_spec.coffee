should               = require 'should'
PhraseGraphChangeSet = require '../../lib/graph/phrase_graph_change_set'
PhraseGraph          = require '../../lib/graph/phrase_graph'

describe 'PhraseGraphChangeSet', -> 

    beforeEach -> 

        @root = 
            context: 
                notice: 
                    event: ->
                    use: ->

        @ChangeSet  = PhraseGraphChangeSet.createClass @root
        Graph       = PhraseGraph.createClass @root
        @graphA     = new Graph
        @graphB     = new Graph


    it 'creates a changeSet with uuid', (done) -> 

        set1 = new @ChangeSet @graphA, @graphB
        set2 = new @ChangeSet @graphA, @graphB

        should.exist = set1.changes.uuid
        should.exist = set2.changes.uuid
        set1.changes.uuid.should.not.equal set2.changes.uuid
        done()

    it 'can have no changes', (done) -> 

        set1 = new @ChangeSet @graphA, @graphB

        should.not.exist set1.changes.created
        should.not.exist set1.changes.updated
        should.not.exist set1.changes.deleted
        done()
