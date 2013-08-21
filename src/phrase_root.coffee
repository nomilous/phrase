Notice         = require 'notice'
PhraseToken    = require './phrase_token'
PhraseNode     = require './phrase_node'
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
                        # has the default 2 seconds to call done() or it will timeout
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
                    # create PhraseGraph (class definition)
                    # -------------------------------------
                    # 
                    # * Houses the set of vertexes and edges that define the phrase tree
                    # * Assembled (via message bus) by the 'first walk' of the phrase recursor
                    # * This is the PhraseGraph definition (class)
                    # * Instance is managed in PhraseRecursor
                    # 

                    context.PhraseGraph = PhraseGraph.createClass root


                    #
                    # create PhraseNode (class definition)
                    # ------------------------------------
                    # 
                    # * A PhraseNode instance is created for each vertex (Node) 
                    #   in the phrase tree. 
                    # * They are stored in a collection in the PhraseGraph  
                    #

                    context.PhraseNode = PhraseNode.createClass root
                  

                    #
                    # create PhraseJob (class definition)
                    # -----------------------------------
                    #
                    # * PhraseJob instances are created with each call to token.run
                    # * The class definition is instanciated here to enable root access
                    # 
                    # 

                    context.PhraseJob = PhraseJob.createClass root


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

                    PhraseRecursor.walk root, opts, phraseRootString, phraseRootFn


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
                # 

                PhraseRecursor.walk root, opts, phraseRootString, phraseRootFn





