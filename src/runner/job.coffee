{v1}         = require 'node-uuid'
{defer}      = require 'when'
sequence     = require 'when/sequence'

exports.createClass = (root) -> 

    #
    # Job (class factory)
    # =========================
    # 
    # Has root access factory create() scope
    #

    {inject, context} = root
    {notice}          = context

    return class Job

        constructor: (opts = {}) -> 

            #
            # job uuid can be assigned (allows resume, later...)
            #

            opts.uuid ||= v1()

            #
            # job deferrral is optional
            #

            opts.deferral ||= 

                reject: (error)  -> throw error
                notify: (update) -> console.log 'Job:', JSON.stringify update

            localOpts =

                notice: notice

                progress: -> 

                    steps:   if opts.steps? then opts.steps.length else 0
                    done:    opts.steps.filter( (s) -> s.done ).length
                    failed:  opts.steps.filter( (s) -> s.fail ).length
                    skipped: opts.steps.filter( (s) -> s.skip ).length


            #
            # reserved / silent properties
            #

            for property in ['notice', 'uuid', 'steps', 'deferral', 'progress']

                do (property) =>

                    Object.defineProperty this, property,

                        enumerable: false
                        get: -> localOpts[property] || opts[property]
                        set: (value) -> 

                            #
                            # reject the deferral on attempt to assign
                            # value to reserved property
                            #

                            #
                            # TODO: state 'failed' (maybe...) 
                            # 
                            #       the jobs steps will likely be divided into sets
                            #       because a rejection emanating from a hook that 
                            #       only affects the nested leaves whould not cause
                            #       a global failure across all leaves in the job
                            # 

                            opts.deferral.reject new Error "Cannot assign reserved property: #{property}(=#{value})"
                            localOpts.skipped = true

 
            Object.defineProperty this, 'skipped', 
                enumarable: false
                get: -> localOpts.skipped || false
                set: (value) -> 

                    #
                    # assignable only once
                    #

                    localOpts.skipped = value unless localOpts.skipped?


            #
            # job parameters
            #

            if opts.params? then @[param] = opts.params[param] for param of opts.params


        run: ->

            #
            # a local deferral for the promise of this step run
            #

            running = defer()

            if @skipped 

                process.nextTick => running.resolve job: this
                return running.promise

            message = 

                update:  'run::starting'
                class:    @constructor.name
                jobUUID:  @uuid
                progress: @progress()
                at:       Date.now()

            @notice.event( message.update, message ).then => 

                            #
                            # asynchronous notification
                            # -------------------------
                            # 
                            # * traverses this phrase tree's message bus 
                            # 
                            # * job is not started until the message has 
                            #   traversed the middleware pipeline
                            #
               
                @deferral.notify message

                    #
                    # synchronous notification
                    # ------------------------
                    # 
                    # * notifies onto parent's deferral
                    # 
                    #     token.run( ... ).then(
                    #        (result) -> 
                    #        (error)  -> 
                    #        (notify) ->   # HERE
                    #     )
                    #


                sequence( @steps.map (step) => 


                    #
                    # each job step is called through the async injector
                    # --------------------------------------------------
                    #
                    # * step.ref.fn is the injection target
                    # 
                    # * it will be called with arguments as determined 
                    #   by this injector
                    # 
                    # * it is run with this (Job instance) as context
                    # 
                    #      eg. this... 
                    # 
                    #          
                    #          phrase 'root title', (nested) -> 
                    # 
                    #              before each: (done) -> 
                    # 
                    #                  @variable = 'VALUE'
                    #                  done()
                    # 
                    #              nested 'nested title', (end) -> 
                    # 
                    #                  console.log @variable   #=> 'VALUE'
                    #                  end()
                    # 
                    #          ...is possible
                    # 


                    injectionConfig =  

                        context: this

                        onError: (done, context, error) => 


                            #
                            # error or timeout in leaf or hook
                            # --------------------------------
                            # 
                            # * the injector is awaiting the call to done() before
                            #   it proceeds onto the next step in the job
                            # 
                            # * this error handler flags all remaining (affected) 
                            #   steps in the set to be skipped
                            # 
                            #      eg. if a beforeAll fails on some node in the 
                            #          phrase tree, all nested nodes are skipped.
                            # 

                            skipped = []

                            for s in @steps

                                continue if s.depth < step.depth

                                if step.set? 

                                    if s.set? then continue unless s.set == step.set

                                else

                                    if s.set? 

                                        intersect = (
                                            step.sets.filter (skipSet) -> 
                                                s.set == skipSet
                                        )

                                        continue unless intersect.length > 0

                                    else 

                                        intersect = (
                                            step.sets.filter (skipSet) -> 
                                                for hasSet in s.sets
                                                    return true if hasSet == skipSet
                                        )

                                        continue unless intersect.length > 0
                                

                                if s is step 
                                    s.fail = true 
                                    update = 'run::step:failed'  
                                else 
                                    s.skip = true
                                    update = 'run::step:skipped'
                                    skipped.push s


                                @deferral.notify

                                    update:     update
                                    class:      @constructor.name
                                    jobUUID:    @uuid
                                    progress:   @progress()
                                    at:         Date.now()
                                    error:      error
                                    step:       step
                                    originator: s == step


                            @notice.event( 'run::step:failed',  

                                    update:     'run::step:failed'
                                    class:      @constructor.name
                                    jobUUID:    @uuid
                                    progress:   @progress()
                                    at:         Date.now()
                                    error:      error
                                    step:       step
                                    skipped:    skipped

                            ).then done


                        beforeEach: (done, control) => 


                            #
                            # an error or timeout in preceding step
                            # -------------------------------------
                            # 
                            # * skip this step
                            # 

                            if step.skip

                                control.skip()
                                done()

                            #
                            # Timeout initiates async errorHandler, if it fires 
                            # then the resolution that could concievably still 
                            # occurr while the timeout handler is running must
                            # be ignored.
                            # 
                            # Ordinarilly this sort of thing would be handled 
                            # by rejecting or resolving the promise that timed
                            # out, but it is that same promise that is being 
                            # used by the timeout handler to stop the flow
                            # of execution from from proceeding into the next 
                            # step. 
                            # 
                            # If the promise is resolved before the timeout 
                            # handler completes that will lead to undesired
                            # concurrencies.
                            #

                            hasTimedOut = false


                            #
                            # extract the deferral that the injector has associated
                            # with the running of the injection target
                            #

                            targetDefer = control.defer

                            unless (

                                #
                                # leaves always have the resolver injected
                                # 

                                step.type == 'leaf' || 

                                #
                                # hardcoded resolver signature for hooks 
                                # 

                                control.signature[0] == 'done'

                            )

                                #
                                # this step is not async
                                # ----------------------
                                # 
                                # the promise therefore needs to be maually resolved
                                #
                                # 

                                process.nextTick -> targetDefer.resolve()
                                done()
                                return
                                #
                                # target function is now called (by the injector)
                                #



                            #
                            # this step is async
                            # ------------------
                            # 
                            # start timeout as defined on step
                            # 

                            timeout = setTimeout (=>


                                hasTimedOut = true
                                injectionConfig.onError targetDefer.resolve, {}, new Error 'timeout'


                            ), step.ref.timeout || 2000

                            control.args[0] = -> 

                                #
                                # custom resolver passed as (done, ...) to
                                # the target function
                                #

                                clearTimeout timeout

                                #
                                # if the timeout has already fired 
                                # this resolver is too late...
                                # 

                                return if hasTimedOut
                                targetDefer.resolve()


                            done()
                            return


                        afterEach: (done) => 
                            
                            unless step.skip or step.fail

                                step.done = true

                                message = 

                                    update:   'run::step:done'
                                    class:    @constructor.name
                                    jobUUID:  @uuid
                                    progress: @progress()
                                    at:       Date.now()
                                    step:     step

                                return @notice.event( message.update, message ).then => 

                                    @deferral.notify message
                                    done()

                            done()


                    inject.async injectionConfig, step.ref.fn


                ).then(

                     => 

                        message = 

                            update:   'run::complete'
                            class:    @constructor.name
                            jobUUID:  @uuid
                            progress: @progress()
                            at:       Date.now()

                        @notice.event( message.update, message ).then => 

                            @deferral.notify message

                            running.resolve 

                                #
                                # job instance on subkey leaves room for 
                                # metadata (necessary later...)
                                # 

                                job: this


                    (error)  -> console.log 'ERROR_IN_PHRASE_JOB', error.stack

                    (notify) -> 

                        #
                        # cannot suspend 'flow of execution' into the next steps
                        # (and needs to - to skip the next steps in the erroring set)
                        #
                        # if notify.event == 'error' or notify.event == 'timeout'
                        #     @handleError notify, -> 
                        #         notify.defer.resolve()
                        #         delete notify.defer
                        #         running.notify notify

                )

            return running.promise


