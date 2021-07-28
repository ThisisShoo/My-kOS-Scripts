// Inventory check
list engines in englist.
set solids to list().
set liquids to list().
for eng in englist { // eng is the universal term for all kinds of engines
    if eng:throttlelock {
        solids:add(eng).
    } else {
        liquids:add(eng).
    }
}

set active to list().
list engines in englist.
for eng in englist{
    if eng:ignition{
        active:add(eng). // Makes a list of active engines (aka the ones in stage)
    }
}

// Status check
set flying to false.
set orbit to false.

// Countdown start
clearScreen.
hudtext("Initiating prelaunch...", 4, 4, 45, yellow, false).
set countdown to 3.
until countdown = 0 {
    set message to "T- "+ countdown.
    hudtext(message, 1, 4, 45, yellow, false).
    set countdown to countdown - 1.
    wait 1.5. 
}

// Ignition sequence
hudtext("Ignition sequence start", 1, 4, 45, yellow, false).
set ship:control:mainthrottle to 1.
sas on.

when stage:ready then {
    stage.
}
wait 3.5.
if ship:verticalspeed < 5{
    stage.
}

launchmessage().

until stage:number < 2{
    if ALT:radar > 2000{
        autostage().
    }
}

// Functions

global function scrub {
    set ship:control:mainthrottle to 0.
    abort.
    sas off.
    hudtext("Mission scrubbed", 1, 4, 45, red, false).
    shutdown.
}
global function launchmessage{
    when ship:verticalspeed > 0.2 then{
        print "Lift off!".
        set flying to true.
    }
}
function autostage{
    set active to list().
    set active_solids to list().
    set active_liquids to list().

    local needstage is false.
    list engines in englist.
    for eng in englist{
        if eng:ignition{
            active:add(eng). // Makes a list of active engines (aka the ones in stage)
        }
    }

    for act in active{ // separates the active solids from liquids
        if act:throttlelock{
            active_solids:add(act).
        }else{
            active_liquids:add(act).
        }
    }

    for active_srb in active_solids{ // Trigger the staging
        if active_srb:flameout{
            set needstage to true.
        }
    }
    for active_liq in active_liquids{
        if active_liq:flameout{
            set needstage to true.
        }
    }

    if needstage {
        if stage:ready = true{
            stage.
            set needstage to false.
            print "staged".
            wait 1.
            for act in active{ // separates the active solids from liquids
                if act:throttlelock{
                    active_solids:add(act).
                }else{
                    active_liquids:add(act).
                }
            }

            for active_srb in active_solids{ // Trigger the staging
                if active_srb:flameout{
                    set needstage to true.
                }
            }
            for active_liq in active_liquids{
                if active_liq:flameout{
                    set needstage to true.
                }
            }
        }
    }

    until needstage = false {
        local m0 is ship:mass.
        wait 0.1. 
        local m1 is ship:mass.
        global massflow is (m0 - m1)/0.1.
    }
}
