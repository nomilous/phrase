should = require 'should'
BoundryHandler = require '../../lib/recursor/boundry_handler'

describe 'TreeBoundry', -> 


    it 'defines link() to recurse a boundry phrase', (done) ->  

        BoundryHandler.link.should.be.an.instanceof Function
        done()


    context 'link() as directory', -> 

        beforeEach -> 
            @directory = BoundryHandler.linkDirectory

        afterEach -> 
            BoundryHandler.linkDirectory = @directory


        it 'calls linkDirectory()', (done) -> 

            BoundryHandler.linkDirectory = -> done()
            BoundryHandler.link directory: './spec'


        it 'recurses for files with name match'
        it 'places a PhraseToken (type=remote) for each match into the parent phrase'

        
