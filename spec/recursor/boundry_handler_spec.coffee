should             = require 'should'
BoundryHandler     = require '../../lib/recursor/boundry_handler'
#PhraseTokenFactory = require '../../lib/token/phrase_token'
fs                 = require 'fs'
phrase             = require '../../lib/phrase'

describe 'TreeBoundry', -> 

    beforeEach -> 

        @root = context: stack: []
        @root.context.notice = event: (title, payload) -> 
        #@root.context.PhraseToken = PhraseTokenFactory.createClass @root

        @readdirSync = fs.readdirSync

    afterEach ->

        fs.readdirSync = @readdirSync

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


            xcontext 'recursor stack and graph assembly', -> 

                beforeEach -> 

                    @root.context.notice = @notice = require(

                        'notice' ).create 'test with actual message bus'


                it 'uses the message bus as assembly line to create each boundry phrase', (done) -> 

                    #
                    # This means that networks / databases can be directly involved in 
                    # the assembly of composite PhraseTrees.
                    #

                    @notice.use (msg, next) -> 

                        if msg.context.title == 'phrase::boundry:assemble' 

                            msg.opts.type.should.equal      'directory'
                            msg.opts.filename.should.match   new RegExp __dirname
                            msg.opts.stackpath.should.equal  'TODO'

                            done()
                            throw 'go no further'

                        next()

                    BoundryHandler.linkDirectory( @root, directory: __dirname )


                it 'uses the assembly result to create the phrase and boundry token'

                it 'defaults to uuid.v1 if not specified on assembly line'


                xit 'pushes and pops onto the recursor stack', (done) -> 

                    @root.context.stack = 

                        push: -> done()
                        pop:  -> throw 'go no further'

                    BoundryHandler.linkDirectory( @root, directory: __dirname ).then(

                        ->
                        (e) -> #console.log e
                    )


                it 'emits phrase::edge:create onto the message bus'

                    # 
                    # PhraseGraph is listening... 
                    # 


            context 'boundry type', -> 

                beforeEach -> 

                    @root.context.notice = @notice = require(

                        'notice' ).create 'test with actual message bus'


                xit 'rejects on mixed boundry modes', (done) -> 

                    @notice.use (msg, next) -> 
                        if msg.context.title == 'phrase::boundry:assemble'
                            msg.opts.mode = 'refer'
                            msg.opts.mode = 'nest' if msg.opts.filename.match /boundry_handler_spec/
                        next()

                    BoundryHandler.linkDirectory( @root, directory: __dirname ).then(

                        -> 
                        (error) -> 

                            error.should.match /Mixed boundry modes not supported/
                            done()

                    )


                context 'As Nest', -> 

                    beforeEach -> 
                        @notice.use (msg, next) -> 
                            if msg.context.title == 'phrase::boundry:assemble'
                                msg.opts.mode = 'nest'
                            next()


                    xit 'sends phrase::nest back to the recursor', (done) -> 

                        BoundryHandler.linkDirectory( @root, directory: __dirname ).then(

                            ->
                            (error) -> console.log UNEXPECTED_ERROR_B: error, file: __filename
                            (notify) -> 

                                notify.action.should.equal 'phrase::nest'
                                done()

                        )


                    xit 'phrase::nest contains a resolver to callback "done"', (done) -> 

                        BoundryHandler.linkDirectory( @root, directory: __dirname ).then(

                            (result) -> done()
                            (error)  -> console.log UNEXPECTED_ERROR_B: error, file: __filename
                            (notify) -> 

                                notify.done.should.be.an.instanceof Function
                                notify.done()

                        )


                    xit 'phrase::nest contains the new phrase to recurse into', (done) -> 

                        BoundryHandler.linkDirectory( @root, directory: __dirname ).then(

                            (result) -> 
                            (error)  -> console.log UNEXPECTED_ERROR_C: error, file: __filename
                            (notify) -> 

                                notify.phrase.should.be.an.instanceof Function
                                notify.phrase()
                                done()

                        )


                    it 'running the new phrase through the async injector will resume the recustion', (done) -> 

                        #
                        # assemble mock phrase 
                        #
                        count1 = 1
                        count2 = 1
                        @notice.use (msg, next) -> 
                            if msg.context.title == 'phrase::boundry:assemble'
                                msg.phrase = 
                                    title: msg.opts.filename.split('/')[-1..].join ''
                                    opts: 
                                        uuid: count1++
                                    fn: -> 
                                        return "RETURN FROM PHRASE_#{ count2++ }"
                                        
                            next()

                        RESULTS = []
                        BoundryHandler.linkDirectory( @root, directory: __dirname ).then(

                            ->
                            ->
                            (notify) -> 

                                #
                                # the new phrase can be mapped onto the 
                                #

                                notify.phrase (phraseTitle, phraseControl, phraseFn) -> 

                                    RESULTS.push phraseFn ->
                                    if phraseControl.uuid == 3
                                        
                                        RESULTS.should.eql [
                                            'RETURN FROM PHRASE_1'
                                            'RETURN FROM PHRASE_2'
                                            'RETURN FROM PHRASE_3'
                                        ]
                                        done()
                        )


                context 'refer', -> 

                    it "boundry token carries reference to the 'other' tree"


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


