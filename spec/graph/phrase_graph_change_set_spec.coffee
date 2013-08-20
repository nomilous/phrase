should               = require 'should'
PhraseGraphChangeSet = require '../../lib/graph/phrase_graph_change_set'

describe 'PhraseGraphChangeSet', -> 

    before -> 

        @ChangeSet = PhraseGraphChangeSet.createClass {}


    it '', -> console.log @ChangeSet
