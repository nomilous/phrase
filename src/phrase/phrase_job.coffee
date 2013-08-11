{v1} = require 'node-uuid'

module.exports = class PhraseJob

    constructor: (opts = {}) -> 

        #
        # job uuid can be assigned (allows resume, later...)
        #

        opts.uuid ||= v1()

        #
        # job deferrral is optional (if not present logs to console)
        #

        opts.deferral ||= notify: (update) -> console.log 'PhraseJob:', JSON.stringify update


        localOpts =

            #
            # storage for progress indication
            #

            progress: 
                steps: if opts.steps? then opts.steps.length else 0
                done:  0

        #
        # silent properties
        #

        for property in ['uuid', 'steps', 'deferral', 'done', 'progress']

            do (property) =>

                Object.defineProperty this, property,

                    enumerable: false
                    get: -> opts[property] || localOpts[property]
            

    start: ->

        # @progress.done++

        @deferral.notify 

            class:    @constructor.name
            uuid:     @uuid
            action:   'start'
            progress: @progress
            at:       Date.now()
