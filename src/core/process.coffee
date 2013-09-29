#
# Process
# =======
# 
# * Represents a running processs. 
# * Houses the collection of PhaseTree roots.
#

collection = {}

class Process

    constructor: (core) -> 

        #
        # processToken.root( uuid )
        # -------------------------
        # 
        # * Creates or returns existing root by uuid
        #

        Object.defineProperty this, 'root',
            
            enumerable: true

            get: => (uuid) => 

                    #
                    # return existing root
                    #

                collection[uuid] || (

                    #
                    # or create a new one
                    # -------------------
                    # 

                    collection[uuid] = 

                        #
                        # * each root knows it's uuid
                        #

                        uuid:     uuid

                        #
                        # * each root has access to peer roots
                        #

                        roots:     @root

                        #
                        # * each root is assigned reference to graph assembler
                        #

                        assembler: core.assembler

                        #
                        # * each root has access to validate, 
                        #   inject, util
                        #

                        validate: core.validate
                        inject:   core.inject
                        util:     core.util

                        # #
                        # # create context for each root
                        # # ----------------------------
                        # # 
                        # # * with this processToken preloaded into
                        # #   the walkers stack
                        # #   
                        # #
                        #
                        # context: stack: [@]
                        # 
                        # no - keep process out of the tree
                        # ---------------------------------
                        # 
                        #   UUIDofPhraseTree/path/way/to/leaf
                        #   UUIDofPhraseTree/path/way/to/edge/[  *  ]/UUIDofAnotherTree
                        # 

                )

        core.root = this.root


module.exports = Process
