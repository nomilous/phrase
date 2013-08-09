#
# phrase token
# ============
# 
# A container / controller (resident in each phrase node) 
# to manage it's edges.  
# 

exports.create = (root) -> 

    {context} = root
    {graph}   = context

    #
    # TEMPORARY: direct access to graph
    #

    graph: graph

