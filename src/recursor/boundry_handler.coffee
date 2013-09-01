{readdirSync} = require 'fs'
{join}        = require 'path'
{defer}       = require 'when'
sequence      = require 'when/sequence'


module.exports = boundryHandler = 

    link: (root, opts) -> 

        if opts.directory? then boundryHandler.linkDirectory root, opts


    linkDirectory: (root, opts) -> 

        if opts.match? then regex = new RegExp opts.match
        else                regex = new RegExp '\\.coffee$'

        {PhraseToken, notice} = root.context

        sequence( for filename in boundryHandler.recurse opts.directory, regex

            do (filename) -> -> notice.event 'phrase::boundry:assemble', 

                opts:

                    type:        'directory'
                    filename:    filename
                    stackpath:   'TODO'
                    mode:        'refer'

        )

        


        # makeLinks = defer()

        # if opts.match? then regex = new RegExp opts.match
        # else                regex = new RegExp '\\.coffee$'



        # process.nextTick -> 

        #     {PhraseToken, notice} = root.context

        #     try filenames = boundryHandler.recurse opts.directory, regex
        #     catch error
        #         return makeLinks.reject error

        #     #
        #     # phrase::boundry:assemble
        #     # ------------------------
        #     #
        #     # * Parameters of the boundry phrase assembly are transmitted onto the 
        #     #   message bus to enable remote components to influence the token assembly.
        #     # 
        #     #   Specifically this is necessary to enable implementations to determine 
        #     #   the map from filename to the Token uuid.
        #     # 
        #     #   And to allow that determination to be performed asynchronously.
        #     # 
        #     #   eg.  
        #     #            nez realizers contain the realizer uuid in the file
        #     #

        #     sequence( for filename in filenames

        #         do (filename) -> -> notice.event 'phrase::boundry:assemble', 

        #             opts:

        #                 type:        'directory'
        #                 filename:    filename
        #                 stackpath:   'TODO'
        #                 mode:        'refer'
                    


        #     ).then(
      
        #         #
        #         # Boundry Mode
        #         # ------------
        #         # 
        #         # Refers to how the PhraseTree on the other side of the boundry is attached 
        #         # to this PhraseTree
        #         # 
        #         # ### refer 
        #         # 
        #         # `boundry token carries reference to the 'other' tree`
        #         # 
        #         # Each PhraseTree from across the boundry is built onto a new root on the 
        #         # core and a reference if placed into this PhraseTree at the vertex where
        #         # the link was called.
        #         # 
        #         # ### nest
        #         # 
        #         # `graph assembly continues with recrsion across the phrase boundry`
        #         # 
        #         # Each PhraseTree from the other side of the boundry is grafted into this
        #         # PhraseTree at the vertex where the link was called. 
        #         #  
        #         #  

        #         result = (messages) -> makeLinks.resolve messages

        #             # return makeLinks.resolve() if messages.length == 0 

        #             # #
        #             # # Boundry Assembly
        #             # # ----------------
        #             # # 
        #             # # * Messages (Array) contains the specifications for each boundry phrase
        #             # #   the was linked
        #             # # 
        #             # # * Mixed mode is not supported. All boundry phrases must be linked with 
        #             # #   the mode as 'refer' or 'nest', not a combination of the two.
        #             # #

        #             # try
        #             #     mode  = undefined
        #             #     messages.map (m) -> 
        #             #         mode = m.opts.mode unless mode?
        #             #         if mode != m.opts.mode 
        #             #             throw new Error 'Mixed boundry modes not supported.' 

        #             # catch error
        #             #     return makeLinks.reject error

        #             # makeLinks.resolve messages


        #         #
        #         # TODO: notice message bus does not yet catch exceptions
        #         #       in the middleware pipeline, this anticipates that
        #         #       
        #         # * proxy message bus exceptions directly
        #         # 

        #         error = (reject) -> makeLinks.reject reject
                

        #     )

        # makeLinks.promise


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

