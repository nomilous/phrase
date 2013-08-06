
#
# phrase recursor
# ===============
# 
# * root phrase recursor is an asynchronously embellished fanfare of revellers 
#   allocating stray tinsel fillament scritinizers to their approximatly crowded 
#   senses of self assembly.
# 
#                                  ie. burly christmas circus flea marshals
#

exports.create = (root) ->

    {context, inject, validate} = root

    recursor = inject.async

        #
        # set the recursor to run all calls in sequence
        #

        parallel: false

        beforeAll: (done) -> 

            context.emitter.emit 'phrase::start'
            done()

        beforeEach: (done, inject) -> 

            #
            # inject
            # ------
            # 
            # This object controls the behaviour of the async injection into
            # the target function `(phrase, control, recursor) ->`
            # 
            # * Inject.defer is a deferral held by the async controller that
            #   wraps the call to the injection target. Ordinarilly it would
            #   be passed into the injection target function as arg1 (done)
            #   
            #   But, instead, calling it out here...
            # 

            defer = inject.defer

            #   ...prevents that behaviour.      And leaves the alternative 
            #                                    resolution mechanism up to
            #                                    the developer
            #
            #  
            #  * Resolving this deferral results in the 'flow of execution'
            #    proceeding into the next phrase.
            # 
            # 
            #  * TEMPORARY !!!  this deferral resolves here
            #               (pending unimplemented mechanism)
            # 
            defer.resolve()


            #
            # * Inject.args are the inbound args that were called into the 
            #   decorated function that was returned by inject.async.
            # 
            # * These args are passed oneward to the injection target but
            #   can be modified as they pass through this beforeEach hook.
            # 

            # 
            # manipulate phrase, control and recursor parameters for injection
            # ----------------------------------------------------------------
            # 
            # * expects last arg as the function to contain nested phrases, 
            #   ensure it is at arg3
            # 

            unless inject.args[2]?

                inject.args[2] = inject.args[1] || inject.args[0] || -> console.log 'NO ARGS'

            done()




        (phrase, control, recursor) -> 

            recursor()



    return recursor
            



