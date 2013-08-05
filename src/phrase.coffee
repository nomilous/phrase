require( 'also' ) exports, {}, (root) -> 

    #
    # phrase root
    # ===========
    # 
    #  ??? TODO
    #


    {context, validate} = root


    #
    # stack
    # -----
    # 
    # * The stack of elements (sub phrases) that is pushed and popped
    #   as the 'flow of execution' traverses the phrase tree.
    #

    context.stack = []

    # 
    # * Stack is directly attached to the `root.context`, this means that
    #   there can only be one root phrase per process.
    # 

    #
    # Phrase.create( opts )
    # ---------------------
    # 
    # Create the `root phrase` with assigned title and universally unique id
    # 

    create: validate.args

        $address: 'phrase.create'

        opts: 
            title: {} 
            uuid: {} 

        eventFn: {}

        (opts, eventFn) -> 

            eventFn()
        
