should              = require 'should'
phraseJob           = require '../../lib/phrase/phrase_job'
{inject}            = require 'also'

describe 'PhraseJob', -> 

    DEFER     = undefined
    STEPS     = undefined
    root      = undefined
    PhraseJob = undefined

    beforeEach -> 
        
        STEPS = []
        DEFER = 
            notify: -> 
            reject: ->

        root      = inject: inject
        PhraseJob = phraseJob.create root

    xcontext 'general', -> 

        it 'is a class', -> 

            (new PhraseJob).should.be.an.instanceof PhraseJob

        it 'is initialized with deferral and steps array', (done) -> 

            job = new PhraseJob

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

                steps: STEPS
                deferral: reject: (error) -> 

                    error.should.match /Cannot assign reserved property: uuid/
                    done()

            job.uuid = 0


        it 'throws on assignment of reserved property without deferral', (done) -> 

            job = new PhraseJob

                steps: STEPS

            try job.uuid = 'a'
            catch error 

                error.should.match /Cannot assign reserved property: uuid/
                done()

        it 'logs to console if running deferral is not defined', -> 

            # job = new PhraseJob steps: STEPS
            # job.run()


    context 'run()', -> 


        xit 'notifies the deferral on running state', (done) -> 

            MESSAGES = []

            job = new PhraseJob

                steps: STEPS
                deferral: 
                    notify: (msg) -> 

                        MESSAGES.push msg

            job.run().then -> 

                msg = MESSAGES[0]
                msg.class.should.equal 'PhraseJob'
                msg.state.should.equal 'run::starting'
                msg.progress.should.eql steps: 0, done: 0
                should.exist msg.uuid
                should.exist msg.at
                done()


        xit 'returns a promise', (done) -> 

            job = new PhraseJob steps: STEPS, deferral: DEFER
            job.run().then.should.be.an.instanceof Function
            done()


        xit 'runs each step.fn on phraseJob instance context', (done) -> 

            STEPS = [

                ref: fn: -> @new_property = 'CREATED ON JOB INSTANCE'

            ]

            job = new PhraseJob steps: STEPS, deferral: DEFER
            job.run().then -> 

                job.new_property.should.equal 'CREATED ON JOB INSTANCE'
                done()


        xit 'ties into the reserved property rejection', (done) -> 

            STEPS = [

                ref: fn: -> @uuid = '0000000000000000000000000000006.62606957'

            ]

            DEFER.reject = (error) -> 

                error.should.match /Cannot assign reserved property/
                done()

            (new PhraseJob steps: STEPS, deferral: DEFER).run()


        xit 'runs all steps', (done) -> 

            STEPS = [

                { ref: fn: -> @one   = 1 }
                { ref: fn: -> @two   = 2 }
                { ref: fn: -> @three = 3 }

            ]

            job = new PhraseJob steps: STEPS, deferral: DEFER
            job.run().then -> 

                job.should.eql one: 1, two: 2, three: 3
                done()


        xit 'resolves with object containing the job instance and notified state succeeded', (done) -> 

            STEPS = [

                { ref: fn: -> @one   = 1 }
                { ref: fn: -> @two   = 2 }
                { ref: fn: -> @three = 3 }

            ]
            MESSAGES     = []
            DEFER.notify = (msg) -> MESSAGES.push msg

            job = new PhraseJob steps: STEPS, deferral: DEFER
            job.run().then (result) -> 

                msg = MESSAGES.pop()
                msg.state.should.equal 'run::complete'
                msg.progress.should.eql { steps: 3, done: 3 }
                result.job.should.eql one: 1, two: 2, three: 3
                done()

        xit 'notifies on error', (done) -> 

            STEPS = [

                ref: fn: (done) -> throw new Error 'mooo'

            ]
            job = new PhraseJob steps: STEPS, deferral: DEFER
            job.run().then(

                -> 
                ->
                (notify) ->

                    notify.event.should.equal 'error'
                    notify.error.should.match /mooo/
                    done()


            )


        xit 'notifies on error when step is synchronous', (done) -> 

            STEPS = [

                ref: fn: -> throw new Error 'mooo'

            ]
            job = new PhraseJob steps: STEPS, deferral: DEFER
            job.run().then(

                -> 
                ->
                (notify) ->

                    notify.event.should.equal 'error'
                    notify.error.should.match /mooo/
                    done()

            )



        it 'error in beforeEach causes job to skip the rest of the set'
        it 'error in beforeEach notifies the set leaf'
        it 'error in beforeAll causes job to skip all sets which depend on it'
        it 'error in beforeAll notifies all affected leaves'
        it 'error in afterAll notifies'
        it 'error in afterEach notifies'



        xit 'sets each step to done', (done) -> 

            STEPS = [

                { ref: fn: -> }
                { ref: fn: -> }
                { ref: fn: -> }

            ]
            job = new PhraseJob steps: STEPS, deferral: DEFER
            job.run().then -> 

                STEPS.map (s) -> s.done.should.equal true
                done()


        xit 'notifies parent deferral on each step completion', (done) -> 

            STEPS = [

                { ref: fn: -> }
                { ref: fn: -> }
                { ref: fn: -> }

            ]

            MESSAGES = []
            DEFER.notify = (notify) -> MESSAGES.push notify

            job = new PhraseJob steps: STEPS, deferral: DEFER
            job.run().then ->

                MESSAGES.map( (m) -> 

                    state: m.state, progress: m.progress

                ).should.eql [ 
                    { state: 'run::starting', progress: { steps: 3, done: 0 } }
                    { state: 'run::started',  progress: { steps: 3, done: 1 } }
                    { state: 'run::started',  progress: { steps: 3, done: 2 } }
                    { state: 'run::started',  progress: { steps: 3, done: 3 } }
                    { state: 'run::complete', progress: { steps: 3, done: 3 } }
                ]
                done()




    xcontext 'run() calls each step asynchronously', ->  

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

            job = new PhraseJob steps: STEPS, deferral: DEFER
            job.run().then -> 

                inject.async = swap
                FUNCTIONS.should.eql [fn1, fn2, fn3]
                done()

        it 'injects no args when none are specified', (done) ->

            (new PhraseJob 
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

            (new PhraseJob 
                deferral: DEFER
                steps: [ ref: 

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

            ).run().then(

                ->
                ->
                (notify) -> 

                    notify.event.should.equal 'timeout'
                    done()

            )

        it 'always injects resolver into leaf phrases', (done) -> 


            (new PhraseJob 
                deferral: DEFER
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



