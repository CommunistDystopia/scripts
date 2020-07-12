Placing_Permissions_Script:
    type: world
    debug: false
    events:
        on player right clicks block with:lava_bucket:
            - if !<player.has_permission[place.lava]>:
                - determine cancelled
        on player right clicks block with:item_frame:
            - if !<player.has_permission[place.item_frame]>:
                - determine cancelled
        on player right clicks block with:water_bucket:
            - if <player.in_group[outlaw]>:
                - determine cancelled