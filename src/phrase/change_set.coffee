{v1}    = require 'node-uuid'
{defer} = require 'when'

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

    class ChangeSet

        constructor: (@graphA, @graphB) -> 

            historyLength     = 1
            @uuid             = v1()
            @changes          = uuid: @uuid
            changeSets[@uuid] = this
            runningGraph      = @graphA
            newGraph          = @graphB

            order = []
            order.push uuid for uuid of changeSets
            delete changeSets[uuid] for uuid in order[ ..( -1 - historyLength) ]

            #
            # updated or deleted
            #

            for path of runningGraph.path2uuid

                runningUUID   = runningGraph.path2uuid[path]
                runningVertex = runningGraph.vertices[runningUUID]
                newUUID       = newGraph.path2uuid[path]

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

                    if changes.leaf?

                        @changes.updated ||= {}
                        @changes.updated[path] ||= {}
                        @changes.updated[path].leaf = changes.leaf


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

            for path of newGraph.path2uuid 

                unless runningGraph.path2uuid[path]?

                    #
                    # missing from runningGraph
                    #

                    uuid   = newGraph.path2uuid[path]
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

                    uuid = @graphA.path2uuid[path]
                    delete @graphA.path2uuid[path]
                    delete @graphA.uuid2path[uuid]

                    try 
                        parent = @graphA.parent[uuid]
                        @graphA.edges[parent] = @graphA.edges[parent].filter (edge) -> edge.to != uuid

                    delete @graphA.edges[uuid]
                    delete @graphA.parent[uuid]
                    delete @graphA.children[uuid]
                    delete @graphA.vertices[uuid]


            if @changes.created?

                for path of @changes.created

                    uuid = @changes.created[path].uuid
                    @graphA.vertices[uuid]  = @changes.created[path]
                    @graphA.path2uuid[path] = @changes.created[path].uuid
                    @graphA.uuid2path[uuid] = path

                    parentB = @graphB.parent[uuid]
                    parent  = @graphA.path2uuid[ @graphB.uuid2path[ parentB ] ]
                    @graphA.edges[uuid]    = [to: parent]
                    @graphA.edges[parent] ||= []
                    @graphA.edges[parent].push to: uuid
                                            #
                                            # not preserving order in edge array 
                                            #


            #
            # rebuild indexes 
            # ---------------
            #
            # TODO: This is very inefficient. It rebuilds the indexes in graphA according 
            #       to the contents of the new graphB, but preserving the uuids from 
            #       the uuids of graphA.
            # 
            #       It would be better (for large graphs), to only modify the indexes
            #       where necessary.
            # 
            #       Preserving the order is important 
            #       (not always, make preserving order a configurable)
            #

            stillParent = {}
            #stillChild  = {}
            for parentUUID of @graphB.children
                parent = @graphA.path2uuid[ @graphB.uuid2path[parentUUID] ] || parentUUID
                @graphA.children[parent] = []
                #
                # translated graphB parentUUID to corresponding uuid in graphA
                # and created a new children index with it
                #

                stillParent[parent] = not @graphB.vertices[parentUUID].leaf

                for childUUID in @graphB.children[parentUUID] 
                    child = @graphA.path2uuid[ @graphB.uuid2path[childUUID] ] || childUUID
                    @graphA.children[parent].push child
                    @graphA.parent[child] = parent

                    #
                    # translated graphB childUUID to corresponding uuid in graphA
                    # and ammended parent / children indexes
                    #
            
            for parentUUID of @graphA.children
                unless stillParent[parentUUID]
                    delete @graphA.children[parentUUID]


            @graphA.leaves.length = 0
            for leaf in @graphB.leaves
                @graphA.leaves.push @graphA.path2uuid[ @graphB.uuid2path[leaf] ] || leaf


            if @changes.updated?

                for path of @changes.updated

                    target = @graphA.vertices[ @graphA.path2uuid[path] ]
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

                                parentUUID = @graphA.path2uuid[path]

                                for childUUID in @graphA.children[parentUUID]

                                    @graphA.vertices[childUUID].hooks[type] = newHook





    Object.defineProperty ChangeSet, 'applyChanges', 
        enumarable: true
        get: -> (uuid, direction) -> 

            doing = defer()
            process.nextTick ->
                return doing.reject new Error( 

                    'ChangeSet.applyChanges() has no set with uuid: ' + uuid

                ) unless changeSets[uuid]?
                doing.resolve changeSets[uuid][ direction || 'AtoB' ]()

            doing.promise

