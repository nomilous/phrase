should              = require 'should'
PhraseJob           = require '../../lib/phrase/phrase_job'

describe 'PhraseJob', -> 

    it 'is a class', -> 

        (new PhraseJob).should.be.an.instanceof PhraseJob
        


