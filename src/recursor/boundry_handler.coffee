{readdirSync} = require 'fs'
{join}        = require 'path'
{defer}       = require 'when' 


module.exports = boundryHandler = 

    link: (root, opts) -> 

        console.log opts

        if opts.directory? then boundryHandler.linkDirectory root, opts


    linkDirectory: (root, opts) -> 

        makeLinks = defer()

        if opts.match? then regex = new RegExp opts.match
        else                regex = new RegExp '\\.coffee$'

        process.nextTick -> 

            try for filename in boundryHandler.recurse opts.directory, regex

                root.context.stack.push {}



                console.log filename[60..]



                root.context.stack.pop()

            catch error

                makeLinks.reject error

            makeLinks.resolve()

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

