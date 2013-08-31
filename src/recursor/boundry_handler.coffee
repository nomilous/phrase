{readdirSync} = require 'fs'
{join}        = require 'path'


module.exports = boundryHandler = 

    link: (root, opts) -> 

        if opts.directory? then boundryHandler.linkDirectory opts


    linkDirectory: (root, opts) -> 

        if opts.match? then regex = new RegExp opts.match
        else                regex = new RegExp '\\.coffee$'

        fileNames = boundryHandler.recurse opts.directory, regex

        console.log fileNames


    recurse: (path, regex, matches = []) ->

        for fileOrDirname in readdirSync path

            nextPath = join path, fileOrDirname

            try boundryHandler.recurse nextPath, matches
            catch error
                throw error unless error.code == 'ENOTDIR'
                
                #
                # TODO: will this follow symlinks? (should it?)
                #

                matches.push nextPath if nextPath.match regex

        return matches

        



