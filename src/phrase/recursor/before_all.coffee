#
# Before All (recursion hook)
#

exports.create = (root) -> 

    {context} = root
    {emitter} = context

    (done) -> 

        emitter.emit 'phrase::start'
        done()

