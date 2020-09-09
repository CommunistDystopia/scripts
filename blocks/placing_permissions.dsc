# +----------------------
# |
# | PLACING PERMISSIONS
# |
# +----------------------
#
# @author devnodachi
# @date 2020/08/02
# @denizen-build REL-1714
#

Placing_Permissions_Script:
    type: world
    debug: false
    events:
        on player right clicks block with:item_frame using:either_hand:
            - if !<player.has_permission[place.item_frame]>:
                - determine cancelled
        on player right clicks block with:*_bucket using:either_hand:
            - if !<player.is_op> && <context.click_type> != RIGHT_CLICK_AIR:
                - if <context.item.material.name> == LAVA_BUCKET:
                    - if !<player.has_permission[place.lava]>:
                        - determine cancelled
                - else:
                    - if !<player.has_permission[place.water]>:
                        - determine cancelled
        on player right clicks block with:*_boat using:either_hand:
            - if !<player.is_op> && <context.click_type> != RIGHT_CLICK_AIR:
                - if <context.location.material.name> != WATER:
                    - determine cancelled