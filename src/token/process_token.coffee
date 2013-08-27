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

            get: -> (uuid) -> 

                collection[uuid] || (

                    collection[uuid] = uuid: uuid

                )



module.exports = ProcessToken