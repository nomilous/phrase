#
# Before All (recursion hook)
#

exports.create = (root, parentControl) -> 

    {context}       = root
    {notice, hooks} = context
    context.stack ||= []

    #
    # send notification of 'first walk' starting if 
    # this is that
    # 

    (done, injectionControl) ->

        #
        # injectionControl
        # ----------------
        # 
        # InjectionControl is a common object passed as arg2 to each 
        # of the recursion control hooks.
        # 
        # * This first hook pops any phrase hooks that may have been 
        #   registered ahead of this phrase being called. A reference
        #   is placed into each child be the beforeEach recursor hook.
        # 

        run = -> 

            beforeAll  = hooks.beforeAll.pop()
            beforeEach = hooks.beforeEach.pop()
            afterEach  = hooks.afterEach.pop()
            afterAll   = hooks.afterAll.pop()

            injectionControl.beforeEach = beforeEach
            injectionControl.beforeAll  = beforeAll
            injectionControl.afterEach  = afterEach
            injectionControl.afterAll   = afterAll

            done()

        return run() if context.walking?
        
        notice.event( 'phrase::recurse:start' ).then -> 

            context.walking = startedAt: Date.now()
            context.walking.first = not context.walks? 
            run()
