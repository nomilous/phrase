#
# Process Token
# =============
# 
# * Represents a running processs. 
# * Houses the collection of PhaseTree roots.
#

collection = {}

class ProcessToken

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

                        root:     @root

                        #
                        # * each root has access to validate, 
                        #   inject, util
                        #

                        validate: core.validate
                        inject:   core.inject
                        util:     core.util

                )



module.exports = ProcessToken
