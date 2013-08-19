{v1} = require 'node-uuid'

exports.createClass = (root) -> 

    #
    # PhraseNode (class factory)
    # ==========================
    # 

    class PhraseNode

        #
        # nested classes
        # --------------
        # 
        # ### PhraseToken
        # 
        # * Comes into play later (PhraseWalkers)
        # * For now only carries name 
        # 
        #    thisThing 'is a token', (end) -> 
        #         
        #    the resulting phraseNode: 
        # 
        #    token: 
        #        name: 'thisThing'
        #    test:  'is a token'
        #    fn:    (end) ->   
        # 

        class PhraseToken 

            constructor: (opts = {}) -> 

                localOpts = {}

                for property in ['name', 'uuid']

                    do (property) => 

                        localOpts[property] = opts[property]

                        Object.defineProperty this, property, 
                            get: -> localOpts[property]
                            enumerable: true

        #
        # ### PhraseHook
        # 
        # TODO: after merge (and enlightenment)
        #

        class PhraseHook

        #
        # ### PhraseHooks 
        # 
        # * The set of hooks that each phrase posses.
        # 
        # IMPORTANT The hooks assigned to each nested phrase
        #           contain reference to a common hook instance 
        #           that was created by the parent phrase.
        # 
        #           Changing a hook should change all hooks 
        #           on the peer phrases.
        # 
        #   TODO:   Ensure that this is the case.
        #             
        #

        class PhraseHooks

            constructor: (opts = {}) -> 

                localOpts = {}

                for property in ['beforeAll', 'beforeEach', 'afterEach', 'afterAll']

                    do (property) => 

                        localOpts[property] = opts[property]

                        Object.defineProperty this, property, 
                            get: -> localOpts[property]
                            enumerable: true


        constructor: (opts = {}) -> 

            localOpts = 

                #
                # enumarable
                #

                uuid:      opts.uuid  || v1()
                text:      opts.text
                leaf:      opts.leaf

                #
                # not enumarable
                #

                fn:        opts.fn
                timeout:   opts.timeout || 2000
                hooks:     new PhraseHooks opts.hooks
                deferral:  opts.deferral
                queue:     opts.queue

            #
            # copy uuid into token
            #

            opts.token.uuid = localOpts.uuid
            localOpts.token = new PhraseToken opts.token


            for property in ['uuid', 'token', 'text']

                do (property) => 

                    Object.defineProperty this, property, 
                        get: -> localOpts[property]
                        enumerable: true


            for property in ['fn', 'timeout', 'hooks', 'deferral', 'queue']

                do (property) => 

                    Object.defineProperty this, property, 
                        get: -> localOpts[property]
                        enumerable: false

            Object.defineProperty this, 'leaf',

                enumerable: true
                get: -> localOpts.leaf
                set: (value) -> 
                    return if localOpts.leaf?
                    localOpts.leaf = value






            Object.defineProperty this, 'update', 

                enumerable: false
                set: (opts) -> 

                    localOpts.fn = opts.fn || localOpts.fn


        wasUpdatedBy: (vertex) -> 

            if @fn.toString() != vertex.fn.toString()
                
                @update = fn: vertex.fn

                return true

            return false

