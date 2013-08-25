should         = require 'should'
RecursorLeaf   = require '../../../lib/phrase/recursor/leaf'
PhraseNode     = require '../../../lib/phrase_node'


describe 'RecursorLeaf', -> 

    context 'detect()', ->

        root    = undefined
        control = undefined

        beforeEach -> 

            root = 

                util: require('also').util

            @Node = PhraseNode.createClass root

            control = 
                leaf: ['end', 'done', 'slurp']

        it 'detects leaf phrases when phrase fn arg1 is in control.leaf', (done) -> 
        
            phrase = new @Node 
                token: {}
                text: ''
                uuid: '1111'
                fn: (slurp) -> 

            leaf   = RecursorLeaf.create root, control
            leaf.detect phrase, (isLeaf) ->

                isLeaf.should.equal true
                done()

        it 'detects not leaf when phrase fn arg1 is not in control.leaf', (done) ->

            phrase = new @Node 
                token: {}
                text: ''
                uuid: '1111'
                fn: (other) -> 
            leaf   = RecursorLeaf.create root, control
            leaf.detect phrase, (isLeaf) ->

                isLeaf.should.equal false
                done()


        it 'marks the phrase as a leaf', (done) -> 

            phrase = new @Node 
                token: uuid: '1111'
                text: ''
                fn: (end) -> 
            leaf   = RecursorLeaf.create root, control
            leaf.detect phrase, (isLeaf) ->

                phrase.leaf.should.equal true
                done()

        it 'marks the phrase as not a leaf', (done) -> 

            phrase = new @Node 
                token: {}
                uuid: '1111'
                text: ''
                fn: (other) -> 
            leaf   = RecursorLeaf.create root, control
            leaf.detect phrase, (isLeaf) ->

                phrase.leaf.should.equal false
                done()

