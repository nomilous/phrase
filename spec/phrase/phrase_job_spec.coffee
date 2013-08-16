should              = require 'should'
phraseJob           = require '../../lib/phrase/phrase_job'
{inject}            = require 'also'

describe 'PhraseJob', -> 

    DEFER     = undefined
    STEPS     = undefined
    root      = undefined
    PhraseJob = undefined
    NOTICE    = undefined
    opts      = undefined

    beforeEach -> 
        
        STEPS = []
        DEFER = 
            notify: -> 
            reject: ->

        root      = inject: inject
        PhraseJob = phraseJob.create root

        NOTICE = 
            event: -> then: (fn) -> fn()
        opts   = notice: NOTICE


    context 'general', -> 

        it 'requires opts.notice', (done) -> 

            try new PhraseJob
            catch error
                error.should.match /PhraseJob requires opts.notice/
                done()

        it 'is a class', -> 

            (new PhraseJob opts).should.be.an.instanceof PhraseJob

        it 'is initialized with deferral and steps array', (done) -> 

            job = new PhraseJob

                notice: NOTICE
                deferral: DEFER
                steps: STEPS

            job.steps.should.equal STEPS
            job.deferral.should.equal DEFER
            done()


        it 'can run() the job', (done) -> 

            should.exist PhraseJob.prototype.run
            done()

        it 'rejects the deferral on assignment of reserved property', (done) -> 

            job = new PhraseJob
                notice: NOTICE
                steps: STEPS
                deferral: reject: (error) -> 

                    error.should.match /Cannot assign reserved property: uuid/
                    done()

            job.uuid = 0


        it 'throws on assignment of reserved property without deferral', (done) -> 

            job = new PhraseJob
                notice: NOTICE
                steps: STEPS

            try job.uuid = 'a'
            catch error 

                error.should.match /Cannot assign reserved property: uuid/
                done()

        it 'logs to console if running deferral is not defined', -> 

            # job = new PhraseJob steps: STEPS
            # job.run()


    context 'run()', -> 


        it 'notifies the message bus on starting', (done) -> 

            NOTICE.event = (event, message) -> 

                event.should.equal 'run::starting'
                message.progress.should.eql steps: 2, done: 0, failed: 0, skipped: 0
                done()
                throw 'go no further'

            job = new PhraseJob notice: NOTICE, steps: [  {},{}  ], deferral: DEFER

            try job.run()



        it 'notifies the deferral on running state', (done) -> 

            MESSAGES = []

            job = new PhraseJob
                notice: NOTICE
                steps: STEPS
                deferral: 
                    notify: (msg) -> 

                        MESSAGES.push msg

            job.run().then -> 

                msg = MESSAGES[0]
                msg.class.should.equal 'PhraseJob'
                msg.state.should.equal 'run::starting'
                msg.progress.should.eql steps: 0, done: 0, failed: 0, skipped: 0
                should.exist msg.jobUUID
                should.exist msg.at
                done()


        it 'returns a promise', (done) -> 

            job = new PhraseJob steps: STEPS, deferral: DEFER, notice: NOTICE
            job.run().then.should.be.an.instanceof Function
            done()


        it 'runs each step.fn on phraseJob instance context', (done) -> 

            STEPS = [

                ref: fn: -> @new_property = 'CREATED ON JOB INSTANCE'

            ]

            job = new PhraseJob steps: STEPS, deferral: DEFER, notice: NOTICE
            job.run().then -> 

                job.new_property.should.equal 'CREATED ON JOB INSTANCE'
                done()


        it 'has constant properties', (done) -> 

            STEPS = [

                ref: fn: -> @notice = "Planck's constant"

            ]

            DEFER.reject = (error) -> 

                error.should.match /Cannot assign reserved property/
                done()

            (new PhraseJob steps: STEPS, deferral: DEFER, notice: NOTICE).run()


        it 'runs all steps', (done) -> 

            STEPS = [

                { ref: fn: -> @one   = 1 }
                { ref: fn: -> @two   = 2 }
                { ref: fn: -> @three = 3 }

            ]

            job = new PhraseJob steps: STEPS, deferral: DEFER, notice: NOTICE
            job.run().then -> 

                job.should.eql one: 1, two: 2, three: 3
                done()


        it 'enables steps to call the notifier inline', (done) -> 

            STEPS = [

                { ref: fn: -> @notice.info "buds know better than books don't grow" }

            ]

            NOTICE.info = (msg) -> 

                msg.should.equal "buds know better than books don't grow"
                done()


            job = new PhraseJob steps: STEPS, deferral: DEFER, notice: NOTICE
            job.run()




        it 'resolves with object containing the job instance and notified state succeeded', (done) -> 

            STEPS = [

                { ref: fn: -> @one   = 1 }
                { ref: fn: -> @two   = 2 }
                { ref: fn: -> @three = 3 }

            ]
            MESSAGES     = []
            DEFER.notify = (msg) -> MESSAGES.push msg

            job = new PhraseJob steps: STEPS, deferral: DEFER, notice: NOTICE
            job.run().then (result) -> 

                msg = MESSAGES.pop()
                msg.state.should.equal 'run::complete'
                msg.progress.should.eql { steps: 3, done: 3, failed: 0, skipped: 0 }
                result.job.should.eql one: 1, two: 2, three: 3
                done()


        it 'notifies the message bus on completion', (done) -> 

            EVENT = undefined
            NOTICE.event = (event, message) -> 

                EVENT = message
                then: (fn) -> fn()

            job = new PhraseJob notice: NOTICE, steps: [], deferral: DEFER
            job.run().then -> 

                EVENT.state.should.equal 'run::complete'
                done()



        it 'notifies parent on error', (done) -> 

            STEPS = [

                { type: 'leaf', set: 1, depth: 0  , ref: { fn: (done) -> throw new Error 'mooo' } }

            ]
            MESSAGES     = []
            DEFER.notify = (notify) -> MESSAGES.push notify
            job = new PhraseJob steps: STEPS, deferral: DEFER, notice: NOTICE
            job.run().then(

                -> 

                    MESSAGES[1].state.should.equal 'run::step:failed'
                    done()

                ->
                ->

            )

        it 'includes failing step and error in the notification', (done) -> 

            STEPS = [

                { type: 'leaf', set: 1, depth: 0  , ref: { fn: (done) -> throw new Error 'mooo' } }

            ]
            MESSAGES     = []
            DEFER.notify = (notify) -> MESSAGES.push notify
            job = new PhraseJob steps: STEPS, deferral: DEFER, notice: NOTICE
            job.run().then(

                -> 

                    MESSAGES[1].error.should.match 
                    MESSAGES[1].step.ref.fn.toString().should.match /mooo/
                    done()

                ->
                ->

            )


        it 'notifies parent on error when step is synchronous', (done) -> 

            STEPS = [

                 { type: 'leaf', set: 1, depth: 0  , ref: { fn: -> throw new Error 'mooo' } }

            ]

            MESSAGES     = []
            DEFER.notify = (notify) -> MESSAGES.push notify
            job = new PhraseJob steps: STEPS, deferral: DEFER, notice: NOTICE
            job.run().then(

                -> 

                    MESSAGES[1].state.should.equal 'run::step:failed'
                    done()

                ->
                ->

            )

        it 'does not run steps that are flagged as skip', (done) -> 

            RAN   = false
            STEPS = [

                ref: fn: -> RAN = true
                skip: true

            ]
            job = new PhraseJob steps: STEPS, deferral: DEFER, notice: NOTICE
            job.run().then(

                (result) -> 

                    RAN.should.equal false
                    done()

                ->
                ->

            )


        it 'error in beforeEach causes job to skip all remaining steps in the set that are at the same depth or deeper', (done) ->

            #
            # ie. if a beforeEach at depth 2 fails, the afterEach at depth 1 should still proceed
            #     all other steps leafing to and from the leaf should be skipped
            #

            STEPS = [

                { type: 'hook', set: 1, depth: 1  , ref: { type: 'beforeEach', fn: (done) -> @one   = 1; done() } }
                { type: 'hook', set: 1, depth: 2  , ref: { type: 'beforeEach', fn: (done) -> @two   = 2; throw new Error 'error' } }
                { type: 'leaf', set: 1, depth: 3  , ref: {                     fn: (done) -> @three = 3; done() } }
                { type: 'hook', set: 1, depth: 2  , ref: { type: 'afterEach',  fn: (done) -> @four  = 4; done() } }
                { type: 'hook', set: 1, depth: 1  , ref: { type: 'afterEach',  fn: (done) -> @five  = 5; done() } }
                

            ]

            MESSAGES     = []
            DEFER.notify = (notify) -> MESSAGES.push notify

            job = new PhraseJob steps: STEPS, deferral: DEFER, notice: NOTICE
            
            job.run().then(

                (result) ->
                    
                    result.job.should.eql 

                        one:  1
                        two:  2

                        #
                        # step 3 and 4 skipped on account of error in step 2
                        #

                        five: 5

                    MESSAGES.map( (m) -> state: m.state, progress: m.progress ).should.eql [ 

                        { state: 'run::starting',     progress: { steps: 5, done: 0, failed: 0, skipped: 0 } }
                        { state: 'run::step:done',    progress: { steps: 5, done: 1, failed: 0, skipped: 0 } }
                        { state: 'run::step:failed',  progress: { steps: 5, done: 1, failed: 1, skipped: 0 } }
                        { state: 'run::step:skipped', progress: { steps: 5, done: 1, failed: 1, skipped: 1 } }
                        { state: 'run::step:skipped', progress: { steps: 5, done: 1, failed: 1, skipped: 2 } }
                        { state: 'run::step:done',    progress: { steps: 5, done: 2, failed: 1, skipped: 2 } }
                        { state: 'run::complete',     progress: { steps: 5, done: 2, failed: 1, skipped: 2 } } 

                    ]

                    done()

                ->
                ->

            )



        it 'error in beforeEach notifies the set leaf'
        it 'error in beforeAll causes job to skip all same depth or deeper steps which depend on it', (done) -> 



            STEPS = [

                { type: 'hook', set:   1,    depth: 1, ref: { type: 'beforeEach', fn: (done) -> @one   = 1; done() } }
                { type: 'hook', sets: [1,2], depth: 2, ref: { type: 'beforeAll',  fn: (done) -> @two   = 2; throw new Error 'error' } }
                { type: 'leaf', set:   1,    depth: 3, ref: {                     fn: (done) -> } }
                { type: 'hook', set:   1,    depth: 1, ref: { type: 'afterEach',  fn: (done) -> done() } }

                { type: 'hook', set:   2,    depth: 1, ref: { type: 'beforeEach', fn: (done) ->  done() } }
                { type: 'leaf', set:   2,    depth: 3, ref: {                     fn: (done) ->  done() } }
                { type: 'hook', sets: [1,2], depth: 2, ref: { type: 'afterAll',   fn: (done) ->  done() } }
                { type: 'hook', set:   2,    depth: 1, ref: { type: 'afterEach',  fn: (done) ->  done() } }


            ]

            MESSAGES     = []
            DEFER.notify = (notify) -> MESSAGES.push notify

            job = new PhraseJob steps: STEPS, deferral: DEFER, notice: NOTICE
            
            job.run().then(

                (result) ->

                    
                    MESSAGES.map( (m) -> state: m.state, progress: m.progress ).should.eql [ 

                        { state: 'run::starting',     progress: { steps: 8, done: 0, failed: 0, skipped: 0 } }
                        { state: 'run::step:done',    progress: { steps: 8, done: 1, failed: 0, skipped: 0 } }
                        { state: 'run::step:failed',  progress: { steps: 8, done: 1, failed: 1, skipped: 0 } }
                        { state: 'run::step:skipped', progress: { steps: 8, done: 1, failed: 1, skipped: 1 } }
                        { state: 'run::step:skipped', progress: { steps: 8, done: 1, failed: 1, skipped: 2 } }
                        { state: 'run::step:skipped', progress: { steps: 8, done: 1, failed: 1, skipped: 3 } }
                        { state: 'run::step:done',    progress: { steps: 8, done: 2, failed: 1, skipped: 3 } }
                        { state: 'run::step:done',    progress: { steps: 8, done: 3, failed: 1, skipped: 3 } }
                        { state: 'run::step:done',    progress: { steps: 8, done: 4, failed: 1, skipped: 3 } }
                        { state: 'run::complete',     progress: { steps: 8, done: 4, failed: 1, skipped: 3 } }

                    ]

                    done()

                ->
                ->

            )



        it 'error in beforeAll notifies all affected leaves'
        it 'error in afterAll notifies'
        it 'error in afterEach notifies'



        it 'sets each step to done', (done) -> 

            STEPS = [

                { ref: fn: -> }
                { ref: fn: -> }
                { ref: fn: -> }

            ]
            job = new PhraseJob steps: STEPS, deferral: DEFER, notice: NOTICE
            job.run().then -> 

                STEPS.map (s) -> s.done.should.equal true
                done()


        it 'notifies parent deferral on each step completion', (done) -> 

            STEPS = [

                { ref: fn: -> }
                { ref: fn: -> }
                { ref: fn: -> }

            ]

            MESSAGES = []
            DEFER.notify = (notify) -> MESSAGES.push notify

            job = new PhraseJob steps: STEPS, deferral: DEFER, notice: NOTICE
            job.run().then ->

                MESSAGES.map( (m) -> 

                    state: m.state, progress: m.progress

                ).should.eql [ 
                    { state: 'run::starting',  progress: { steps: 3, done: 0, failed: 0, skipped: 0 } }
                    { state: 'run::step:done', progress: { steps: 3, done: 1, failed: 0, skipped: 0 } }
                    { state: 'run::step:done', progress: { steps: 3, done: 2, failed: 0, skipped: 0 } }
                    { state: 'run::step:done', progress: { steps: 3, done: 3, failed: 0, skipped: 0 } }
                    { state: 'run::complete',  progress: { steps: 3, done: 3, failed: 0, skipped: 0 } }
                ]
                done()




    context 'run() calls each step asynchronously', ->  

        it 'each step is passed through the injector', (done) -> 

            fn1 = -> 
            fn2 = -> 
            fn3 = -> 

            STEPS = [
                { ref: fn: fn1 }
                { ref: fn: fn2 }
                { ref: fn: fn3 }
            ]

            FUNCTIONS = []
            swap = inject.async
            inject.async = (preparator, fn)-> 
                FUNCTIONS.push fn
                ->

            job = new PhraseJob steps: STEPS, deferral: DEFER, notice: NOTICE
            job.run().then -> 

                inject.async = swap
                FUNCTIONS.should.eql [fn1, fn2, fn3]
                done()

        it 'injects no args when none are specified', (done) ->

            (new PhraseJob 
                notice: NOTICE
                deferral: DEFER
                steps: [ ref: fn: -> 

                    #
                    # step.ref.fn contains no arguments,
                    # ...none were injected
                    #

                    arguments.should.eql {}
                    done()

                ]
            ).run()


        it 'injects the resolver if arg1 is "done" and notifies on timeout', (done) -> 

            MESSAGES = []
            DEFER.notify = (msg) -> MESSAGES.push msg

            (new PhraseJob 
                notice: NOTICE
                deferral: DEFER
                steps: [ 

                    set:   1
                    depth: 0

                    ref: 
                        timeout: 10
                        fn: (done) -> 

                            #
                            # step.ref.fn signature has done at arg1
                            # ...custom resolver should have been injected
                            #

                            done.should.be.an.instanceof Function
                            done.toString().should.match /clearTimeout/

                            #
                            # let it timeout
                            #   

                ]

            ).run().then ->

                MESSAGES.map( (m) -> state: m.state, progress: m.progress ).should.eql [ 

                    { state: 'run::starting',    progress: { steps: 1, done: 0, failed: 0, skipped: 0 } }
                    { state: 'run::step:failed', progress: { steps: 1, done: 0, failed: 1, skipped: 0 } }
                    { state: 'run::complete',    progress: { steps: 1, done: 0, failed: 1, skipped: 0 } }

                ]

                done()



        it 'always injects resolver into leaf phrases', (done) -> 


            (new PhraseJob 
                deferral: DEFER
                notice: NOTICE
                steps: [ 

                    type: 'leaf'
                    ref: 

                        
                        fn: (arg1) -> 

                            #
                            # step.ref.fn signature has done at arg1
                            # ...custom resolver should have been injected
                            #

                            arg1.should.be.an.instanceof Function
                            arg1.toString().should.match /clearTimeout/
                            arg1()

                ]

            ).run().then(

                -> done()
                ->
                -> 
            )



