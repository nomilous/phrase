#
# Recursor Control
# ================
#

BeforeAll      = require './control/before_all'  
BeforeEach     = require './control/before_each'
AfterEach      = require './control/after_each'
AfterAll       = require './control/after_all'

exports.bindControl = (root, control) -> 

    {util} = root

    console.moo = 1

    control.phraseType = (fn) -> 

        arg1 = try util.argsOf( fn )[0]

        if arg1? 

            if control.leaf.indexOf( arg1 ) >= 0

                return 'leaf'

        return 'vertex'
        

    return {

        beforeAll:   BeforeAll.create root, control
        beforeEach:  BeforeEach.create root, control
        afterEach:   AfterEach.create root, control
        afterAll:    AfterAll.create root, control

    }