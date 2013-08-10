#
# phrase token
# ============
# 
# A container / controller (resident in each phrase node) 
# to manage it's edges.  
# 

exports.create = (root) -> 

    {context, inject} = root
    {graph}   = context

    #
    # TEMPORARY: direct access to graph
    #

    graph: graph

    run: (opts) -> 

        running = inject.async 

            beforeEach: (done, injection) -> 

                injection.defer.resolve(  ['RESULT'] )
                done()

            ->

        return running opts

