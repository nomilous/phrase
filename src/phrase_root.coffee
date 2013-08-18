Notice         = require 'notice'
PhraseToken    = require './phrase_token'
PhraseGraph    = require './graph/phrase_graph'
PhraseRecursor = require './phrase/phrase_recursor'
PhraseJob      = require './phrase/phrase_job'

require( 'also' ) exports, {}, (root) -> 

    #
    # phrase
    # ======
    # 
    # API Entrypoint
    #

    {context, validate} = root


    #
    # stack
    # -----
    # 
    # * The stack of elements (sub phrases) that is pushed and popped
    #   as the 'first walk' traverses the phrase tree.
    # 

    context.stack = []



    #
    # Phrase.createRoot( opts, linkFn )
    # ---------------------------------
    # 

    createRoot: validate.args

        $address: 'phrase.createRoot'

        opts: 

            title: {} 
            uuid: {} 
            leaf: 
                $default: ['end', 'done']
                $description: """

                    This specifies an array of possible phraseFn arg1 signature names 
                    that are used to determine if the phrase function is a leaf.

                        eg. 

                        phraseRegistrar 'phrase text', (end) -> 

                            # 
                            # this is a leaf function
                            # 

                """
            timeout: 
                $default: 2000
                $description: """

                    This specifies how long to allow asynchronous hooks or leaves
                    to run before it is assumed they will not complete.

                    eg. 

                    before each: (done) -> 

                        #
                        # has 2 seconds to call done() or it will timeout
                        #

                """

                

        linkFn: 

            $type: Function
            $description: """

                This callback is called immediately upon initialization of the
                phrase root. It receives the phrase tree access token and a
                middleware registrar that enables tapping into the chatter 
                traversing the phrase tree's internal message bus.

            """

        (opts, linkFn) -> 

            #
            # * create the message bus
            # 

            context.notice = Notice.create opts.uuid


            #
            # * used in hooks (TEMPORARY)
            #

            root.timeout = opts.timeout


            #
            # return phrase root registrar
            # 
         
            return (phraseRootString, phraseRootFn) -> 

                if context.walking?

                    throw new Error 'Phrase root registrar cannot perform concurrent walks'


                unless context.token?


                    #
                    # this is the first walk
                    # 

                    # 
                    #
                    # create graph
                    # ------------
                    # 
                    # * Houses the set of vertexes and edges that define the phrase tree
                    # * Assembled by the 'first walk' of the phrase recursor
                    # 

                    context.graph = PhraseGraph.create root
                    context.notice.use context.graph.assembler
                  

                    #
                    # create PhraseJob (class definition)
                    # -----------------------------------
                    #
                    # * PhraseJob instances are created with each call to token.run
                    # * The class definition is instanciated here to enable root access
                    # 
                    # 

                    context.PhraseJob = PhraseJob.create root


                    #
                    # create PhraseToken (root instance)
                    # ----------------------------------
                    # 
                    # * This token is the primary interface into the phrase tree
                    # 

                    context.token = PhraseToken.create root


                    #
                    # * Start 'first walk' to load the phrase tree
                    #

                    PhraseRecursor.create root, opts, phraseRootString, phraseRootFn


                    # 
                    # * Call the linker to assign external access to the 
                    #   phrase tree (via the token) and the message bus
                    #   

                    linkFn context.token, context.notice


                    #
                    # impart the return
                    # -----------------
                    # 
                    # * activate 'uncertainty shields'
                    # * activate 'duality field'
                    # * activate 'supersymmetry sensor array'
                    # * activate 'entanglment phase array'
                    # * activate 'causality phase array'
                    #

                    return 

                    #
                    # the quantum flux has stabalized
                    # -------------------------------
                    #
                    # * rotate the 'chaos manifold'
                    # 

                    ;


                #
                # not the first walk
                # ------------------
                # 

                PhraseRecursor.create root, opts, phraseRootString, phraseRootFn





