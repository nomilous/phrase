should      = require 'should'
PhraseRoot  = require('../../lib/phrase/root').createClass require 'also'
AccessToken = require '../../lib/token/access_token'
Run         = require '../../lib/runner/run'

describe 'Run', -> 

    root        = undefined
    TOKEN       = undefined
    NOTICE      = undefined
    TREE        = undefined
    LEAF_TWO    = undefined
    PHRASE_ROOT = undefined
    NEST_ONE    = undefined
    JOB_RUN     = undefined 
    
    # console.log before.toString()

    before (done) -> 

        root = PhraseRoot.createRoot

            title: 'Title'
            uuid:  'ROOT-UUID'

            (token, notice) -> 

                TOKEN  = token
                NOTICE = notice
                TREE   = token.tree

                notice.use (msg, next) -> 

                    return done() if LEAF_TWO?

                    if msg.context.title == 'phrase::recurse:end'

                        #
                        # tree is ready, locate UUIDs of test phrase nodes
                        #

                        vertices = TOKEN.tree.vertices
                        # LEAF_TWO = ( for uuid of vertices
                        #     continue unless vertices[uuid].title == 'LEAF_TWO'
                        #     uuid
                        # )[0]
                        # PHRASE_ROOT = ( for uuid of vertices
                        #     continue unless vertices[uuid].title == 'PHRASE_ROOT'
                        #     uuid
                        # )[0]
                        NEST_ONE = ( for uuid of vertices
                            continue unless vertices[uuid].title == 'NEST_ONE'
                            uuid
                        )[0]
                        done()

                    next()


        root 'PHRASE_ROOT', (nested) -> 
            before all:  ->  'BEFORE-ALL-OUTSIDE'
            before each: -> 'BEFORE-EACH-OUTSIDE'
            after  each: ->  'AFTER-EACH-OUTSIDE'
            after  all:  ->   'AFTER-ALL-OUTSIDE'
            nested 'NEST_ONE', (deeper) -> 
                before all:  ->  'BEFORE-ALL-NESTED'
                before each: -> 'BEFORE-EACH-NESTED'
                after  each: ->  'AFTER-EACH-NESTED'
                after  all:  ->   'AFTER-ALL-NESTED'
                deeper 'LEAF_ONE', (end) ->
                    'RUN_LEAF_ONE' 
                    #end()
                deeper 'NEST_TWO', (deeper) -> 
                    deeper 'NEST_THREE', (deeper) -> 
                        before all:  ->  'BEFORE-ALL-DEEP'
                        before each: -> 'BEFORE-EACH-DEEP'
                        after  each: ->  'AFTER-EACH-DEEP'
                        after  all:  ->   'AFTER-ALL-DEEP'
                        deeper 'LEAF_TWO', (end) -> 
                            'RUN_LEAF_TWO' 
                            #end()
                deeper 'LEAF_THREE', (end) -> 
                    'RUN_LEAF_THREE'
                    #end()
            nested 'LEAF_FOUR', (end) -> end()



    context 'run()', ->

        xit 'returns a promise', (done) -> 

            TOKEN.run(uuid: 0).then.should.be.an.instanceof Function
            done()

        xit 'reject if no target uuid was supplied', (done) -> 

            TOKEN.run().then(
                ->
                (error) -> 
                    error.code.should.equal 1
                    error.should.match /missing opts.uuid/
                    done()
            )
            
        xit 'rejects on missing uuid', (done) -> 

            TOKEN.run( uuid: 'NO_SUCH_UUID' ).then(
                ->
                (error) -> 
                    error.code.should.equal 2
                    error.should.match /uuid: 'NO_SUCH_UUID' not in local tree/
                    done()
            )

        xit 'calls get all steps to run', (done) -> 

            swap = Run.getSteps
            Run.getSteps = (root, opts) ->

                Run.getSteps = swap
                opts.uuid.should.equal NEST_ONE
                done()
                then: -> throw 'go no further'

            try TOKEN.run( uuid: NEST_ONE )


        xit 'creates a Job and calls it to run', (done) -> 

            swap = Run.getSteps
            Run.getSteps = (root, opts) ->
                Run.getSteps = swap

                swap = root.context.Job.prototype.run
                root.context.Job.prototype.run = -> 

                    root.context.Job.prototype.run = swap
                    @steps.should.eql ['STEP']
                    done()

                then: (resolve) -> resolve ['STEP']

            try TOKEN.run( uuid: NEST_ONE )


        it 'updates the promise', (ok) ->

            tick = 0
            Date.now = -> tick++

            MESSAGES = []

            TOKEN.run( uuid: NEST_ONE ).then(

                (result) -> 
                (error)  -> 

                    console.log error.stack

                (notify) -> 
                    MESSAGES.push notify
                    if notify.update == 'scan::complete'
                        MESSAGES.should.eql [ 

                            { update: 'scan::starting', at: 0 }
                            { update: 'scan::complete', at: 1, steps: 23, leaves: 3 } 

                        ]
                        ok()

            ) 



    xcontext 'getSteps()', ->

        it 'collects the sequence of calls required to run all the leaves on any given branch', (done) -> 

            root     = context: tree: TREE
            opts     = uuid: NEST_ONE
            deferral = notify: ->


            Run.getSteps( root, opts, deferral ).then (steps) -> 

                # steps.map (step) -> 
                #     console.log FN: step.ref.fn.toString()

                i = 0
                steps[i++].ref.fn.toString().should.match /BEFORE-ALL-OUTSIDE/   # first all
                steps[i++].ref.fn.toString().should.match /BEFORE-EACH-OUTSIDE/
                steps[i++].ref.fn.toString().should.match /BEFORE-ALL-NESTED/    # first all
                steps[i++].ref.fn.toString().should.match /BEFORE-EACH-NESTED/
                steps[i++].ref.fn.toString().should.match                       /RUN_LEAF_ONE/
                steps[i++].ref.fn.toString().should.match /AFTER-EACH-NESTED/
                steps[i++].ref.fn.toString().should.match /AFTER-EACH-OUTSIDE/
                # 
                steps[i++].ref.fn.toString().should.match /BEFORE-EACH-OUTSIDE/
                steps[i++].ref.fn.toString().should.match /BEFORE-EACH-NESTED/
                # 
                steps[i++].ref.fn.toString().should.match /BEFORE-ALL-DEEP/      # first all
                steps[i++].ref.fn.toString().should.match /BEFORE-EACH-DEEP/
                steps[i++].ref.fn.toString().should.match                       /RUN_LEAF_TWO/
                steps[i++].ref.fn.toString().should.match /AFTER-EACH-DEEP/
                steps[i++].ref.fn.toString().should.match /AFTER-ALL-DEEP/       # last all
                # 
                steps[i++].ref.fn.toString().should.match /AFTER-EACH-NESTED/
                steps[i++].ref.fn.toString().should.match /AFTER-EACH-OUTSIDE/
                # 
                steps[i++].ref.fn.toString().should.match /BEFORE-EACH-OUTSIDE/
                steps[i++].ref.fn.toString().should.match /BEFORE-EACH-NESTED/
                steps[i++].ref.fn.toString().should.match                       /RUN_LEAF_THREE/
                steps[i++].ref.fn.toString().should.match /AFTER-EACH-NESTED/
                steps[i++].ref.fn.toString().should.match /AFTER-ALL-NESTED/    # last all
                steps[i++].ref.fn.toString().should.match /AFTER-EACH-OUTSIDE/
                steps[i++].ref.fn.toString().should.match /AFTER-ALL-OUTSIDE/   # last all
                # 
                should.not.exist steps[i++]

                done()


        it 'assigns step sets per leaf', (done) -> 

            root     = context: tree: TREE
            opts     = uuid: NEST_ONE
            deferral = notify: ->


            Run.getSteps( root, opts, deferral ).then (steps) -> 

                i = 0

                steps[i++].sets.should.eql [1,2,3] # first all
                steps[i++].set.should.equal 1
                steps[i++].sets.should.eql [1,2,3] # first all
                steps[i++].set.should.equal 1
                steps[i++].set.should.equal 1 # /RUN_LEAF_ONE/
                steps[i++].set.should.equal 1
                steps[i++].set.should.equal 1

                steps[i++].set.should.equal 2
                steps[i++].set.should.equal 2
                steps[i++].sets.should.eql [2]  # first all
                steps[i++].set.should.equal 2
                steps[i++].set.should.equal 2  # /RUN_LEAF_TWO/
                steps[i++].set.should.equal 2
                steps[i++].sets.should.eql [2]  # last all
                steps[i++].set.should.equal 2
                steps[i++].set.should.equal 2
                
                steps[i++].set.should.equal 3
                steps[i++].set.should.equal 3
                steps[i++].set.should.equal 3 # /RUN_LEAF_THREE/
                steps[i++].set.should.equal 3
                steps[i++].sets.should.eql [3,2,1] # last all
                steps[i++].set.should.equal 3
                steps[i++].sets.should.eql [3,2,1] # last all

                done()


        it 'assigns depth to each step', (done) -> 


            root     = context: tree: TREE
            opts     = uuid: NEST_ONE
            deferral = notify: ->


            Run.getSteps( root, opts, deferral ).then (steps) -> 

                i = 0

                steps[i++].depth.should.equal 1 # first all
                steps[i++].depth.should.equal 1
                steps[i++].depth.should.equal 2 # first all
                steps[i++].depth.should.equal 2
                steps[i++].depth.should.equal 3 # /RUN_LEAF_ONE/
                steps[i++].depth.should.equal 2
                steps[i++].depth.should.equal 1

                steps[i++].depth.should.equal 1
                steps[i++].depth.should.equal 2
                steps[i++].depth.should.equal 4  # first all
                steps[i++].depth.should.equal 4
                steps[i++].depth.should.equal 5  # /RUN_LEAF_TWO/
                steps[i++].depth.should.equal 4
                steps[i++].depth.should.equal 4  # last all
                steps[i++].depth.should.equal 2
                steps[i++].depth.should.equal 1
                
                steps[i++].depth.should.equal 1
                steps[i++].depth.should.equal 2
                steps[i++].depth.should.equal 3 # /RUN_LEAF_THREE/
                steps[i++].depth.should.equal 2
                steps[i++].depth.should.equal 2 # last all
                steps[i++].depth.should.equal 1
                steps[i++].depth.should.equal 1 # last all

                done()


        it 'notifies state', (done) -> 

            tick     = 0 
            Date.now = -> tick++
            root     = context: tree: TREE
            opts     = uuid: NEST_ONE
            UPDATES  = []
            deferral = notify: (update) -> UPDATES.push update


            Run.getSteps( root, opts, deferral ).then (steps) -> 

                # console.log UPDATES
                UPDATES.should.eql [
                    { update: 'scan::starting', at: 0 }
                    { update: 'scan::complete', at: 1, steps: 23, leaves: 3 }
                ]
                done()


        xit 'can run all leaves on a branch', (done) -> 

            MESSAGES = []
            tick     = 0
            Date.now = -> ++tick

            TOKEN.run( uuid: NEST_ONE ).then(

                (results) -> 

                    #
                    # overall results
                    #

                    MESSAGES.should.eql [

                        { timestamp: 1, update: 'running', total: 3, remaining: 3 }
                        { timestamp: 2, update: 'running', total: 3, remaining: 2 }
                        { timestamp: 3, update: 'running', total: 3, remaining: 1 }
                        { timestamp: 4, update: 'done',    total: 3, remaining: 0 }

                    ]

                    done()

                (error)   ->

                    #
                    # catastrofic
                    #

                    console.log ERROR: error

                (notify) -> 

                    #
                    # per leaf results, including errors
                    #
                    console.log '\n', notify
                    MESSAGES.push notify

            )

        it 'can run a single leaf'
        it 'can run all leaves on a branch'
        it 'can run all leaves in the tree'


