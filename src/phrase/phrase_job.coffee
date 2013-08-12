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

                #
                # storage for progress indication
                #

                progress: -> 
                    steps: if opts.steps? then opts.steps.length else 0
                    done:  0

            #
            # reserved / silent properties
            #

            for property in ['uuid', 'steps', 'deferral', 'progress']

                do (property) =>

                    Object.defineProperty this, property,

                        enumerable: false
                        get: -> opts[property] || localOpts[property]
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

                

        run: ->

            running = defer()

            @deferral.notify 

                state:   'run::starting'
                class:    @constructor.name
                uuid:     @uuid
                progress: @progress()
                at:       Date.now()

            sequence( @steps.map (step) => 

                #
                # each job step is called through the async injector
                #

                inject.async 

                    #
                    # step.ref.fn is the injection target and will be called with
                    # arguments as determined by this injector
                    # 

                    beforeEach: (done, control) => 

                        #
                        # extract the deferral that the injector has associated
                        # with the running of the injection target
                        #

                        defer = control.defer

                        unless control.signature[0] == 'done'

                            #
                            # this step is not async
                            # ----------------------
                            # 
                            # the promise therefore needs to be maually resolved
                            #

                            process.nextTick -> defer.resolve()
                            done()
                            return

                        #
                        # this step is async
                        # ------------------
                        # 
                        # start timeout as defined as defined on step
                        # 

                        timeout = setTimeout (=>

                            #
                            # notify parent of timeout
                            # 

                            running.notify 

                                event: 'timeout'
                                class: @constructor.name
                                uuid:  @uuid
                                step:  step
                                at:    Date.now()

                            #
                            # for now: resolve on timeout to let the remaining 
                            # job steps run
                            # 
                            defer.resolve()
                            #
                            # TODO: handle timeouts per step type, beforeAll and 
                            #       beforeEach timeouts might not affect all leaves
                            #       in the run. 
                            #


                        ), step.ref.timeout || 2000

                        control.args[0] = -> 

                            #
                            # custom resolver passed as (done, ...) to
                            # step function clears the timeout
                            #

                            

                            clearTimeout timeout

                            console.log 'RESOLVED'
                            defer.resolve()

                        done()

                    afterEach: (done, control) -> 

                        unless control.signature[0] == 'done'

                            #
                            # step.ref.fn has been called, but no resolver 
                            # was injected, the promise associated with the
                            # call therefore requires manual resolution
                            # 

                            control.defer.resolve()
                        
                        done()

                    #
                    # injection target
                    #

                    step.ref.fn

            ).then => 

                @deferral.notify 

                    state:   'run::complete'
                    class:    @constructor.name
                    uuid:     @uuid  
                    progress: @progress()
                    at:       Date.now()

                running.resolve 

                    #
                    # job instance on subkey leaves room for 
                    # metadata (necessary later...)
                    # 

                    job: this

            return running.promise