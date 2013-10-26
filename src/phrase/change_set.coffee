{deferred} = require 'also'

exports.createClass = (root) -> 

    #
    # ChangeSets (class factory)
    # ==========================
    #
    # * Stores the set of changes to be applied to a tree to 
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
    #        ( just wanna clear up the phrase tree 
    #             definition for now, file's getting 
    #                too big... )
    # 

    #
    # ##undecided3 
    # 
    # * reimplement tree as nested notice hubs
    # * edge middleware contains call to nested hub pupeline
    # * nested can do the same   ...((star topology) for now)
    # * each standalone for now
    # * ((i can't ""see"" all the way to the end of this road)) but it ""feels"" right
    #


    {util} = root

    changeSets = {}

    class ChangeSet

        constructor: (@treeA, @treeB) -> 

            historyLength     = 1
            @uuid             = util.uuid()
            @changes          = uuid: @uuid
            changeSets[@uuid] = this
            runningTree       = @treeA
            newTree           = @treeB

            order = []
            order.push uuid for uuid of changeSets
            delete changeSets[uuid] for uuid in order[ ..( -1 - historyLength) ]

            #
            # updated or deleted
            #

            for path of runningTree.path2uuid

                runningUUID   = runningTree.path2uuid[path]
                runningVertex = runningTree.vertices[runningUUID]
                newUUID       = newTree.path2uuid[path]

                unless newUUID?

                    #
                    # missing from newTree
                    #

                    @changes.deleted ||= {}
                    @changes.deleted[path] = runningVertex
                    continue

                #
                # in both trees
                #

                newVertex = newTree.vertices[newUUID]

                if changes = runningVertex.getChanges newVertex

                    if changes.type?

                        @changes.updated ||= {}
                        @changes.updated[path] ||= {}
                        @changes.updated[path].type = changes.type


                    if changes.fn?

                        if runningVertex.token.type == 'leaf' # and newVertex.type == 'leaf'
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

            for path of newTree.path2uuid 

                unless runningTree.path2uuid[path]?

                    #
                    # missing from runningTree
                    #

                    uuid   = newTree.path2uuid[path]
                    vertex = newTree.vertices[uuid]

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

                    uuid = @treeA.path2uuid[path]
                    delete @treeA.path2uuid[path]
                    delete @treeA.uuid2path[uuid]

                    try 
                        parent = @treeA.parent[uuid]
                        @treeA.edges[parent] = @treeA.edges[parent].filter (edge) -> edge.to != uuid

                    delete @treeA.edges[uuid]
                    delete @treeA.parent[uuid]
                    delete @treeA.children[uuid]
                    delete @treeA.vertices[uuid]


            if @changes.created?

                for path of @changes.created

                    uuid = @changes.created[path].uuid
                    @treeA.vertices[uuid]  = @changes.created[path]
                    @treeA.path2uuid[path] = @changes.created[path].uuid
                    @treeA.uuid2path[uuid] = path

                    parentB = @treeB.parent[uuid]
                    parent  = @treeA.path2uuid[ @treeB.uuid2path[ parentB ] ]
                    @treeA.edges[uuid]    = [to: parent]
                    @treeA.edges[parent] ||= []
                    @treeA.edges[parent].push to: uuid
                                            #
                                            # not preserving order in edge array 
                                            #


            #
            # rebuild indexes 
            # ---------------
            #
            # TODO: This is very inefficient. It rebuilds the indexes in treeA according 
            #       to the contents of the new treeB, but preserving the uuids from 
            #       the uuids of treeA.
            # 
            #       It would be better (for large trees), to only modify the indexes
            #       where necessary.
            # 
            #       Preserving the order is important 
            #       (not always, make preserving order a configurable)
            #

            stillParent = {}
            #stillChild  = {}
            for parentUUID of @treeB.children
                parent = @treeA.path2uuid[ @treeB.uuid2path[parentUUID] ] || parentUUID
                @treeA.children[parent] = []
                #
                # translated treeB parentUUID to corresponding uuid in treeA
                # and created a new children index with it
                #

                stillParent[parent] = not @treeB.vertices[parentUUID].leaf

                for childUUID in @treeB.children[parentUUID] 
                    child = @treeA.path2uuid[ @treeB.uuid2path[childUUID] ] || childUUID
                    @treeA.children[parent].push child
                    @treeA.parent[child] = parent

                    #
                    # translated treeB childUUID to corresponding uuid in treeA
                    # and ammended parent / children indexes
                    #
            
            for parentUUID of @treeA.children
                unless stillParent[parentUUID]
                    delete @treeA.children[parentUUID]


            @treeA.leaves.length = 0
            for leaf in @treeB.leaves
                @treeA.leaves.push @treeA.path2uuid[ @treeB.uuid2path[leaf] ] || leaf


            if @changes.updated?

                for path of @changes.updated

                    target = @treeA.vertices[ @treeA.path2uuid[path] ]
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
                    #                                          same object lives in both trees on create
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

                                parentUUID = @treeA.path2uuid[path]

                                for childUUID in @treeA.children[parentUUID]

                                    @treeA.vertices[childUUID].hooks[type] = newHook





    Object.defineProperty ChangeSet, 'applyChanges', 
        enumarable: true
        get: -> deferred (doing, uuid, direction) -> 


            process.nextTick ->
                return doing.reject new Error( 

                    'ChangeSet.applyChanges() has no set with uuid: ' + uuid

                ) unless changeSets[uuid]?
                doing.resolve changeSets[uuid][ direction || 'AtoB' ]()


