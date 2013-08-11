{v1} = require 'node-uuid'

module.exports = class PhraseJob

    constructor: (opts = {}) -> 

        opts.running ||= notify: (update) -> 
            console.log 'PhraseJob:', JSON.stringify update
        opts.uuid    ||= v1()

        localOpts =
            progress: 
                steps: if opts.steps? then opts.steps.length else 0
                done:  0

        for property in ['uuid', 'steps', 'running', 'done', 'progress']

                                #
                                # silent properties
                                #

            do (property) =>

                Object.defineProperty this, property,

                    enumerable: false
                    get: -> opts[property] || localOpts[property]
            

    start: ->

        # @progress.done++

        @running.notify 

            class:   @constructor.name
            uuid:    @uuid
            action:  'start'
            progress: @progress
            at:       Date.now()
