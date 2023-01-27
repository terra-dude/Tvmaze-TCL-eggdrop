################################################
# This Script is writed by TeRRaNoVA           #
# Tvmaze today's schedule script with countrys #
# 2023-01-29 v.2.0.1 Beta                      #
#                                              #
# CHANGELOG:---------------------------------- #
# Fixed: Clock/date now gets correct date      #
# Improvement: A.Spam so it checks afther 10   #
# Update: trigger from !tv to !today           # 
# Improvement: Now shows Network if NULL       #
# Improvement: Skip Words                      #
# country code. Use !today US, GB, NL, CA, AU  #
################################################

#### Package needed
package require http
package require json

#### Trigger
bind pub - !today pub:announce

######## DONT EDIT BELOW UNLESS YOU KNOW WAT YOUR DOING ###########
proc pub:announce {nick host handle chan arg} {
    set now [clock seconds]
    set date [clock format $now -format "%Y-%m-%d"]
         set country "US"
     if {$arg eq "US"} {
         set country "US"
     } elseif {$arg eq "NL"} {
         set country "NL"
     } elseif {$arg eq "GB"} {
         set country "GB"
     } elseif {$arg eq "CA"} {
         set country "CA"
     } elseif {$arg eq "AU"} {
         set country "AU"
#Note that contrary to what you might expect, the ISO country code for the United Kingdom is not UK, but GB. 
     } else {
        putquick "PRIVMSG $chan : Invalid country code. Use !today US, GB, NL, CA, AU"
        return
     }
    set url "http://api.tvmaze.com/schedule?country=$country&date=$date"
    set response [http::geturl $url]
    set data [http::data $response]
    set shows [json::json2dict $data]
    set count 0
    set announcement_count 0
    set skip_words { "Episode" "0 and 2."}
    putquick "PRIVMSG $chan :  Here is the TV schedule for today:"
    foreach show $shows {
        if {$announcement_count == 10} {
    putquick "PRIVMSG $chan :  Hold on there is more......"
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
   putquick "PRIVMSG $chan :  $name \(S$season E$number\) airs at $time on $network"
        incr count
            incr announcement_count
        }
    }
}

    }
}
putlog "Loaded tvmaze todays schedule check countrys script v2.0.1 Beta"
