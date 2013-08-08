#
# After All (recursion hook)
#

exports.create = (root) -> 

    {context} = root
    {notice}  = context

    (done) -> 

        done()

