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
                get: -> (changes) -> 

                    for thing in ['fn', 'timeout']

                        if changes[thing]? 

                            localOpts[thing] = changes[thing].to


        getChanges: (vertex) -> 

            #
            # * reports only on changes
            # * returns {} or {  
            #       
            #       # approximately: 
            # 
            #       target:  [PhraseNode (this)]
            #  
            #       fn: 
            #          from: [function]
            #          to:   [function]
            #
            #  
            #       hooks:
            #          beforeAll: 
            #              from: [function]
            #              to:   [function]
            # 
            # 
            #   } 
            # 
            # * The target is included to provide a direct reference to the
            #   the change destination (the results of this function are used
            #   by the PhraseGraph to assemble a changeSet, which could likely
            #   be queued and applied onto the graph by later instruction)
            # 
            # * The target is specifically used for cases where the change
            #   is a hook. In these cases the changeset refers to the parent
            #   vertex (where the hook is more logically resident) as the 
            #   changed resource. Without the target still pointing at the
            #   child vertex the process applying the change would have no
            #   access to the hook to change. 
            # 
            #      (Hooks are stored in the children, by reference, 
            #       all pointing to the same actual hook instance)
            # 

            changes = undefined

            for property in ['fn', 'timeout']

                if @[property].toString() != vertex[property].toString()
                    
                    changes ||= target: this
                    changes[property] = 
                        from: @[property]
                        to: vertex[property]

            for hookType in ['beforeAll', 'beforeEach', 'afterEach', 'afterAll']

                currentFn      = try @hooks[hookType].fn.toString()
                currentTimeout = try @hooks[hookType].timeout
                latestFn       = try vertex.hooks[hookType].fn.toString()
                latestTimeout  = try vertex.hooks[hookType].timeout

                if currentFn != latestFn

                    changes ||= target: this
                    changes.hooks ||= {}
                    changes.hooks[hookType] ||= {}
                    changes.hooks[hookType].fn = 
                        from: try @hooks[hookType].fn
                        to: try vertex.hooks[hookType].fn

                if currentTimeout != latestTimeout

                    changes ||= target: this
                    changes.hooks ||= {}
                    changes.hooks[hookType] ||= {}
                    changes.hooks[hookType].timeout = 
                        from: try @hooks[hookType].timeout
                        to: try vertex.hooks[hookType].timeout

            return changes


