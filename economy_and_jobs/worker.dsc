# +----------------------
# |
# | W O R K E R
# |
# +----------------------
#
# @author devnodachi
# @date 2020/09/12
# @denizen-build REL-1714
#

Worker_Script:
    type: world
    debug: false
    events:
        on system time minutely:
                - foreach <server.online_players> as:server_player:
                    - if !<[server_player].in_group[outlaw]>:
                        - flag <[server_player]> worker_timer:+:1
                        - if <[server_player].flag[worker_timer]> >= 20:
                            - flag <[server_player]> worker_timer:0
                            - give 1_Bill quantity:5 to:<[server_player].inventory>
                            - narrate "<white> You recieved your <green>$5 <white>allowance for spending 20 minutes on the server." targets:<[server_player]>
        on player quits:
            - if <player.has_flag[worker_timer]>:
                - flag <player> worker_timer:!