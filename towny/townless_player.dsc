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

# note puerto_bayamos_border_spawn
# flag server puerto_bayamos_border

Townless_Player_Script:
    type: world
    debug: false
    events:
        after player respawns priority:3:
            - if !<player.in_group[prisoner]>:
                - if !<player.has_town>:
                    - if !<player.in_group[outlaw]>:
                        - execute as_server "lp user <player.name> parent add outlaw" silent
                    - teleport <player> <location[townless_spawn]>
                - else:
                    - if <player.in_group[outlaw]>:
                        - execute as_server "lp user <player.name> parent remove outlaw" silent