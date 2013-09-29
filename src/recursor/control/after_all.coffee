#
# After All (recursion hook)
#

exports.create = (root, parentControl) -> 

    {context}        = root
    {stack, notice}  = context

    (done, injectionControl) -> 

        parent = stack[ stack.length - 1 ]

        if parent? 

            done()

            process.nextTick -> 

                #
                # This is the injection deferral that suspended
                # the completion of the 'first walk''s traversal
                # of the parent phrase.
                # 
                # Calling it now releases that suspension and 
                # allows the 'first walk' to proceed into the
                # next sibling of the parent.
                #
                # It is called on the nextTick to ensure that 
                # any functionality still pending at this depth
                # ( that follows done() ) occurrs before the 
                # parent resolution.
                # 
                # 
                #  #GREP1
                # 

                parent.deferral.resolve()

        else 

            #
            # there is no parent, recursor has arrived back
            # to the phrase root
            # 

            startedAt = context.walking.startedAt
            context.walking.duration = Date.now() - startedAt

            notice.event( 'phrase::recurse:end' 

                walk: context.walking
                root: uuid: root.uuid

            ).then -> 

                unless context.walks?

                    context.walks     = []
                    context.firstWalk = context.walking
                    firstwalk         = true

                context.walks.unshift context.walking
                if context.walks.length > 5 then context.walks.pop()

                unless firstwalk

                    #
                    # TODO: - mechanism to pend the tree update until instructed to switch
                    #       - mechanism to switch back
                    #

                    return context.tree.update().then -> 

                        delete context.walking
                        process.nextTick done

                delete context.walking
                process.nextTick done

                