{pipeline}       = require 'also'
ChangeSetFactory = require './change_set'
seq              = 0

exports.createClass = (root) -> 

    #
    # PhraseTree (class factory)
    # ===========================
    #
    # * Creates a root context container to house the list of trees
    # 
    # * Returns the PhraseTree class definition 
    # 

    {context, util} = root
    {notice}        = context
    context.trees   = trees = 

        latest: null
        list:   {} 

    #
    # ChangeSet 
    # ---------
    # 
    # * Generated when the TreeWalker is called to re-walk the phrase tree.
    # 
    # * Builds the delta that, when applied, would advance the root.context.tree 
    #   to the new definition in root.context.trees.latest
    # 
    # * It is a class factory so that the class definition can reside inside a 
    #   a closure with access to the root context.
    # 

    ChangeSet = ChangeSetFactory.createClass root

    
    #
    # Tree Assembler (middleware)
    # ---------------------------
    # 
    # * TreeWalker walks the phrase tree and transmits all vertex and edge data 
    #   onto the message bus.
    # 
    # * This middleware constructs the tree from that data.
    # 
    # * It assembles into the latest gragh only. All previously created trees
    #   remain unchanged. 
    #

    notice.use 

        title: 'phrase tree assmebler'
        assembler = (next, capsule) -> 

            return next() unless trees.latest?

            switch capsule.phrase

                when 'phrase::recurse:start'

                    #return next() unless msg.root.uuid == root.uuid
                    next()

                when 'phrase::edge:create'

                    return next() unless capsule.root.uuid == root.uuid
                    trees.latest.registerEdge next, capsule

                when 'phrase::recurse:end'

                    return next() unless capsule.root.uuid == root.uuid
                    trees.latest.createIndexes next, capsule


                else next()



    class PhraseTree

        constructor: (opts = {}) -> 

            localOpts = 

                uuid:       opts.uuid || util.uuid()
                version:    opts.version || ++seq
                rootVertex: undefined
                vertices:   {}
                edges:      {}
                path2uuid:  {}
                uuid2path:  {}

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


            trees.list[ localOpts.uuid ] = this
            trees.latest = this

            order = []
            historyLength = 2
            order.push uuid for uuid of trees.list
            delete trees.list[uuid] for uuid in order[ ..( -1 - historyLength) ]


            #
            # immutables
            # 

            for property in ['uuid', 'version', 'vertices', 'edges', 'path2uuid', 'uuid2path', 'parent', 'children', 'leaves', 'tree']

                do (property) => 

                    Object.defineProperty this, property, 

                        get: -> localOpts[property]
                        enumerable: true

            #
            # invisible
            #

            Object.defineProperty this, 'rootVertex',

                enumerable: false
                get: -> localOpts.rootVertex
                set: (value) -> localOpts.rootVertex = value unless localOpts.rootVertex?


        createIndexes: (next, capsule) -> 

            capsule.tokens = {}

            recurse = (vertex, stack = []) => 

                signature = vertex.token.signature
                title     = vertex.title

                stack.push "/#{  signature  }/#{  title  }"

                path = stack.join ''
                @path2uuid[     path    ] = vertex.uuid
                @uuid2path[ vertex.uuid ] = path
                capsule.tokens[   path  ] = vertex.token

                if @children[ vertex.uuid ]?

                    recurse @vertices[uuid], stack for uuid in @children[ vertex.uuid ]

                stack.pop()
            
            recurse @rootVertex

            next()


        findRoute: (uuidA, uuidB) -> 

            if uuidA?

                throw new Error 'PhraseTree.route(null, uuidB) only supports tree route calculation from root to uuidB'

            recurse = (uuid, uuids = []) => 

                return uuids unless uuid?
                uuids.unshift uuid
                recurse @parent[uuid], uuids

            return recurse uuidB


        update: -> 

            return pipeline [

                #
                # WARNING - The phrase capsule sequence / names will very likely 
                #           change when this update pipeline is expanded to support 
                #           scrolling the running tree (root.context.tree) forward 
                #           and backward through versions. 
                #

                (       ) -> notice.phrase 'tree::compare:start'
                (       ) -> new ChangeSet( context.tree, context.trees.latest ).changes
                (changes) -> notice.phrase 'tree::compare:end', changes: changes

                    #
                    # * This currently goes on to auto apply the new changes
                    # * It can be stopped by setting skipChange, (did for testing)
                    # * But there is currently no way to call to apply changes later
                    # 
                    # TODO: pend change apply per later instruction
                    # 

                (message) -> notice.phrase 'tree::update:start', message
                (message) -> 

                    return skipped: true if message.skipChange
                    ChangeSet.applyChanges message.changes.uuid

                (updated) -> notice.phrase 'tree::update:end', updated

            ]

        registerEdge: (next, capsule) -> 

            [vertex1, vertex2] = capsule.vertices

            
            #
            # TODO: these will be created and overwritten multiple times
            #       as the phrase recursor transmits the edge definitions
            # 
            #       consider not doing so
            #

            @vertices[vertex1.uuid] = vertex1
            @rootVertex = vertex1 unless @rootVertex?
            return next() unless vertex2?
            @vertices[vertex2.uuid] = vertex2

            #
            # TODO: non tree edges / weight / direction / etcetera
            #

            @edges[ vertex1.uuid ] ||= []
            @edges[ vertex1.uuid ].push to: vertex2.uuid

            @edges[ vertex2.uuid ] ||= []
            @edges[ vertex2.uuid ].push to: vertex1.uuid



            @children[ vertex1.uuid ]  ||= []
            @children[ vertex1.uuid ].push vertex2.uuid
            @parent[   vertex2.uuid ]    = vertex1.uuid
            @leaves.push vertex2.uuid  if vertex2.token? and vertex2.token.type == 'leaf'

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

            if @vertices[uuid].token? and @vertices[uuid].token.type == 'leaf'

                found.push @vertices[uuid]
                return found

            @leavesOf child_uuid, found for child_uuid in @children[uuid]
            return found



    #
    # expose the tree assembler as classmethod
    # (hidden, exposed for testing)
    # 

    Object.defineProperty PhraseTree, 'assembler',

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

    return PhraseTree

    #
    # * rotate the 'chaos manifold'
    #

    ;

