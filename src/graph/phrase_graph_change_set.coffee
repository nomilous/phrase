{v1}    = require 'node-uuid'

exports.createClass = (root) -> 

    #
    # PhraseGraphChangeSets (class factory)
    # =====================================
    #
    # * Stores the set of changes to be applied to a graph to 
    #   advance it to the next ersion.
    # 
    # * And probably the corresponding inverse set, for retreat.
    # 
    # * And will probably store these change set pairs in the
    #   context.walks (history array) for sequenceing multiple
    #   changes.
    #   
    # * Also, 
    #      
    #        It's an obvious 'complexity bomb' 
    # 
    #        And won't be fully implemented now, 
    # 
    #        ( just wanna clear up the phrase graph 
    #             definition for now, file's getting 
    #                too big... )
    # 

    changeSets = {}

    class PhraseGraphChangeSet

        constructor: (@graphA, @graphB) -> 

            @uuid             = v1()
            @changes          = uuid: @uuid
            changeSets[@uuid] = this
            runningGraph      = @graphA
            newGraph          = @graphB
            
            #
            # updated or deleted
            #

            

            for path of runningGraph.paths

                runningUUID   = runningGraph.paths[path]
                runningVertex = runningGraph.vertices[runningUUID]
                newUUID       = newGraph.paths[path]

                unless newUUID?

                    #
                    # missing from newGraph
                    #

                    @changes.deleted ||= {}
                    @changes.deleted[path] = runningVertex
                    continue

                #
                # in both graphs
                #

                newVertex = newGraph.vertices[newUUID]

                if changes = runningVertex.getChanges newVertex

                    if changes.fn?

                        if runningVertex.leaf # and newVertex.leaf
                                              # 
                                              # would prevent leaf that is becoming
                                              # vertex with nested leaf(s) from 
                                              # reporting as updated
                                              # 

                            #
                            # * only leaf vertexes are eligable for fn update
                            #   branch vertex fns contain all nested leaf vertexes
                            # 
                            # * they and should have no body of their own 
                            #   (other than hooks)
                            #

                            @changes.updated ||= {}
                            @changes.updated[path] ||= {}
                            @changes.updated[path].fn = changes.fn


                    if changes.timeout?

                        #
                        # if runningVertex.leaf # and newVertex.leaf
                        # 
                        # * timeout change on a branch vertex should be applied
                        #   (all nested phrases inherit it)
                        #

                        @changes.updated ||= {}
                        @changes.updated[path] ||= {}
                        @changes.updated[path].timeout = changes.timeout


                    if changes.hooks? 

                        #
                        # #GREP2
                        # 
                        # * hooks are discovered on branch vertices (by the recursor), but 
                        #   not stored there, instead a reference to the hooks is inserted 
                        #   into each nested phrase
                        # 
                        # * therefore, when a hook is found changed on a phrase, it is
                        #   a hook common across all nested phrases, and the vertex that 
                        #   should be reported as changed is the parent because observers 
                        #   will want to re-run all leaves affected by the change in a 
                        #   single run (per calling the parent to run)
                        #

                        parentPath = path.split('/')[..-3].join '/'
                        @changes.updated ||= {}
                        @changes.updated[parentPath] ||= {}
                        @changes.updated[parentPath].hooks  = changes.hooks
                        @changes.updated[parentPath].target = changes.target


            #
            # created
            #

            for path of newGraph.paths 

                unless runningGraph.paths[path]?

                    #
                    # missing from runningGraph
                    #

                    uuid   = newGraph.paths[path]
                    vertex = newGraph.vertices[uuid]

                    @changes.created ||= {}
                    @changes.created[path] = vertex
                    continue

            #
            # TODO: consider only reporting changed parent if both the 
            #       parent and the child changed
            # 
            #       observers that are performing action on change would 
            #       otherwise need to perform that summary so as not to
            #       run the changed child twice (once of which as a con-
            #       sequence of the changed parent)
            #       
            #

        AtoB: -> 

            #
            # IMPORTANT - no breakout in this update
            #

            if @changes.deleted?

                for path of @changes.deleted

                    #
                    # consider keeping it for BtoA (later)
                    #

                    uuid   = @graphA.paths[path]
                    delete @graphA.vertices[uuid]


            if @changes.created?

                for path of @changes.created

                    uuid = @changes.created[path].uuid
                    @graphA.vertices[uuid] = @changes.created[path]


            #
            # TODO: rebuild (or adjust) indexes for new and removed uuids
            #       preserve created order
            #


            if @changes.updated?

                for path of @changes.updated

                    target = @graphA.vertices[ @graphA.paths[path] ]
                    target.update @changes.updated[path]


                    #
                    # HAC! - Result of having implementing phrase hooks as nested shared
                    #        by reference into each affected PhraseNode, 
                    # 
                    #      - If the change is creating a hook, then ref to the new  hook
                    #        needs to copied into all peer phrases. 
                    # 
                    #      - AND a uuid needs to be assigned, normally happens here #GREP3
                    #      
                    #      - AND the one that did happen there belongs to the other tree
                    #                                          best to keep it that way!...?
                    #                                          same object lives in both graphs on create
                    #                                     
                    # 
                    #      - alternatively the change detector could include the entire 
                    #        list of leaves that the created hook affects.
                    # 
                    #             will then need a mechanism for the observer to
                    #             identify overlap in the reported changes to
                    #             allow the simplest call to re-apply / hup
                    #            

                    if @changes.updated[path].hooks?

                        for type in ['beforeAll', 'beforeEach', 'afterEach', 'afterAll']

                            hook = @changes.updated[path].hooks[type]

                            if hook? and not ( hook.fn.from? or hook.timeout.from? )

                                #
                                # create new hook on all children
                                #

                                newHook = new root.context.PhraseNode.PhraseHook

                                    #
                                    # should have had   change.from.propety
                                    # instead of        change.property.from
                                    #

                                    timeout: hook.timeout.to
                                    fn:      hook.fn.to

                                parentUUID = @graphA.paths[path]

                                for childUUID in @graphA.children[parentUUID]

                                    @graphA.vertices[childUUID].hooks[type] = newHook



    Object.defineProperty PhraseGraphChangeSet, 'applyChanges', 
        enumarable: true
        get: -> (uuid, direction) -> 

            changeSet = changeSets[uuid]
            changeSet[ direction || 'AtoB' ]()

