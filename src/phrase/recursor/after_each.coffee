#
# After Each (recursion hook)
#

exports.create = (root) -> 

    {context} = root
    {stack, emitter} = context

    (done) -> 

        stack.pop()

        done()

