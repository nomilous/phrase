{v1} = require 'node-uuid'

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

            when 'phrase::edge:create'

                graphs.latest.registerEdge msg, next

            when 'phrase::leaf:create'

                graphs.latest.registerLeaf msg, next


            else next()





    class PhraseGraph

        constructor: (opts = {}) -> 

            localOpts = 

                uuid:      opts.uuid || v1()
                vertices:  {}
                edges:     {}

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

            for property in ['uuid', 'vertices', 'edges', 'parent', 'children', 'leaves', 'tree']

                do (property) => 

                    Object.defineProperty this, property, 

                        get: -> localOpts[property]
                        enumerable: true



        registerEdge: (msg, next) -> 

            [vertex1, vertex2] = msg.vertices

            #
            # TODO: these will be created and overwritten multiple times
            #       as the phrase recursor transmits the edge definitions
            # 
            #       consider not doing so
            #

            @vertices[vertex1.uuid] = vertex1
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













exports.create = (root) -> 

    {context} = root
    {notice}  = context



    vertices = {}
    edges    = {}

    #
    # special case for trees
    # ----------------------
    # 
    # ### parent
    # 
    # Index maps vertex to parent vertex 
    # ie. parent[ UUID ] = parentUUID
    # 
    # ### children
    # 
    # Index maps vertex to array of children, (in created order)
    # children[ UUID ] = [child1UUID, child2UUID, ...]
    # 
    # ### leaves
    # 
    # Array of vertexes that are leaves on the tree
    # 
    # ### tree
    # 
    # tree.leaves - Leaf list with path from root
    # 

    parent   = {} 
    children = {}
    leaves   = []
    tree     = leaves: {}

    api = 

        #
        # leavesOf(uuid)
        # --------------
        # 
        # Return array of vertexes that are leaves of the specified
        # vertex (opts.uuid). Returns the vertex itself if it is a
        # leaf. 
        # 

        leavesOf: (uuid, found = []) -> 

            return found unless vertices[uuid]?

            if vertices[uuid].leaf

                found.push vertices[uuid]
                return found

            api.leavesOf child_uuid, found for child_uuid in children[uuid]
            return found
            


    Object.defineProperty api, 'vertices', 

        enumerable: true
        get: -> vertices

    Object.defineProperty api, 'edges', 

        enumerable: true
        get: -> edges


    #
    # assembler(msg, next)
    # --------------------
    # 
    # Middleware assembles the phrase graph
    # messages generated by the 'first walk'
    #

    Object.defineProperty api, 'assembler', 

        enumerable: false
        get: -> (msg, next) -> 

            # console.log msg.content

            if msg.context.title == 'phrase::edge:create'

                api.registerEdge msg, next
            
            else if msg.context.title == 'phrase::leaf:create'

                api.registerLeaf msg, next

            else next()


    notice.use api.assembler


    Object.defineProperty api, 'registerEdge', 

        enumerable: false
        get: -> (msg, next) -> 

            [vertex1, vertex2] = msg.vertices

            #
            # the edge emitter includes [root, undefined]
            # ignore it
            #

            return next() unless vertex2

            #
            # TODO: overrwrite / change detection / related event generation
            #

            vertices[vertex1.uuid] = vertex1
            vertices[vertex2.uuid] = vertex2

            #
            # TODO: non tree edges / weight / direction / etcetera
            #

            edges[ vertex1.uuid ] ||= []
            edges[ vertex1.uuid ].push connect: vertex2.uuid

            edges[ vertex2.uuid ] ||= []
            edges[ vertex2.uuid ].push connect: vertex1.uuid

            if msg.type == 'tree'

                parent[ vertex2.uuid ] = vertex1.uuid
                children[ vertex1.uuid ] ||= []
                children[ vertex1.uuid ].push vertex2.uuid
                leaves.push vertex2.uuid if vertex2.leaf

            next()


    Object.defineProperty api, 'registerLeaf', 

        enumerable: false
        get: -> (msg, next) -> 

            tree.leaves[msg.uuid] = msg
            next()

    Object.defineProperty api, 'parent', 

        enumerable: true
        get: -> parent

    Object.defineProperty api, 'children', 

        enumerable: true
        get: -> children

    Object.defineProperty api, 'leaves', 

        enumerable: true
        get: -> leaves

    Object.defineProperty api, 'tree', 

        enumerable: true
        get: -> tree

    





