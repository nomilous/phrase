{v1} = require 'node-uuid'

#
# (Phrase) Hook
#

exports.PhraseHook = class PhraseHook

    constructor: (root, @type, opts) -> 

        #GREP3

        #
        # TODO: get control timeout from parent node
        #

        @fn = switch type

            when 'beforeEach', 'afterEach' then opts.each
            when 'beforeAll',  'afterAll'  then opts.all

        @uuid      = v1()
        @timeout   = opts.timeout || root.timeout || 2000


# 
# create before() and after() hook registrars on global scope
# -----------------------------------------------------------
#  

beforeHooks = each: [], all: []
afterHooks  = each: [], all: []

exports.bind = (root) -> 

    #
    # global appears to allow property redefines, huh?
    #
    
    Object.defineProperty global, 'before',
        enumerable: false
        get: -> (opts = {}) -> 

            beforeHooks.each.push new PhraseHook root, 'beforeEach', opts if typeof opts.each == 'function'
            beforeHooks.all.push  new PhraseHook root, 'beforeAll', opts  if typeof opts.all  == 'function'


    Object.defineProperty global, 'after',
        enumerable: false
        get: -> (opts = {}) -> 

            afterHooks.each.push new PhraseHook root, 'afterEach', opts if typeof opts.each == 'function'
            afterHooks.all.push  new PhraseHook root, 'afterAll', opts  if typeof opts.all  == 'function'

        
    beforeAll:   beforeHooks.all
    beforeEach:  beforeHooks.each
    afterEach:   afterHooks.each
    afterAll:    afterHooks.all

