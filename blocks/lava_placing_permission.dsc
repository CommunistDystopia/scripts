Lava_Placing_Permission_Script:
    type: world
    debug: false
    events:
        on player right clicks block with:lava_bucket:
            - if !<player.has_permission[place.lava]>:
                - determine cancelled