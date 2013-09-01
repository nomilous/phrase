should              = require 'should'
RecursorBeforeEach  = require '../../../lib/recursor/control/before_each'
PhraseNode          = require '../../../lib/phrase/node'
PhraseTokenFactory  = require '../../../lib/token/phrase_token' 
BoundryHandler      = require '../../../lib/recursor/boundry_handler'


describe 'RecursorBeforeEach', -> 

    root             = undefined
    injectionControl = undefined
    parent           = undefined

    beforeEach -> 

        root = 
            context: 
                stack: []

                #
                # mock notice pipeline
                #
                notice: 
                    info: -> then: (resolve) -> resolve()
                    event: -> then: (resolve) -> resolve()

                PhraseNode: PhraseNode.createClass root
                PhraseToken: PhraseTokenFactory.createClass root

            util: require('also').util

        injectionControl = 
            defer: resolve: ->
            args: ['phrase title', {}, (nested) -> ]

        parent = 
            phraseToken: signature: 'it'
            phraseType: -> 'leaf' 

        @phraseToken    = PhraseTokenFactory.createClass
        @boundryLink    = BoundryHandler.link
        @boundryRecurse = BoundryHandler.recurse

    afterEach ->

        PhraseTokenFactory.createClass = @phraseToken
        BoundryHandler.link = @boundryLink
        BoundryHandler.recurse = @boundryRecurse

    context 'recursion control -', ->


        it 'extracts the injection deferral', (done) -> 
            
            Object.defineProperty injectionControl, 'defer', 
                get: -> 
                    done()
                    throw 'go no further'

            hook = RecursorBeforeEach.create root, parent
            try hook (->), injectionControl


        it 'calls the hook resolver', (done) -> 

            hook = RecursorBeforeEach.create root, parent
            hook done, injectionControl


        it 'hands error into injectionControl deferral if phraseTitle contains /', (done) -> 

            root.context.stack.push new root.context.PhraseNode

                token: signature: 'context'
                title: 'the parent phrase'
                fn: ->

            parent.phraseToken = signature: 'it'
            hook = RecursorBeforeEach.create root, parent
            injectionControl.args = [ 'does not allow / in phraseTitle', { uuid: 'UUID' }, (end) -> ]

            hook ( (result) ->

                #SUSPECT1
                # 
                # return unless result?
                # unless result? then console.log (new Error '').stack

                result.should.be.an.instanceof Error
                result.should.match /INVALID title/
                done()

            ), injectionControl


        it 'attaches phraseToken to phraseControl for injection at arg2', (done) -> 

            parentPhraseFn = (glia) -> 

            injectionControl.args = [ 'parent phrase title', { key: 'VALUE' }, parentPhraseFn ]
            hook = RecursorBeforeEach.create root, parent

            hook (-> 

                injectionControl.args[1].phraseToken.signature.should.equal 'glia'
                done()

            ), injectionControl




        it 'ensures injection function as lastarg is at arg3 if phrase is not a leaf or boundry', (done) -> 

            nestedPhraseFn = -> 
            parent.phraseType = -> 'vertex'

            hook = RecursorBeforeEach.create root, parent

            injectionControl.args = [ 'phrase title', { phrase: 'control' }, nestedPhraseFn ]
            hook (-> 
                injectionControl.args[2].should.equal nestedPhraseFn
            ), injectionControl


            injectionControl.args = [ 'phrase title', nestedPhraseFn ]
            hook (-> 
                injectionControl.args[2].should.equal nestedPhraseFn
            ), injectionControl


            injectionControl.args = [ nestedPhraseFn ]
            hook (-> 
                injectionControl.args[2].should.equal nestedPhraseFn
                done()
            ), injectionControl


        it 'replaces injection function with noop if phrase is a leaf', (done) -> 

            #
            #  or boundry (not tested)
            #


            root.context.stack.push new root.context.PhraseNode

                token: signature: 'context'
                title: 'the parent phrase'
                fn: ->

            nestedPhraseFn = -> 'not noop'
            hook = RecursorBeforeEach.create root, parent
            injectionControl.args = [ 'phrase title', { phrase: 'control' }, nestedPhraseFn ]
            hook (-> 

                injectionControl.args[2].toString().should.match /function \(\) {}/
                done()

            ), injectionControl




    context 'phrase type control -', ->


        it 'gets the phrase type', (done) -> 

            nestedPhraseFn = -> 
            injectionControl.args = [ 'phrase title', { key: 'VALUE' }, nestedPhraseFn ]

            parent.phraseType = (fn) ->

                fn.should.equal nestedPhraseFn
                done()

            hook = RecursorBeforeEach.create root, parent
            hook (->), injectionControl

        it 'creates the first phrase a Token as root', (done) -> 

            injectionControl.args = [ 'something', { key: 'VALUE' }, -> ]
            parent.phraseToken = signature: 'describe', uuid: 'uuid'
            hook = RecursorBeforeEach.create root, parent
            hook (->

                root.context.stack[0].token.type.should.equal      'root'
                root.context.stack[0].token.signature.should.equal 'describe'
                root.context.stack[0].token.uuid.should.equal      'uuid'
                done()

            ), injectionControl

        it 'creates each subsequent phrase a Token according to type with signature and uuid', (done) -> 

            root.context.stack.push new root.context.PhraseNode

                token: signature: 'describe'
                title: 'the parent phrase'
                fn: ->

            injectionControl.args = [ 'phrase title', { uuid: 'uuid', key: 'VALUE' }, -> ]
            parent.phraseToken = signature: 'it', uuid: 'uuid'
            hook = RecursorBeforeEach.create root, parent
            hook (->

                root.context.stack[1].token.type.should.equal      'leaf'
                root.context.stack[1].token.signature.should.equal 'it'
                root.context.stack[1].token.uuid.should.equal      'uuid'
                done()

            ), injectionControl


        it 'can assign uuid from phraseControl for non root phrases', (done) -> 

            root.context.stack.push new root.context.PhraseNode

                token: signature: 'context'
                title: 'the parent phrase'
                fn: ->

            injectionControl.args = [ 'is a leaf phrase', { uuid: 'UUID' }, (end) -> ]
            parent.phraseToken = signature: 'it'
            hook = RecursorBeforeEach.create root, parent

            hook (-> 

                root.context.stack[1].uuid.should.equal 'UUID'
                done()

            ), injectionControl


        it 'does not assign uuid from parent phraseToken if not root phrase', (done) -> 

            injectionControl.args = [ 'phrase title', { key: 'VALUE' }, -> ]
            parent.phraseToken = signature: 'it', uuid: 'UUID'
            root.context.stack[0] = new root.context.PhraseNode

                token: signature: 'describe'
                title: 'use case one'
                uuid: '000000'
                fn: ->

            injectionControl.defer = resolve: ->

            hook = RecursorBeforeEach.create root, parent
            hook (->

                root.context.stack[1].uuid.should.not.equal 'UUID'
                done()

            ), injectionControl


    context 'stack and graph assembly -', ->


        it 'pushes the new phrase into the stack and resolves the injection deferral if leaf', (done) -> 

            #
            # or boundry (not tested)
            #

            nestedPhraseFn = ->
            phraseHookFn = ->

            root.context.stack.push new root.context.PhraseNode

                token: signature: 'describe'
                title: 'the parent phrase'
                fn: ->

            injectionControl.args = [ 'phrase title', { uuid: 'uuid', key: 'VALUE' }, nestedPhraseFn ]
            parent.phraseToken = signature: 'it'
            injectionControl.beforeEach = phraseHookFn
            
            injectionControl.defer = 

                resolve: -> 

                    # 
                    # the pushed phrase contains the injection deferral that the 
                    # async injector wrapped around the pending call to phraseFn
                    # 
                    # beforeEach recursion control hook should have created the 
                    # new Phrase with reference to that deferral (this mock)
                    #
                    # ensure that it did.....
                    # 

                    done()

            hook = RecursorBeforeEach.create root, parent

            hook (-> 

                #root.context.stack[0].should.be.an.instanceof root.context.PhraseNode

                root.context.stack[1].title.should.equal 'phrase title'
                root.context.stack[1].uuid.should.equal 'uuid'  # only in case of root phrase
                root.context.stack[1].fn.should.equal nestedPhraseFn
                root.context.stack[1].token.signature.should.equal 'it'
                root.context.stack[1].hooks.beforeEach.should.equal phraseHookFn


            ), injectionControl


        it 'emits "phrase::edge:create" into the middleware pipeline', (done) -> 

            #
            # existing stack elements
            #

            root.context.stack.push new root.context.PhraseNode

                token: signature: 'describe'
                title: 'use case one'
                fn: ->

            root.context.stack.push new root.context.PhraseNode

                token: signature: 'context'
                title: 'the parent phrase'
                fn: ->

            #
            # pending new stack element
            #
            parent.phraseToken = signature: 'it'
            injectionControl.args      = [ 'has this child in', {}, -> ]
            SEQUENCE = []
            EVENTS = {}
            root.context.notice.event = (event, payload) -> 

                SEQUENCE.push event
                EVENTS[event] = payload
                return then: (resolve) -> resolve() 

            hook = RecursorBeforeEach.create root, parent
            hook (->

                SEQUENCE.should.eql [ 'phrase::edge:create' ]

                should.exist event1 = EVENTS['phrase::edge:create']
                event1.type.should.equal 'tree'
                event1.vertices[0].title.should.equal 'the parent phrase'
                event1.vertices[1].title.should.equal 'has this child in'

                done()

            ), injectionControl


    context 'boundry linking -', -> 

        # beforeEach (done) -> 

        #     parent.phraseType = (fn) -> 'boundry'
        #     injectionControl.args  = [ 'edge phrase', (@edge) => done() ]
        #     hook = RecursorBeforeEach.create root, parent
        #     hook (->), injectionControl


        it 'noops the injected recursion phraseFn', (done) ->

            #
            # so that the injection recursion can proceed unhindered
            # but does nothing for the case of boundry phrases
            # 

            parent.phraseType = (fn) -> 'boundry'
            injectionControl.args  = [ 'edge phrase', (edge) ->

                # edge.link directory: './path'

            ]
            hook = RecursorBeforeEach.create root, parent
            hook (->

                injectionControl.args[2].toString().should.eql 'function () {}'
                done()

            ), injectionControl
            
            

        it 'resolves the injection deferral if no call to link', (done) -> 

            parent.phraseType = (fn) -> 'boundry'
            injectionControl.args  = [ 'edge phrase', (edge) ->

                # edge.link directory: './path'

            ]
            hook = RecursorBeforeEach.create root, parent
            hook done, injectionControl


        xit 'resolves the injection deferral after ALL calls to link are handled', (done) -> 

            RESOLVED  = false
            LINKCOUNT = 0

            injectionResolver = -> 
                LINKCOUNT.should.equal 10000
                done()
                
            {defer} = require 'when'
            BoundryHandler.link = (root, opts) -> 

                doing = defer()
                process.nextTick -> 

                    RESOLVED.should.equal false
                    LINKCOUNT++
                    doing.resolve()

                doing.promise

            parent.phraseType = (fn) -> 'boundry'
            injectionControl.args  = [ 'edge phrase', (edge) ->

                for i in [1..10000] # a tad sluggish...

                    edge.link directory: './path' + i


            ]
            hook = RecursorBeforeEach.create root, parent
            hook injectionResolver, injectionControl 


        it 'proxies errors into the injections hook resolver', (done) -> 

            injectionResolver = (result) -> 

                result.should.be.an.instanceof Error
                result.should.match /in BoundryHandler/
                done()

            BoundryHandler.link = (root, opts) -> 

                throw new Error 'in BoundryHandler'

            parent.phraseType = (fn) -> 'boundry'
            injectionControl.args  = [ 'edge phrase', (edge) ->

                edge.link directory: './path1'

            ]
            hook = RecursorBeforeEach.create root, parent
            hook injectionResolver, injectionControl 


        context 'integration (refered boundry)', -> 

            it "boundry handler errors into the accessToken's error event listeners"

            it 'creates a reference phrase in the primary tree for each boundry phrase', (done) -> 

                BoundryHandler.recurse = (directory, match) -> [

                    '/make/believe/one.possible'
                    '/make/believe/two.possible'
                    '/make/believe/three.possible'

                ]

                recursor = require('../../../lib/phrase').createRoot

                    title:   'Boundry Test (refer)'
                    uuid:    '0000000001'
                    boundry: ['seeBeyond']
                    leaf:    ['π']

                    (accessToken, messageBus) -> 

                        messageBus.use (msg, next) -> 

                            if msg.context.title == 'phrase::boundry:assemble'

                                #
                                # async boundry phrase assembly line
                                # ----------------------------------
                                # 
                                # * can fetch and load a remote tree
                                # 
                                # TODO: (maybe) default assembly, (or the recursor never completes the 'first walk')
                                #

                                # msg.opts.mode = 'refer'
                                msg.opts.mode = 'nest'
                                msg.phrase = 

                                    title: msg.opts.filename.split('/')[-1..].join()
                                    control: uuid: msg.opts.filename

                                    fn: (fromBeyond) -> 

                                        fromBeyond '¥®†§ç', (ƒ) -> 

                                            ƒ 'øπˆ˙¥√ø', uuid: '∞', (π) -> π()
                                            ƒ '®∂¨çøˆ•',            (π) -> π()

                                next()

                            else next()

                        accessToken.on 'ready', ({tokens}) -> 

                            # console.log tokens

                            tokens[ '/Boundry Test (refer)/Primary Tree/nest/boundry phrase/seeBeyond/three.possible/fromBeyond/¥®†§ç/ƒ/øπˆ˙¥√ø' ].should.eql

                                type:      'leaf'
                                uuid:      '∞'
                                signature: 'ƒ'

                            done()

                           

                recursor 'Primary Tree', (nest) -> 

                    nest 'boundry phrase', (seeBeyond) -> 

                        seeBeyond.link

                            directory: '/make/believe'
                            match: /\.possibile$/


            it 'the reference phrase contains uuid of new tree rooted on the local core'


        context 'integration (nested boundry)', -> 

            it "boundry handler errors into the accessToken's error event listeners"

                #
                # and associate message bus event
                # #GREP4
                #


            it 'contunues walk through peer phrases that are linked as nested', (done) -> 

                recursor = require('../../../lib/phrase').createRoot

                    title: 'Boundry Test (nest)'
                    uuid:  '0000000002'
                    (accessToken, messageBus) -> 

                        accessToken.on 'ready', ({tokens}) -> 

                            #console.log JSON.stringify tokens, null, 2

                            tokens[ '/Boundry Test (nest)/tree1/nest/boundry leaf' ].should.eql 

                                type: 'boundry'
                                uuid: 'GRAFTPOINT1'
                                signature: 'nest'

                            should.exist tokens[ '/Boundry Test (nest)/tree1/nest/boundry leaf/edge/NESTED 15/book/The Enchanted Wood/characters/Angry Pixie' ]
                            done()

                        count = 1
                        messageBus.use (msg, next) -> 
                            
                            if msg.context.title == 'phrase::boundry:assemble'

                                # switch count++ % 2

                                #     when 0 then msg.opts.mode = 'nest'
                                #     when 1 then msg.opts.mode = 'refer'

                                msg.opts.mode = 'nest'

                                msg.phrase = 

                                    title: "NESTED #{count++}"
                                    control: uuid:  count++
                                    fn: (book) -> 

                                        #
                                        # The Faraway Tree (series)
                                        # -------------------------
                                        #

                                        book "The Enchanted Wood", (characters) -> 

                                            characters 'Moonface',      (end) -> end()
                                            characters 'Angry Pixie',   (end) -> end()
                                            characters 'Mr.Watzisname', (end) -> end()
                                            characters 'Dame Washalot', (end) -> end()
                                            characters 'Saucepan Man',  (end) -> end()
                                            characters 'Silky',         (end) -> end()
                                            characters 'Dame Slap',     (end) -> end()

                                        book "The Magic Faraway Tree", (end) -> end()
                                        book "The Folk of the Faraway Tree", (end) -> end()
                                        book "Up the Faraway Tree", (end) -> end()

                            next()

                recursor 'tree1', (nest) -> 

                    nest 'local leaf', (end) -> 

                    nest 'boundry leaf', uuid: 'GRAFTPOINT1', (edge) -> 

                        edge.link directory: __dirname
                        edge.link directory: __dirname
                        # edge.link directory: __dirname
                        # edge.link directory: __dirname
                        # edge.link directory: __dirname

