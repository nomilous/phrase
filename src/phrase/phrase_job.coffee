{v1}         = require 'node-uuid'
{defer}      = require 'when'
sequence     = require 'when/sequence'

exports.create = (root) -> 

    #
    # PhraseJob (class factory)
    # =========================
    # 
    # Has root access factory create() scope
    #

    {inject} = root

    class PhraseJob

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
                notify: (update) -> console.log 'PhraseJob:', JSON.stringify update

            localOpts =

                progress: -> 

                    steps: if opts.steps? then opts.steps.length else 0
                    done:  opts.steps.filter( (s) -> s.done ).length


            #
            # reserved / silent properties
            #

            for property in ['uuid', 'steps', 'deferral', 'progress']

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


        handleError: (error, done) -> 

            errored  = undefined
            nextleaf = undefined


            @steps.map (s) -> 

                if s.done then errored = s
                else if errored? and not nextleaf?
                        nextleaf = s if s.type == 'leaf'

            # #if errored.type == 'hook' 

            console.log HANDLE_ERROR_HOOK: errored
            console.log NEXT_LEAF: nextleaf
            

            done()
                

        run: ->

            #
            # notifies onto parent's deferral
            # 
            #  token.run( ... ).then(
            #     (result) -> 
            #     (error)  -> 
            #     (notify) ->   # HERE
            #  )
            #

            @deferral.notify 

                state:   'run::starting'
                class:    @constructor.name
                jobUUID:  @uuid
                progress: @progress()
                at:       Date.now()



            #
            # a local deferral for the promise of this step run
            #

            running = defer()

            sequence( @steps.map (step) => 


                #
                # a previous step in this set errored or timed out
                #

                if step.done then return => 

                    if step.type == 'leaf'

                        @deferral.notify 

                            event:    'skip'
                            class:    @constructor.name
                            jobUUID:  @uuid
                            progress: @progress()
                            at:       Date.now()
                            #step:     step




                #
                # each job step is called through the async injector
                #

                inject.async 

                    #
                    # step.ref.fn is the injection target
                    # -----------------------------------
                    # console.log step 
                    # 
                    # * and will be called with arguments as determined 
                    #   by this injector
                    # 
                    # * and is run on this as context
                    # 
                    # * and is set to notifiy instead of reject on error
                    # 

                    context: this
                    notifyOnError: true

                    beforeEach: (done, control) => 

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
                            # BUG: Non async steps to don't notify on error
                            # process.nextTick -> targetDefer.resolve()
                            # 
                            # nasty fix...
                            # 
                            setTimeout targetDefer.resolve, 1
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

                            #
                            # notify on the promise
                            # 

                            targetDefer.notify 

                                event: 'timeout'
                                class: @constructor.name
                                jobUUID:  @uuid
                                at:    Date.now()
                                defer: targetDefer


                        ), step.ref.timeout || 2000

                        control.args[0] = -> 

                            #
                            # custom resolver passed as (done, ...) to
                            # the target function
                            #

                            clearTimeout timeout
                            targetDefer.resolve()

                        done()
                        return


                    afterEach: (done) => 

                        step.done = true

                        @deferral.notify

                            state:   'run::started'
                            class:    @constructor.name
                            jobUUID:  @uuid
                            progress: @progress()
                            at:       Date.now()

                        done()


                    #
                    # injection target
                    #

                    step.ref.fn

            ).then(

                 => 

                    @deferral.notify 

                        state:   'run::complete'
                        class:    @constructor.name
                        jobUUID:  @uuid
                        progress: @progress()
                        at:       Date.now()

                    running.resolve 

                        #
                        # job instance on subkey leaves room for 
                        # metadata (necessary later...)
                        # 

                        job: this

                (error)  -> console.log 'ERROR_IN_PHRASE_JOB', error.stack

                (notify) => 

                    if notify.event == 'error' or notify.event == 'timeout'

                        @handleError notify, -> 

                            notify.defer.resolve()
                            delete notify.defer
                            running.notify notify

            )

            return running.promise