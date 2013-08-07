#
# bind all recusrion hooks to root context
#

BeforeAll      = require './before_all'  
BeforeEach     = require './before_each'
AfterEach      = require './after_each'
AfterAll       = require './after_all'

exports.create = (root) -> 

    beforeAll:   BeforeAll.create root
    beforeEach:  BeforeEach.create root
    afterEach:   AfterEach.create root
    afterAll:    AfterAll.create root
