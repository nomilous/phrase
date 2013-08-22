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
                        @changes.updated[parentPath].hooks = changes.hooks


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

            doing = defer()

            for path of @changes.updated

                target = @graphA.vertices[ @graphA.paths[path] ]
                target.update @changes.updated[path]


            

            process.nextTick doing.resolve
            doing.promise


    Object.defineProperty PhraseGraphChangeSet, 'applyChanges', 
        enumarable: true
        get: -> (uuid, direction) -> 

            changeSet = changeSets[uuid]
            changeSet[ direction || 'AtoB' ]()

