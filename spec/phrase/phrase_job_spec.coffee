should              = require 'should'
PhraseJob           = require '../../lib/phrase/phrase_job'

describe 'PhraseJob', -> 

    DEFER = undefined
    STEPS = undefined

    beforeEach -> 
        STEPS = []
        DEFER = notify: -> 

    it 'is a class', -> 

        (new PhraseJob).should.be.an.instanceof PhraseJob

    it 'is initialized with deferral and steps array', (done) -> 

        job = new PhraseJob 

            running: DEFER
            steps: STEPS

        # console.log job

        job.steps.should.equal STEPS
        job.running.should.equal DEFER
        done()


    it 'can be started', (done) -> 

        should.exist PhraseJob.prototype.start
        done()

    it 'notifies on start', (done) -> 

        job = new PhraseJob 

            #steps: STEPS
            running: 
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

