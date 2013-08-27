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
                    # 

                    collection[uuid] = 

                        uuid: uuid
                        root: @root

                )



module.exports = ProcessToken
