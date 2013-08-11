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


    it 'can be started', (done) -> 

        should.exist PhraseJob.prototype.start
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


    it 'notifies the deferral on start', (done) -> 

        job = new PhraseJob 

            steps: STEPS
            deferral: 
                notify: (msg) -> 

                    msg.class.should.equal 'PhraseJob'
                    msg.action.should.equal 'start'
                    msg.progress.should.eql steps: 0, done: 0
                    should.exist msg.uuid
                    should.exist msg.at
                    done()

        job.start()


    it 'logs to console if running deferral is not defined', -> 

        # job = new PhraseJob steps: STEPS
        # job.start()


    it 'runs each step.fn on phraseJob instance context', (done) -> 

        STEPS = [

            fn: -> @new_property = 'CREATED ON JOB INSTANCE'

        ]

        job = new PhraseJob steps: STEPS, deferral: DEFER
        job.start()
        job.new_property.should.equal 'CREATED ON JOB INSTANCE'
        done()


    it 'ties up with the reserved properties', (done) -> 

        STEPS = [

            fn: -> @uuid = '0000000000000000000000000000006.62606957'

        ]

        DEFER.reject = (error) -> 

            error.should.match /Cannot assign reserved property/
            done()

        (new PhraseJob steps: STEPS, deferral: DEFER).start()



