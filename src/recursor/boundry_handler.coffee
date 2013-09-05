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

        {notice} = root.context

        notice.event 'phrase::link:directory',

            directory: opts.directory
            match: regex


        sequence( for filename in boundryHandler.recurse opts.directory, regex

            #
            # phrase::boundry:assemble
            # ------------------------
            #
            # * Parameters of the boundry phrase assembly are transmitted onto 
            #   the message bus to enable remote components to influence the 
            #   token assembly.
            # 
            #   Specifically this is necessary to enable implementations to 
            #   determine  the map from filename to the Token uuid.
            # 
            #   And to allow that determination to be performed asynchronously.
            # 
            #   eg.  
            #        nez realizers contain the realizer uuid in the file
            # 
            # * This sequence promises a response from multiple calls to 
            #   phrase::boundry:assemble, one per file found by the recursor
            # 
            # * It is assumed something is attached to the bus that does the 
            #   actual phrase assembly for each.
            # 
            # * All resulting assembled phrases are resolved into the caller
            #   that is waiting on the promise.
            #

            do (filename) -> -> notice.event 'phrase::boundry:assemble', 

                opts:

                    type:        'directory'
                    filename:    filename
                    stackpath:   'TODO'
                    mode:        'refer'

        )

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

