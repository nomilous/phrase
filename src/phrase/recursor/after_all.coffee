#
# After All (recursion hook)
#

exports.create = (root) -> 

    {context} = root
    {emitter} = context

    (done) -> 

        done()

