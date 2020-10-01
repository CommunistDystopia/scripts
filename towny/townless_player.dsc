# +----------------------
# |
# | TOWNLESS PLAYER
# |
# +----------------------
#
# @author devnodachi
# @date 2020/09/19
# @denizen-build REL-1714
# @dependency TownyAdvanced/Towny
#

Townless_Player_Script:
    type: world
    debug: false
    events:
        on player dies in:region_puertospawn:
            - if <player.has_town> && <player.town.name> == puerto_bayamos:
                - flag <player> puerto_bayamos_border:true
        after player respawns:
            - if <location[puerto_bayamos_border_spawn]||null> == null || <location[townless_spawn]||null> == null:
                - narrate "<red> ERROR: <white> The townless or puerto bayamos border spawn point doesn't exist. Open a ticket in Discord for help."
                - stop
            - if !<player.in_group[prisoner]>:
                - if <player.has_flag[puerto_bayamos_border]>:
                    - flag <player> puerto_bayamos_border:!
                    - teleport <player> <location[puerto_bayamos_border_spawn]>
                - if !<player.has_town>:
                    - if !<player.in_group[outlaw]>:
                        - group add outlaw
                    - teleport <player> <location[townless_spawn]>
                - else:
                    - if <player.in_group[outlaw]>:
                        - group remove outlaw