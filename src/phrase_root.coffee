Notice    = require 'notice'
recursor  = require './phrase/recursor'

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
    # * Stack is directly attached to the `root.context`, this means that
    #   there can only be one root phrase per process.
    # 

    context.stack = []


    #
    # Phrase.create( opts, linkFn )
    # -----------------------------
    # 

    create: validate.args

        $address: 'phrase.create'

        opts: 

            title: {} 
            uuid: {} 

        linkFn: 

            $type: Function
            $description: """

                This callback is called immediately upon initialization of the
                phrase root. It receives an event publisher that can be used 
                to subscribe to phrase events from the local branch.

            """

        (opts, linkFn) -> 

            #
            # notice
            # -------
            #
            # * middlewares can register to receive phrase lifecycle and activity 
            #   events emanating from within the branch rooted at this phrase.
            # 

            context.notice = Notice.create opts.uuid

            #
            # callback with the message pipeline (notice)
            #

            linkFn context.notice


            #
            # return phrase recursor (root)
            # 
         
            return recursor.create root, opts
