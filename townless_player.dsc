Townless_Player_Script:
    type: world
    debug: false
    events:
        on player respawns:
            - if <player.town||null> == null:
                - group add outlaw
                - determine <location[townless_spawn]>