should         = require 'should'
RecursorLeaf   = require '../../../lib/phrase/recursor/leaf'
PhraseNode     = require '../../../lib/phrase_node'


describe 'RecursorLeaf', -> 

    context 'detect()', ->

        root = undefined

        beforeEach -> 

            root = 

                util: require('also').util

        it 'detects leaf phrases when phrase fn arg1 is "end"', (done) -> 

            phrase = new PhraseNode fn: (end) -> 
            leaf   = RecursorLeaf.create root
            leaf.detect phrase, (isLeaf) ->

                isLeaf.should.equal true
                done()

        it 'detects not leaf when phrase fn arg1 is not "end"', (done) ->

            phrase = new PhraseNode fn: (other) -> 
            leaf   = RecursorLeaf.create root
            leaf.detect phrase, (isLeaf) ->

                isLeaf.should.equal false
                done()


        it 'marks the phrase as a leaf', (done) -> 

            phrase = new PhraseNode fn: (end) -> 
            leaf   = RecursorLeaf.create root
            leaf.detect phrase, (isLeaf) ->

                phrase.leaf.should.equal true
                done()

        it 'marks the phrase as not a leaf', (done) -> 

            phrase = new PhraseNode fn: (other) -> 
            leaf   = RecursorLeaf.create root
            leaf.detect phrase, (isLeaf) ->

                phrase.leaf.should.equal false
                done()

