{v1}     = require 'node-uuid'
seq      = 0
{defer}  = require 'when'
pipeline = require 'when/pipeline'

exports.createClass = (root) -> 

    #
    # PhraseGraph (class factory)
    # ===========================
    #
    # * Creates a root context container to house the list of graphs
    # 
    # * Returns the PhraseGraph class definition 
    # 

    {context}      = root
    {notice}       = context
    context.graphs = graphs = 

        latest: null
        list:   {} 
    
    #
    # Graph Assembler (middleware)
    # ----------------------------
    # 
    # * PhraseRecursor walks the phrase tree and transmits all vertex and 
    #   edge data onto the message bus.
    # 
    # * This middleware constructs the graph from that data.
    # 
    # * It assembles into the latest gragh only. All previously created graphs
    #   remain unchanged. 
    #

    notice.use assembler = (msg, next) -> 

        return next() unless graphs.latest?

        switch msg.context.title

            when 'phrase::recurse:start'

                next()

            when 'phrase::edge:create'

                graphs.latest.registerEdge msg, next

            when 'phrase::leaf:create'

                graphs.latest.registerLeaf msg, next

            when 'phrase::recurse:end'

                graphs.latest.createIndexes msg, next


            else next()



    class PhraseGraph

        constructor: (opts = {}) -> 

            localOpts = 

                uuid:      opts.uuid || v1()
                version:   opts.version || ++seq
                vertices:  {}
                edges:     {}
                paths:     {}

                #
                # tree (as special case graph)
                # ----------------------------
                # 
                # These may later move onto the vertex objects themselves
                # instead of being in an index.
                # 
                # * `parent`   - index to parent   ( parent[ UUID ] = parentUUID
                # * `children` - index to children ( children[ parentUUID ] = [uuid1, uuid2, ...] )
                # * `leaves`   - array of leaf uuids
                # 

                parent:    {}
                children:  {}
                leaves:    []

                #
                # TEMPORARY (likely)
                # Specific list of leaves as accumulated by phrase::leaf:create payloads.
                # 

                tree: leaves: {}


            graphs.list[ localOpts.uuid ] = this
            graphs.latest = this


            #
            # immutables
            # 

            for property in ['uuid', 'version', 'vertices', 'edges', 'paths', 'parent', 'children', 'leaves', 'tree']

                do (property) => 

                    Object.defineProperty this, property, 

                        get: -> localOpts[property]
                        enumerable: true

        createIndexes: (msg, next) -> 

            return next() unless @leaves.length > 0

            msg.tokens = {}

            recurse = (vertex, stack = []) => 

                tokenName = vertex.token.name
                text      = vertex.text

                stack.push "/#{  tokenName  }/#{  text  }"

                path = stack.join ''
                @paths[    path ]  = vertex.uuid
                msg.tokens[ path ] = vertex.token

                if @children[ vertex.uuid ]?

                    recurse @vertices[uuid], stack for uuid in @children[ vertex.uuid ]

                stack.pop()
            
            recurse @vertices[ @tree.leaves[ @leaves[0] ].path[0] ]

            next()


        update: -> 

            changes = {}



            return pipeline [

                (       ) => notice.event 'graph::compare:start'
                (       ) => 



                    {} 



                (changes) => notice.event 'graph::compare:end', 

                    changes: changes

            ]
            
                



            # created = []
            # updated = []
            # deleted = []

            # runningGraph = context.graph
            # newGraph     = context.graphs.latest

            # for path of runningGraph.paths

            #     runningUUID   = runningGraph.paths[path]
            #     runningVertex = runningGraph.vertices[runningUUID]
            #     newUUID       = newGraph.paths[path]

            #     unless newUUID?

            #         deleted.push vertex: runningVertex, path: path
            #         continue

            #     #
            #     # in both
            #     #

            #     if runningVertex.leaf

            #         #
            #         # * only leaf vertexes are eligable to be updated directly
            #         # * TODO: changed hooks mark the parent as updated
            #         #

            #         if changes = runningVertex.getChanges newGraph.vertices[newUUID]

            #             console.log CHANGED: changes

            #             # 
            #             # updated.push vertex: runningVertex, path: path
            #             #


            # for path of newGraph.paths 

            #     unless runningGraph.paths[path]?
            #         uuid   = newGraph.paths[path]
            #         vertex = newGraph.vertices[uuid]

            #         created.push vertex: vertex, path: path  
            #         continue

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

            # for create in created

            #     console.log '\nCREATED'
            #     console.log create.path
            #     console.log create.vertex.fn.toString()
                    

            # for update in updated
                
            #     console.log '\nUPDATED'
            #     console.log update.path
            #     console.log update.vertex.fn.toString()

            # for deletes in deleted

            #     console.log '\nDELETED'
            #     console.log deletes.path
            #     console.log deletes.vertex.fn.toString()


            #doing.promise

        registerEdge: (msg, next) -> 

            [vertex1, vertex2] = msg.vertices

            

            #
            # TODO: these will be created and overwritten multiple times
            #       as the phrase recursor transmits the edge definitions
            # 
            #       consider not doing so
            #

            @vertices[vertex1.uuid] = vertex1

            return next() unless vertex2?
            @vertices[vertex2.uuid] = vertex2

            #
            # TODO: non tree edges / weight / direction / etcetera
            #

            @edges[ vertex1.uuid ] ||= []
            @edges[ vertex1.uuid ].push to: vertex2.uuid

            @edges[ vertex2.uuid ] ||= []
            @edges[ vertex2.uuid ].push to: vertex1.uuid



            if msg.type == 'tree'

                @children[ vertex1.uuid ]  ||= []
                @children[ vertex1.uuid ].push vertex2.uuid
                @parent[   vertex2.uuid ]    = vertex1.uuid
                @leaves.push vertex2.uuid if vertex2.leaf


            next()


        #
        # leavesOf(uuid)
        # --------------
        # 
        # Return array of vertexes that are leaves of the specified
        # vertex (opts.uuid). Returns the vertex itself if it is a
        # leaf. 
        # 

        leavesOf: (uuid, found = []) -> 

            return found unless @vertices[uuid]?

            if @vertices[uuid].leaf

                found.push @vertices[uuid]
                return found

            @leavesOf child_uuid, found for child_uuid in @children[uuid]
            return found
            

        registerLeaf: (msg, next) -> 

            @tree.leaves[msg.uuid] = msg
            next()




    #
    # expose the graph assembler as classmethod
    # (hidden, exposed for testing)
    # 

    Object.defineProperty PhraseGraph, 'assembler',

        enumerable: false
        get: -> assembler



    #
    # impart the return
    # -----------------
    # 
    # * it has been too obscurely implied by the fact that
    #   defineProperty returns the object upon which the 
    #   property was defined.
    #

    return PhraseGraph

    #
    # * rotate the 'chaos manifold'
    #

    ;

