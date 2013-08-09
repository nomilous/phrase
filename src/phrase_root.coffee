Notice         = require 'notice'
PhraseToken    = require './phrase_token'
PhraseRecursor = require './phrase/phrase_recursor'

require( 'also' ) exports, {}, (root) -> 

    #
    # phrase
    # ======
    # 
    # API Entrypoint
    #

    {context, validate} = root

  

    #
    # rootToken
    # ---------
    #
    # * A control / attachmant point for initiate actions into 
    #   this phrase tree.
    # 

    context.rootToken = PhraseToken.create root

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
    # Phrase.createRoot( opts, linkFn )
    # -----------------------------
    # 

    createRoot: validate.args

        $address: 'phrase.createRoot'

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

            linkFn context.rootToken, context.notice


            #
            # return phrase recursor (root)
            # 
         
            return PhraseRecursor.create root, opts
