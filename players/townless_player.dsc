Townless_Player_Script:
    type: world
    debug: false
    events:
        on player respawns:
            - if !<player.in_group[slave]>:
                - if <player.town||null> == null:
                    - if !<player.in_group[outlaw]>:
                        - group add outlaw
                    - determine <location[townless_spawn]>
                - else:
                    - if <player.in_group[outlaw]>:
                        - group remove outlaw