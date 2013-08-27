should       = require 'should'
ProcessToken = require '../../lib/token/process_token'
core         = require 'also'

describe 'ProcessToken', -> 

    context 'construction', ->

        before -> 

            @process = new ProcessToken core

        it 'houses the core but does not expose it', (done) -> 

            should.not.exist @process.core
            done()


        context 'root()', ->

            it 'creates roots to attach phrase trees to', (done) ->

                root1 = @process.root 'UUID1'
                root2 = @process.root 'UUID2'

                root1.uuid.should.equal 'UUID1'
                root2.uuid.should.equal 'UUID2'
                done()


            it 'returns already existing roots', (done) -> 

                root1 = @process.root 'UUID3'
                root1.property = 'value'


                root2 = @process.root 'UUID3'
                root2.property.should.equal 'value'
                root1.should.equal root2
                done()


            it 'enables each root access to peer roots', (done) -> 

                A = @process.root 'A'
                B = @process.root 'B'
                A.root('B').one  = 1
                
                B.one.should.equal 1
                done()

