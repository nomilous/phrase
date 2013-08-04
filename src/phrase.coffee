#
# phrase
# ======
#
# context
# -------
# 
# Explicit object to contain the lifecycle context of the phrase.
# 

context = 

    #
    # ### stack 
    # 
    # * The stack of elements (sub phrases) that is pushed and popped
    #   as the 'flow of execution' traverses the phrase tree.
    #

    stack: []

#
# Phrase.create( opts )
# ---------------------
# 
# Creates a phrase context.
# 
# ### opts 
# 
# * `title` (required) 
# 

requiredOpts = ['title', 'uuid']


exports.create = (opts = {}) -> 
    
    #
    # validate opts
    #

    missing = requiredOpts.filter( (e) -> not opts[e]? ).map( (e) -> "opts.#{e}" ).join ', '
    throw new Error "Phrase.create(opts) expects #{ missing }" if missing.length > 0


    
    
