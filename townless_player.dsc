Townless_Player_Script:
    type: world
    debug: false
    events:
        on player respawns:
            - if !<player.in_group[slave]> && <player.town||null> == null:
                - group add outlaw
                - determine <location[townless_spawn]>