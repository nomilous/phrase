#
# phrase graph
# ============
#
# Container to house all vertexes and edges of the phrase tree
# that is assembled by the phrase recursor's 'first walk'
# 

exports.create = (root) -> 

    #
    # assembler()
    # -----------
    # 
    # Middleware assembles the phrase graph
    #

    assembler: (msg, next) -> 

        next()

