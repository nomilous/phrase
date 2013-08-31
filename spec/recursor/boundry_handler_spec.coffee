should             = require 'should'
BoundryHandler     = require '../../lib/recursor/boundry_handler'
#PhraseTokenFactory = require '../../lib/token/phrase_token'
phrase             = require '../../lib/phrase'

describe 'TreeBoundry', -> 

    beforeEach -> 

        @root = context: stack: []
        #@root.context.PhraseToken = PhraseTokenFactory.createClass @root


    it 'defines link() to recurse a boundry phrase', (done) ->  

        BoundryHandler.link.should.be.an.instanceof Function
        done()


    xcontext 'link() as directory', -> 

        beforeEach -> 
            @directory = BoundryHandler.linkDirectory
            @recurse   = BoundryHandler.recurse

        afterEach -> 
            BoundryHandler.linkDirectory = @directory
            BoundryHandler.recurse = @recurse


        it 'calls linkDirectory()', (done) -> 

            BoundryHandler.linkDirectory = -> done()
            BoundryHandler.link @root, directory: './spec'

        context 'linkDirectory()', ->

            it 'calls recure with default regex', (done) -> 

                BoundryHandler.recurse = (path, regex) -> 

                    path.should.match /phrase\/spec\/recursor$/
                    should.exist 'file.name.coffee'.match regex
                    done()
                    return []

                BoundryHandler.linkDirectory @root, directory: __dirname


            it 'finds matches', (done) -> 

                files = @recurse __dirname, /\.coffee$/
                files.map( 

                    (f) -> f.replace __dirname, '.'

                ).should.eql [

                    './boundry_handler_spec.coffee',
                    './control/after_all_spec.coffee',
                    './control/after_each_spec.coffee',
                    './control/before_all_spec.coffee',
                    './control/before_each_spec.coffee',
                    './control_spec.coffee',
                    './tree_walker_spec.coffee'

                ]
                done()

            it 'finds no tea', (done) ->

                @recurse( __dirname, /\.tea$/ ).should.eql []
                done()


            it 'returs a promise', (done) -> 

                should.exist BoundryHandler.linkDirectory( @root, directory: __dirname ).then
                done()


            it 'pushes and pops onto the recursor stack', (done) -> 

                @root.context.stack = 

                    push: -> done()
                    pop:  -> throw 'go no further'

                BoundryHandler.linkDirectory( @root, directory: __dirname ).then(

                    ->
                    (e) -> #console.log e
                )


            xit 'emit phrase::edge:create onto the message bus', (done) -> 

                #
                # PhraseGraph is listening... 
                # 


    context 'integration', -> 

        it 'works', (done) -> 

            recursor = phrase.createRoot

                title:   'Title'
                uuid:    'UUID'
                boundry: ['matchThisForBoundry']

                (accessToken) -> accessToken.on 'ready', ({tokens}) -> 

                    console.log tokens

            recursor 'outer', (edge) -> 

                console.log edge.link

                edge.link directory: __dirname


