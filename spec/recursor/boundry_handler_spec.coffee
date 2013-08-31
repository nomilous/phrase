should             = require 'should'
BoundryHandler     = require '../../lib/recursor/boundry_handler'
#PhraseTokenFactory = require '../../lib/token/phrase_token'
phrase             = require '../../lib/phrase'

describe 'TreeBoundry', -> 

    beforeEach -> 

        @root = context: stack: []
        @root.context.notice = event: (title, payload) -> 
        #@root.context.PhraseToken = PhraseTokenFactory.createClass @root


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
            BoundryHandler.link @root, directory: './spec'

        context 'linkDirectory()', -> 

            xcontext 'finds files', -> 

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

            xcontext 'flow control', -> 

                it 'returs a promise', (done) -> 

                    should.exist BoundryHandler.linkDirectory( @root, directory: __dirname ).then
                    done()


            context 'recursor stack and graph assembly', -> 


                xit 'pushes and pops onto the recursor stack', (done) -> 

                    @root.context.stack = 

                        push: -> done()
                        pop:  -> throw 'go no further'

                    BoundryHandler.linkDirectory( @root, directory: __dirname ).then(

                        ->
                        (e) -> #console.log e
                    )

                xit 'queries message bus for uuid', (done) -> 

                    @root.context.notice = event: (title, payload) -> 

                        title.should.equal 'phrase::boundry:query'
                        done()
                        throw 'go no further'

                    BoundryHandler.linkDirectory( @root, directory: __dirname )

                xit 'defaults to not walk across the boundry', (done) -> 

                    @root.context.notice = event: (title, payload) -> 

                        payload.follow.should.equal false
                        done()
                        throw 'go no further'

                    BoundryHandler.linkDirectory( @root, directory: __dirname )


                it 'and defaults to uuid.v1'


                it 'emit phrase::edge:create onto the message bus'

                    # 
                    # PhraseGraph is listening... 
                    # 


    xcontext 'integration', -> 

        it 'works', (done) -> 

            recursor = phrase.createRoot

                title:   'Title'
                uuid:    'UUID'
                boundry: ['matchThisForBoundry']

                (accessToken, messageBus) -> 

                    i = 1000000

                    messageBus.use (msg, next) -> 

                        if msg.context.title == 'phrase::boundry:assemble'
                            
                            msg.token.uuid = "REMOTE-UUID#{  i++  }" 

                        next()

                    accessToken.on 'ready', ({tokens}) -> 

                        console.log tokens

            recursor 'outer', (edge) -> 

                edge.link directory: __dirname


