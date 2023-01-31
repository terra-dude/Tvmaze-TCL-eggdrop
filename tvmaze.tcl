################################################
# This Script is writed by TeRRaNoVA           #
# Tvmaze today's schedule script               #
# 2023-01-29 v.1.0.3 Beta                      #
#                                              #
# CHANGELOG:---------------------------------- #
# Fixed: Clock/date now gets correct date      #
# Improvement: A.Spam so it checks afther 10   #
# Update: trigger from !tv to !today           # 
# Improvement: Now shows Network if NULL       #
# Improvement: Skip Words                      #
# Imp/Fix: Endline / Removed Space             #
# Update: Pm user or Channel 1 0               #
################################################

#### Package needed
package require http
package require json

#### Trigger
bind pub - !today pub:announce

######## DONT EDIT BELOW UNLESS YOU KNOW WAT YOUR DOING ###########
proc pub:announce {nick host handle chan arg} {
    set priv_msg_enabled 0 #set this to 0 or 1 to announce channel of user
    set now [clock seconds]
    set date [clock format $now -format "%Y-%m-%d"]
    set url "http://api.tvmaze.com/schedule?country=US&date=$date"
    set response [http::geturl $url]
    set data [http::data $response]
    set shows [json::json2dict $data]
    set count 0
    set announcement_count 0
    set skip_words { "Episode" "0 and 2."}
    set output_location [expr {$priv_msg_enabled ? "PRIVMSG $nick" : "PRIVMSG $chan"}]
    if {$priv_msg_enabled == 1} {
       putquick "PRIVMSG $user : Here is the TV schedule for today US:"
    } else {
       putquick "PRIVMSG $chan : Here is the TV schedule for today US:"
    }
    foreach show $shows {
        if {$announcement_count == 10} {
    putquick "$output_location : Hold on there is more......"
            after 5000
            set announcement_count 0
        }
        set show_info [dict get $show "show"]
        set name [dict get $show_info "name"]
        set network_info [dict get $show_info "network"]
        if {$network_info eq "null"} {
            set network "Not Available"
        } else {
            set network [dict get $network_info "name"]
        }
        set season [dict get $show "season"]
        set number [dict get $show "number"]
        set time [dict get $show "airtime"]
        if {[lsearch -exact $skip_words $name] == -1} {
   putquick "$output_location : $name \(S$season/E$number\) airs at $time on $network"
        incr count
            incr announcement_count
        }
    }
}
}
putquick "$output_location : End of TV schedule list for today $date. Checking for new shows tomorrow......
}
putlog "Loaded tvmaze todays schedule script v1.0.3 Beta"
