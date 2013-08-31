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
            #  

            sequence( for filename in filenames


                do (filename) -> -> notice.event 'phrase::boundry:assemble', 

                    params:

                        type:        'directory'
                        filename:    filename
                        stackpath:   'TODO'
                        mode:        'refer'
                    


            ).then(

                #
                # * All remote ammendments have been made
                #

                (messages) -> 

                    for message in messages

                        if message.error? 

                            console.log 'ERROR_UNHANDLED_1', error.stack
                            continue


                        console.log '\nphraseText\t', message.result.title
                        console.log 'phraseControl\t', message.result.opts
                        console.log 'phraseFn\t', message.result.fn.toString()

                        console.log mode:  message.params.mode
                        root.context.stack.push {}


                        

                        root.context.stack.pop()

                    makeLinks.resolve()


                #
                # TODO: notice message bus does not yet catch exceptions
                #       in the middleware pipeline, this anticipates that
                #       
                # * proxy message bus exceptions directly
                # 

                # (reject) -> makeLinks.reject reject
                makeLinks.reject
                

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

