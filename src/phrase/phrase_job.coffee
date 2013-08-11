{v1}    = require 'node-uuid'
{defer} = require 'when'

module.exports = class PhraseJob

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

            state:   'running'
            class:    @constructor.name
            uuid:     @uuid
            progress: @progress()
            at:       Date.now()

        process.nextTick => 

            step.fn.call this for step in @steps

            @deferral.notify 

                state:   'succeeded'
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