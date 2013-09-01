{readdirSync} = require 'fs'
{join}        = require 'path'
{defer}       = require 'when'
sequence      = require 'when/sequence'


module.exports = boundryHandler = 

    link: (root, opts) -> 

        if opts.directory? then boundryHandler.linkDirectory root, opts


    linkDirectory: (root, opts) -> 

        makeLinks = defer()

        if opts.match? then regex = new RegExp opts.match
        else                regex = new RegExp '\\.coffee$'

        process.nextTick -> 

            {PhraseToken, notice} = root.context

            try filenames = boundryHandler.recurse opts.directory, regex
            catch error
                return makeLinks.reject error

            #
            # phrase::boundry:assemble
            # ------------------------
            #
            # * Parameters of the boundry phrase assembly are transmitted onto the 
            #   message bus to enable remote components to influence the token assembly.
            # 
            #   Specifically this is necessary to enable implementations to determine 
            #   the map from filename to the Token uuid.
            # 
            #   And to allow that determination to be performed asynchronously.
            # 
            #   eg.  
            #            nez realizers contain the realizer uuid in the file
            #

            sequence( for filename in filenames


                do (filename) -> -> notice.event 'phrase::boundry:assemble', 

                    opts:

                        type:        'directory'
                        filename:    filename
                        stackpath:   'TODO'
                        mode:        'refer'
                    


            ).then(
      
                #
                # Boundry Mode
                # ------------
                # 
                # Refers to how the PhraseTree on the other side of the boundry is attached 
                # to this PhraseTree
                # 
                # ### refer 
                # 
                # `boundry token carries reference to the 'other' tree`
                # 
                # Each PhraseTree from across the boundry is built onto a new root on the 
                # core and a reference if placed into this PhraseTree at the vertex where
                # the link was called.
                # 
                # ### nest
                # 
                # `graph assembly continues with recrsion across the phrase boundry`
                # 
                # Each PhraseTree from the other side of the boundry is grafted into this
                # PhraseTree at the vertex where the link was called. 
                #  
                #  

                result = (messages) -> 

                    return makeLinks.resolve() if messages.length == 0 

                    #
                    # Boundry Assembly
                    # ----------------
                    # 
                    # * Messages (Array) contains the specifications for each boundry phrase
                    #   the was linked
                    # 
                    # * Mixed mode is not supported. All boundry phrases must be linked with 
                    #   the mode as 'refer' or 'nest', not a combination of the two.
                    #

                    try
                        mode  = undefined
                        messages.map (m) -> 
                            mode = m.opts.mode unless mode?
                            if mode != m.opts.mode 
                                throw new Error 'Mixed boundry modes not supported.' 

                    catch error
                        return makeLinks.reject error

                    #
                    # ### As Nest
                    # 
                    # * It assembles a phraseFn that calls all the nested phrase
                    #   functions that were returned by the assembly pipeline.
                    # 
                    # * It hands the phrase back to the recursor (before each) via 
                    #   the promise notifier
                    #

                    if mode == 'nest'

                        makeLinks.notify 
  
                            action: 'phrase::nest'
                            done: -> makeLinks.resolve()

                            phrase: (boundry) -> 

                                #
                                # * The recursor then proceeds as normal, recursing into this
                                #   new phrase (As if it was always nested here.).
                                #
                                # 
                                #        "Aaaah... The beauty of the closure, 
                                # 
                                # 

                                messages.map ({phrase}) -> do (phrase) -> 

                                    #
                                    # `boundry` is the async injection recursor,
                                    #  see: Injection Target (ThePhraseRecursor)
                                    #  in /recursor/tree_walker
                                    # 
                                    
                                    boundry phrase.title, phrase.control, phrase.fn



                    # for message in messages
                    #     if message.error? 
                    #         console.log 'ERROR_UNHANDLED_1', error.stack
                    #         continue
                    #     if message.opts.mode == 'nest'
                    #         console.log '\nphraseTitle\t', message.phrase.title
                    #         console.log 'phraseControl\t', message.phrase.opts
                    #         console.log 'phraseFn\t', message.phrase.fn.toString()
                        # root.context.stack.push {}
                        # root.context.stack.pop()

                    makeLinks.resolve()


                #
                # TODO: notice message bus does not yet catch exceptions
                #       in the middleware pipeline, this anticipates that
                #       
                # * proxy message bus exceptions directly
                # 

                error = (reject) -> makeLinks.reject reject
                

            )

        makeLinks.promise


    recurse: (path, regex, matches = []) ->

        for fileOrDirname in readdirSync path

            nextPath = join path, fileOrDirname

            try boundryHandler.recurse nextPath, regex, matches
            catch error
                throw error unless error.code == 'ENOTDIR'
                throw error unless nextPath?
                
                #
                # TODO: will this follow symlinks? (should it?)
                #



                matches.push nextPath if nextPath.match regex

        return matches

