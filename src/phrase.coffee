require( 'also' ) exports, {}, (root) -> 

    #
    # ### stack 
    # 
    # * The stack of elements (sub phrases) that is pushed and popped
    #   as the 'flow of execution' traverses the phrase tree.
    # 

    root.context.stack = []

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

    create: (opts = {}) -> 
        
        #
        # validate opts
        #

        missing = ['title', 'uuid'].filter( (e) -> not opts[e]? ).map( (e) -> "opts.#{e}" ).join ', '
        throw new Error "Phrase.create(opts) expects #{ missing }" if missing.length > 0

