should = require 'should'
BoundryHandler = require '../../lib/recursor/boundry_handler'

describe 'TreeBoundry', -> 


    it 'defines link() to recurse a boundry phrase', (done) ->  

        BoundryHandler.link.should.be.an.instanceof Function
        done()


    context 'link() as directory', -> 

        beforeEach -> 
            @directory = BoundryHandler.linkDirectory
            @recurse   = BoundryHandler.recurse

        afterEach -> 
            BoundryHandler.linkDirectory = @directory
            BoundryHandler.recurse = @recurse


        it 'calls linkDirectory()', (done) -> 

            BoundryHandler.linkDirectory = -> done()
            BoundryHandler.link {}, directory: './spec'

        context 'linkDirectory()', ->

            it 'calls recure with default regex', (done) -> 

                BoundryHandler.recurse = (path, regex) -> 

                    path.should.match /phrase\/spec\/recursor$/
                    should.exist 'file.name.coffee'.match regex
                    done()

                BoundryHandler.linkDirectory {}, directory: __dirname


        it 'places a PhraseToken (type=remote) for each match into the parent phrase', (done) -> 

                root = {}

                BoundryHandler.linkDirectory root, directory: __dirname
