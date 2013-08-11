should              = require 'should'
PhraseJob           = require '../../lib/phrase/phrase_job'

describe 'PhraseJob', -> 

    DEFER = undefined
    STEPS = undefined

    beforeEach -> 
        STEPS = []
        DEFER = 
            notify: -> 
            reject: ->

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


        it 'notifies the deferral on running state', (done) -> 

            MESSAGES = []

            job = new PhraseJob 

                steps: STEPS
                deferral: 
                    notify: (msg) -> 

                        MESSAGES.push msg

            job.run().then -> 

                msg = MESSAGES[0]
                msg.class.should.equal 'PhraseJob'
                msg.state.should.equal 'running'
                msg.progress.should.eql steps: 0, done: 0
                should.exist msg.uuid
                should.exist msg.at
                done()


        it 'returns a promise', (done) -> 

            job = new PhraseJob steps: STEPS, deferral: DEFER
            job.run().then.should.be.an.instanceof Function
            done()


        it 'runs each step.fn on phraseJob instance context', (done) -> 

            STEPS = [

                fn: -> @new_property = 'CREATED ON JOB INSTANCE'

            ]

            job = new PhraseJob steps: STEPS, deferral: DEFER
            job.run().then -> 

                job.new_property.should.equal 'CREATED ON JOB INSTANCE'
                done()


        it 'ties into the reserved property rejection', (done) -> 

            STEPS = [

                fn: -> @uuid = '0000000000000000000000000000006.62606957'

            ]

            DEFER.reject = (error) -> 

                error.should.match /Cannot assign reserved property/
                done()

            (new PhraseJob steps: STEPS, deferral: DEFER).run()


        it 'runs all steps', (done) -> 

            STEPS = [

                { fn: -> @one   = 1 }
                { fn: -> @two   = 2 }
                { fn: -> @three = 3 }

            ]

            job = new PhraseJob steps: STEPS, deferral: DEFER
            job.run().then -> 

                job.should.eql one: 1, two: 2, three: 3
                done()


        it 'resolves with object containing the job instance and notified state succeeded', (done) -> 

            STEPS = [

                { fn: -> @one   = 1 }
                { fn: -> @two   = 2 }
                { fn: -> @three = 3 }

            ]
            MESSAGES     = []
            DEFER.notify = (msg) -> MESSAGES.push msg

            job = new PhraseJob steps: STEPS, deferral: DEFER
            job.run().then (result) -> 

                MESSAGES.pop().state.should.equal 'succeeded'
                result.job.should.eql one: 1, two: 2, three: 3
                done()

