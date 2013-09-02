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
            uuid: 'ROOTUUID'
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


    context 'stack and tree assembly -', ->


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


        it 'emits "phrase::edge:create" into the middleware pipeline with vertex pair and root uuid', (done) -> 

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
                event1.root.uuid.should.equal root.uuid
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

                BoundryHandler.recurse = -> [

                    'list'
                    'again'
                    'threetimes'

                ]

                recursor = require('../../../lib/phrase').createRoot

                    title:   'Boundry Test (refer)'
                    uuid:    '0000000001'

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

                                msg.opts.mode = 'nest'
                                msg.phrase = 

                                    title: msg.opts.filename.split('/')[-1..].join()
                                    control: uuid: msg.opts.filename

                                    fn: (probe) -> 

                                        probe "1957 -  USSR - Sputnik 1 - Success", (end) -> end()
                                        probe "1957 -  USSR - Sputnik 2 - Success", (end) -> end()
                                        probe "1957 -  USA - Vanguard TV3 - Failed", (end) -> end()
                                        probe "1958 -  USA - Explorer 1 - Success", (end) -> end()
                                        probe "1958 -  USA - Vanguard 6.5in Satellite 2 - Failed", (end) -> end()
                                        probe "1958 -  USA - Explorer 2 - Failed", (end) -> end()
                                        probe "1958 -  USA - Vanguard 1 - Success", (end) -> end()
                                        probe "1958 -  USA - Explorer 3 - Success", (end) -> end()
                                        probe "1958 -  USSR - ISZ D-1 No. 1 - Failed", (end) -> end()
                                        probe "1958 -  USA - Vanguard 20in X-ray 1 - Failed", (end) -> end()
                                        probe "1958 -  USSR - Sputnik 3 - Success", (end) -> end()
                                        probe "1958 -  USA - Vanguard 20in Lyman-Alpha 1 - Failed", (end) -> end()
                                        probe "1960 -  USA - Sun - Success - Pioneer 5 solar monitor", (end) -> end()
                                        probe "1962 -  UK - Earth - Success Ariel 1 the first British satellite in space (built by NASA, launched on American rocket)", (end) -> end()
                                        probe "1962 -  Canada - Earth - Success - Alouette 1, the first Canadian satellite (on American rocket)", (end) -> end()
                                        probe "1964 -  Italy - Earth - Success - San Marco 1, the first Italian satellite (on American rocket)", (end) -> end()
                                        probe "1965 -  France - Earth - Success - Asterix, the first French satellite", (end) -> end()
                                        probe "1970 -  Japan - Earth - Success - Osumi the first Japanese satellite", (end) -> end()
                                        probe "1970 -  Soviet Union - Venus - Success - Venera 7, the first successful landing of a spacecraft on another planet", (end) -> end()
                                        probe "1970 -  Soviet Union - Moon - Success - Luna 16 lander is the first automated return of samples from the Moon", (end) -> end()
                                        probe "1970 -  Soviet Union - Moon - Success - Zond 8 flyby", (end) -> end()
                                        probe "1970 -  Soviet Union - Moon - Success - Luna 17,Lunokhod 1 lander,rover is the first automated surface exploration of the Moon", (end) -> end()
                                        probe "1970 -  UK - Failure - Orba (satellite), second stage of rocket shutdown 13 seconds early", (end) -> end()
                                        probe "1970 -  USA - Success - Launch of Uhuru, the first dedicated X-ray satellite", (end) -> end()
                                        probe "1970 -  China - Success - Launch of Dong Fang Hong I, the first Chinese satellite", (end) -> end()
                                        probe "1971 -  Soviet Union - Moon - Failure - Luna 18 lander", (end) -> end()
                                        probe "1971 -  Soviet Union - Moon - Success - Luna 19 orbiter", (end) -> end()
                                        probe "1971 -  USA - Mars - Failure - Mariner 8 flyby", (end) -> end()
                                        probe "1971 -  Soviet Union - Mars - Failure - Cosmos 419 probe", (end) -> end()
                                        probe "1971 -  Soviet Union - Mars - Partial Failure - Mars 2 orbiter and lander, created the first human artifact on Mars", (end) -> end()
                                        probe "1971 -  Soviet Union - Mars - Partial Success - Mars 3 orbiter and lander, first successful landing on Mars", (end) -> end()
                                        probe "1971 -  USA - Mars - Success - Mariner 9 orbiter, first pictures of Mars' moons (Phobos and Deimos) taken", (end) -> end()
                                        probe "1971 -  UK - Earth - Success - Prospero X-3 satellite, first satellite launched by Britain using a British rocket", (end) -> end()
                                        probe "1971 -  UK - Earth - Success - Ariel 4,", (end) -> end()
                                        probe "1972 -  Soviet Union - Venus - Success - Venera 8 lander", (end) -> end()
                                        probe "1972 -  Soviet Union - Moon - Success - Luna 20 lander", (end) -> end()
                                        probe "1972 -  USA, UK - Earth - Success - Launch of the Copernicus ultraviolet satellite", (end) -> end()
                                        probe "1972 -  USA - Jupiter - Success - Pioneer 10 launched, first spacecraft to encounter Jupiter", (end) -> end()
                                        probe "1972 -  USA - Sun - Success - Explorer 49 solar probe", (end) -> end()
                                        probe "1973 -  USA - Venus,Mercury - Success - Mariner 10 launched, it passed by and photographed Mercury, also was the first dual planet probe", (end) -> end()
                                        probe "1973 -  USA - Jupiter,Saturn - Success - Pioneer 11 launched, first spacecraft to encounter Saturn", (end) -> end()
                                        probe "1973 -  Soviet Union - Moon - Success - Luna 21,Lunokhod 2 lander/rover", (end) -> end()
                                        probe "1973 -  Soviet Union - Mars - Failure - Mars 4 orbiter", (end) -> end()
                                        probe "1973 -  Soviet Union - Mars - Success - Mars 5 orbiter", (end) -> end()
                                        probe "1973 -  Soviet Union - Mars - Failure - Mars 6 orbiter and lander", (end) -> end()
                                        probe "1973 -  Soviet Union - Mars - Failure - Mars 7 orbiter and lander", (end) -> end()
                                        probe "1974 -  West Germany - Sun - Success - Helios 1 solar probe", (end) -> end()
                                        probe "1974 -  Soviet Union - Moon - Success - Luna 22 orbiter", (end) -> end()
                                        probe "1974 -  Soviet Union - Moon - Failure - Luna 23 probe", (end) -> end()
                                        probe "1974 -  UK - Earth - Success - Launch of the Ariel 5 X-ray satellite", (end) -> end()
                                        probe "1975 -  Soviet Union - Venus - Success - Venera 9 returns the first pictures of the surface of Venus", (end) -> end()
                                        probe "1975 -  Soviet Union - Venus - Success - Venera 10 orbiter and lander", (end) -> end()
                                        probe "1975 -  USA - Mars - Partial Success - Viking 1 orbiter and lander; lands on Mars 1976", (end) -> end()
                                        probe "1975 -  USA - Mars - Success - Viking 2 orbiter and lander; lands on Mars 1976", (end) -> end()
                                        probe "1975 -  India - Earth - Success - Aryabhata India, launched by USSR", (end) -> end()
                                        probe "1975 -  India - India's first rocket SLV launched", (end) -> end()
                                        probe "1976 -  West Germany - Sun - Success - Helios 2 solar probe", (end) -> end()
                                        probe "1976 -  Soviet Union - Moon - Success - Luna 24 lander", (end) -> end()
                                        probe "1976 -  USA, Canada - Earth - Success - Hermes Communications Technology Satellite prototype for testing direct broadcast TV", (end) -> end()
                                        probe "1976 -  USA, Netherlands - Earth - Success - The Vela and ANS X-ray satellites discover X-ray bursts (first Dutch satellite)", (end) -> end()
                                        probe "1976 -  USA - Sun - Success - The Orbiting Solar Observatory X-ray satellite shows that X-ray bursts have blackbody spectra", (end) -> end()
                                        probe "1977 -  USA - Earth - Success - Launch of the HEAO-1 X-ray satellite", (end) -> end()
                                        probe "1978 -  USA - Venus - Success - Pioneer Venus 1 orbiter", (end) -> end()
                                        probe "1978 -  USA - Venus - Success - Pioneer Venus 2 atmospheric probe", (end) -> end()
                                        probe "1978 -  Soviet Union - Venus - Partial Success - Venera 11 flyby and lander", (end) -> end()
                                        probe "1978 -  Soviet Union - Venus - Success - Venera 12 flyby and lander", (end) -> end()
                                        probe "1978 -  USA, UK, Europe - Earth - Success - Launch of the International Ultraviolet Explorer satellite", (end) -> end()
                                        probe "1978 -  USA - Earth - Success - Launch of the Einstein X-ray satellite (HEAO-2) is the first X-ray photographs of astronomical objects", (end) -> end()
                                        probe "1979 -  Japan - Earth - Success - Launch of the Hakucho X-ray satellite", (end) -> end()
                                        probe "1979 -  UK - Earth - Success - Launch of the Ariel 6 cosmic-ray and X-ray satellite", (end) -> end()
                                        probe "1979 -  USA - Jupiter - Success - Voyager 1 and Voyager 2 send back images of Jupiter and its system", (end) -> end()
                                        probe "1979 -  India - Earth - Success - Bhaskara-1 India, launched by ISRO (First Indian low orbit Earth Observation Satellite)", (end) -> end()
                                        probe "1980 -  USA - Sun - Failure - Solar Maximum Mission solar probe succeeded after being repaired in Earth orbit", (end) -> end()
                                        probe "1981 -  India - Earth - Success - Bhaskara-2 India, launched by ISRO", (end) -> end()
                                        probe "1981 -  Soviet Union - Venus - Success - Venera 13 launched, it returned the first colour pictures of the surface of Venus", (end) -> end()
                                        probe "1981 -  Soviet Union - Venus - Success - Venera 14 flyby and lander", (end) -> end()
                                        probe "1981 -  Bulgaria - Earth - Success - Bulgaria 1300, polar research mission, launched by the Soviet Union", (end) -> end()
                                        probe "1983 -  Soviet Union - Venus - Success - Venera 15 orbiter", (end) -> end()
                                        probe "1983 -  Soviet Union - Venus - Success - Venera 16 orbiter", (end) -> end()
                                        probe "1983 -  Europe - Earth - Success - Launch of the EXOSAT X-ray satellite", (end) -> end()
                                        probe "1983 -  Japan - Earth - Success - Launch of the Tenma X-ray satellite (ASTRO-B)", (end) -> end()
                                        probe "1983 -  USA, Netherlands, UK - Earth - Success - Launch of the IRAS satellite", (end) -> end()
                                        probe "1984 -  Soviet Union - Venus,Halley's Comet - Success - Vega 1 flyby, atmospheric probe and lander", (end) -> end()
                                        probe "1984 -  Soviet Union - Venus,Halley's Comet - Success - Vega 2 flyby, atmospheric probe and lander", (end) -> end()
                                        probe "1986 -  Europe - Halley's Comet - Success - Giotto flyby", (end) -> end()
                                        probe "1987 -  Japan - Earth - Success - Launch of the Ginga X-ray satellite (ASTRO-C)", (end) -> end()
                                        probe "1988 -  Soviet Union - Mars - Failure - Phobos 1 orbiter and lander", (end) -> end()
                                        probe "1988 -  Soviet Union - Mars - Partial Failure - Phobos 2 flyby and lander", (end) -> end()
                                        probe "1989 -  USA - Venus - Success - Magellan orbiter launched which mapped 99 percent of the surface of Venus (300 m resolution)", (end) -> end()
                                        probe "1989 -  USA - Venus,Earth,Moon,Gaspra,Ida,Jupiter - Success - Galileo flyby, orbiter and atmospheric probe", (end) -> end()
                                        probe "1989 -  USA - Neptune - Success - Voyager 2 sends back images of Neptune and its system", (end) -> end()
                                        probe "1989 -  Europe - Earth - Success - Launch of the Hipparcos satellite", (end) -> end()
                                        probe "1989 -  USA - Earth - Success - Launch of the COBE satellite", (end) -> end()
                                        probe "1989 -  Soviet Union - Earth - Success - Launch of the Granat gamma-ray and X-ray satellite", (end) -> end()
                                        probe "1990 -  USA, Europe - Sun - Success - Ulysses solar flyby", (end) -> end()
                                        probe "1990 -  Japan - Moon - Success - Hiten probe, this was the first non-United States or USSR probe to reach the Moon", (end) -> end()
                                        probe "1990 -  USA, Europe - Success - Launch of the Hubble Space Telescope", (end) -> end()
                                        probe "1990 -  Germany - Success - Launch of the ROSAT X-ray satellite to conduct the first imaging X-ray sky survey", (end) -> end()
                                        probe "1991 -  Japan - Sun - Success - Yohkoh solar probe", (end) -> end()
                                        probe "1991 -  USA - Earth - Success - Launch of the Compton Gamma-Ray Observatory satellite", (end) -> end()
                                        probe "1992 -  USA - Mars - Failure - Mars Observer orbiter", (end) -> end()
                                        probe "1993 -  Japan - Earth - Success - Launch of the ASCA (ASTRO-D) X-ray satellite", (end) -> end()
                                        probe "1994 -  USA - Moon - Success - Clementine orbiter mapped the surface of the Moon (resolution 125-150m) and allowed the first accurate relief map of the Moon to be generated", (end) -> end()
                                        probe "1995 -  Europe - Earth - Success - Launch of the Infrared Space Observatory", (end) -> end()
                                        probe "1995 -  Europe, USA - Sun - Success - SOHO solar probe", (end) -> end()
                                        probe "1996 -  USA - 433 Eros - Success - NEAR Shoemaker - asteroid flybys/orbiter/lander", (end) -> end()
                                        probe "1996 -  USA - Mars - Success - Mars Global Surveyor orbiter", (end) -> end()
                                        probe "1996 -  USA - Mars - Success - Mars Pathfinder, the first automated surface exploration of another planet", (end) -> end()
                                        probe "1996 -  Russia - Mars - Failure - Mars 96 orbiter and lander", (end) -> end()
                                        probe "1997 -  USA, Europe - Saturn and Titan - Success - Cassini-Huygens - arrived in orbit on July 1, 2004, landed on Titan January 14, 2005", (end) -> end()
                                        probe "1998 -  North Korea - Earth - Unknown - Claimed launch of Kwangmyŏngsŏng-1 by North Korea though no independent source was able to verify ", (end) -> end()
                                        probe "1998 -  USA - Moon - Success - Lunar Prospector orbiter", (end) -> end()
                                        probe "1998 -  Japan - Mars - Failure - Nozomi (Planet B) orbiter, the first Japanese spacecraft to reach another planet", (end) -> end()
                                        probe "1998 -  USA - Mars - Failure - Mars Climate Orbiter", (end) -> end()
                                        probe "1999 -  USA - Mars - Failure - Mars Polar Lander", (end) -> end()
                                        probe "1999 -  USA - Mars - Failure - Deep Space 2 (DS2) penetrators", (end) -> end()
                                        probe "1999 -  USA - Earth - Success - Launch of the Chandra X-ray Observatory", (end) -> end()
                                        probe "1999 -  Europe - Earth - Success - Launch of the X-Ray Multi-Mirror Mission, XMM-Newton", (end) -> end()
                                        probe "2000 -  UK - Earth - Success - SNAP-1 robotic camera enabling images to be sent to other spacecrafts orbiting the Earth", (end) -> end()
                                        probe "2001 -  USA - Sun - Partial Success - Genesis solar wind sample return - crash-landed on return", (end) -> end()
                                        probe "2001 -  USA - Success - Wilkinson Microwave Anisotropy Probe (WMAP) performs cosmological observations.", (end) -> end()
                                        probe "2001 -  USA - Mars - Success - Mars Odyssey", (end) -> end()
                                        probe "2003 -  Canada - Earth - Success - MOST the smallest space telescope in orbit", (end) -> end()
                                        probe "2003 -  USA - Comet Encke - Failure - CONTOUR launched, but lost during early trajectory insertion.", (end) -> end()
                                        probe "2003 -  Europe - Moon - Success - Smart 1 orbiter", (end) -> end()
                                        probe "2003 -  Europe - Mars - Partial Success - Mars Express orbiter (successfully reached orbit) and failed lander, the Beagle 2", (end) -> end()
                                        probe "2003 -  USA - Mars - Success - Mars Exploration Rovers - successful launches, Spirit successfully landed, Opportunity successfully landed", (end) -> end()
                                        probe "2003 -  UK - Success - UK-DMC orbiter, part of the Disaster Monitoring Constellation", (end) -> end()
                                        probe "2003 -  Japan - 25143 Itokawa - Hayabusa - sample return - arrive at 2010", (end) -> end()
                                        probe "2004 -  Europe - Comet 67P - Rosetta space probe launched - yet to arrive", (end) -> end()
                                        probe "2004 -  USA - Mercury - MESSENGER orbiter - launched - in Mercury orbit", (end) -> end()
                                        probe "2004 -  USA - Success - Launch of the Swift Gamma ray burst observatory.", (end) -> end()
                                        probe "2005 -  Iran - Earth - Sinah-1 - launched, first Iranian-built satellite", (end) -> end()
                                        probe "2005 -  USA - Comet Tempel 1 - Deep Impact - successful comet impact", (end) -> end()
                                        probe "2005 -  USA - Mars - Mars Reconnaissance Orbiter - in orbit", (end) -> end()
                                        probe "2005 -  Europe - Venus - Venus Express - in orbit", (end) -> end()
                                        probe "2006 -  USA - Pluto - New Horizons - launched - yet to arrive", (end) -> end()
                                        probe "2006 -  France,ESA - Earth - COROT - launched, telescope to search for extrasolar planets", (end) -> end()
                                        probe "2007 -  USA - Mars - Success - Phoenix - launched and successfully landed in 2008", (end) -> end()
                                        probe "2007 -  Japan - Moon - SELENE orbiter and lander - in lunar orbit since October 3, 2007", (end) -> end()
                                        probe "2007 -  USA - Vesta,Ceres- Dawn - launched - solar powered ion engined probe to 4 Vesta and 1 Ceres.", (end) -> end()
                                        probe "2007 -  China - Moon - Chang'e-I - success - lunar orbiter", (end) -> end()
                                        probe "2008 -  USA - Earth - Success - IBEX - launched - operating", (end) -> end()
                                        probe "2009 -  Europe - L2 - Planck (spacecraft) - launched, arrived, operating", (end) -> end()
                                        probe "2009 -  Europe - L2 - Herschel Space Observatory - launched, arrived, operating", (end) -> end()
                                        probe "2009 -  Iran - Earth - Omid - launched by Iranian made launcher Safir, first Iranian-launched satellite", (end) -> end()
                                        probe "2009 -  USA - Earth - Success - Kepler - launched - operating", (end) -> end()
                                        probe "2009 -  India - Earth - Success - RISAT-2 developed by Israel Aerospace Industries, launched by ISRO, India", (end) -> end()
                                        probe "2009 -  India - Moon - Partial failure - Chandrayaan-1 developed and launched by ISRO, India", (end) -> end()
                                        probe "2009 -  UK - Success - UK-DMC 2 orbiter, successor to UK-DMC part of the Disaster Monitoring Constellation", (end) -> end()
                                        probe "2010 -  Japan - Venus - Akatsuki orbiter - failed orbital insertion", (end) -> end()
                                        probe "2010 -  Japan - Venus IKAROS - launched - first solar-sail spacecraft", (end) -> end()
                                        probe "2010 -  China - Moon - Chang'e-2 - success - lunar orbiter,impacter", (end) -> end()
                                        probe "2011 -  USA - Jupiter - Juno - launched and en route", (end) -> end()
                                        probe "2011 -  Russia - Mars - Fobos-Grunt - Failure - lander and sample return", (end) -> end()
                                        probe "2012 -  Iran - Earth - Navid - launched - earth-watching satellite", (end) -> end()
                                        probe "2012 -  USA - Mars - Mars Science Laboratory with Curiosity rover—orbit and landed", (end) -> end()
                                        probe "2012 -  North Korea - First successful North Korean orbital rocket launch", (end) -> end()
                                        probe "2013 -  South Korea - First successful South Korean orbital rocket launch", (end) -> end()
                                        probe "2013 -  UK - Earth - STRaND-1 - success - First smartphone-operated satellite to be launched and dubbed the world's first 'phonesat'", (end) -> end()
                                        probe "2013 -  Ecuador - Earth - NEE-01 PEGASO First Ecuadorian satellite", (end) -> end()



                                next()

                            else next()

                        accessToken.on 'ready', ({tokens}) -> 

                            should.exist tokens["/Boundry Test (refer)/Exploration/space/probes/edge/list/probe/2013 -  UK - Earth - STRaND-1 - success - First smartphone-operated satellite to be launched and dubbed the world's first 'phonesat'"]
                            done()

                           

                recursor 'Exploration', (space) -> 

                    space 'probes', (edge) -> 

                        edge.link directory: __dirname


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

