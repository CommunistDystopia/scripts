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
        on player respawns:
            - if !<player.in_group[prisoner]>:
                - if <player.town||null> == null:
                    - if !<player.in_group[outlaw]>:
                        - group add outlaw
                    - determine <location[townless_spawn]>
                - else:
                    - if <player.in_group[outlaw]>:
                        - group remove outlaw