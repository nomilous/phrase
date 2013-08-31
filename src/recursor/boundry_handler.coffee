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
            # Assemble each linked PhraseToken
            # --------------------------------
            #
            # * Details of each found file are transmitted into the message bus to enable 
            #   remote components to influence the token assembly.
            # 
            #   Specifically this is necessary to enable implementations to determine 
            #   the map from filename to the Token uuid (which may require callback)
            # 
            #   And to allow that determination to be performed asynchronously.
            # 
            #   eg.  
            #            nez realizers contain the realizer uuid in the file
            #            
            #          

            sequence( for filename in filenames


                do (filename) -> -> notice.event 'phrase::boundry:assemble', 

                    #
                    # * sends the type of this remote token assembly line
                    #

                    type:        'directory'
                    filename:    filename

                    #
                    # TODO: include the current stack path
                    #

                    stackpath:   'TODO'

                    token: 

                        #
                        # TODO: consider only allowing set: (value) -> once
                        #

                        uuid: undefined
                    


            ).then(

                #
                # * All remote ammendments have been made
                #

                (messages) -> for message in messages

                    console.log message.token.uuid

                    root.context.stack.push {}



                        



                    root.context.stack.pop()

                    makeLinks.resolve()

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

