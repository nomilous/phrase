{v1} = require 'node-uuid'

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

            progress: 
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

                        opts.deferral.reject new Error "Cannot assign reserved property: #{property}(=#{value})"




            

    start: ->

        @deferral.notify 

            class:    @constructor.name
            uuid:     @uuid
            action:   'start'
            progress: @progress
            at:       Date.now()
