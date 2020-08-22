# +----------------------
# |
# | W O R K E R
# |
# +----------------------
#
# @author devnodachi
# @date 2020/08/15
# @denizen-build REL-1714
#

Worker_Script:
    type: world
    debug: false
    events:
        on system time minutely:
            - foreach <server.online_players> as:server_player:
                - ~yaml load:data/college/config.yml id:college_data
                - define hasJob <yaml[college_data].read[job_groups].shared_contents[<[server_player].groups>].is_empty||null>
                - if <[hasJob]> == null:
                    - stop
                - if !<[hasJob]>:
                    - flag <[server_player]> worker_timer:+:1
                    - if <[server_player].flag[worker_timer]> >= 20:
                        - flag <[server_player]> worker_timer:0
                        - give 1_Bill quantity:5 to:<[server_player].inventory>
                        - narrate "<white> You got paid <green>[5$] <white>for working <yellow>20 minutes" targets:<[server_player]>
        on player quits:
            - if <player.has_flag[worker_timer]>:
                - flag <player> worker_timer:!