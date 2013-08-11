{v1} = require 'node-uuid'

exports.PhraseHook = class PhraseHook

    constructor: (root, @fn) -> 

        @createdAt = Date.now()
        @runCount  = 0
        @uuid      = v1()

    run: -> 

        @runCount++
        @lastRunAt = Date.now()
        # console.log "run hook:", @fn.toString()

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

            beforeHooks.each.push new PhraseHook root, opts.each if typeof opts.each == 'function'
            beforeHooks.all.push  new PhraseHook root, opts.all  if typeof opts.all  == 'function'


    Object.defineProperty global, 'after',
        enumerable: false
        get: -> (opts = {}) -> 

            afterHooks.each.push new PhraseHook root, opts.each if typeof opts.each == 'function'
            afterHooks.all.push  new PhraseHook root, opts.all  if typeof opts.all  == 'function'

        
    beforeAll:   beforeHooks.all
    beforeEach:  beforeHooks.each
    afterEach:   afterHooks.each
    afterAll:    afterHooks.all

