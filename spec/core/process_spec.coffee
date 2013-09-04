should       = require 'should'
Process      = require '../../lib/core/process'
Graph        = require '../../lib/core/graph'
core         = require 'also'

describe 'ProcessToken', -> 

    context 'construction', ->

        before -> 

            Graph.create core
            @process = new Process core

        it 'houses the core but does not expose it', (done) -> 

            should.not.exist @process.core
            done()


        context 'root()', ->

            it 'enables access to root creator on core', (done) -> 

                root = core.root 'UUID0'
                root.uuid.should.equal 'UUID0'
                done()


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


            it 'assigns ref to core graph assembler', (done) ->

                A = @process.root 'A'
                A.assembler.should.equal core.assembler
                done()


            it 'provides access to core validate and inject', (done) -> 

                A = @process.root 'A'

                A.validate.should.equal require('also').validate
                A.inject.should.equal   require('also').inject
                done()


            # it 'preloads the processToken into each root context stack', (done) ->

            #     #
            #     # this'll probably break a few things for a bit...
            #     #

            #     C = @process.root '∆'
            #     C.context.stack[0].should.equal @process
            #     done()

