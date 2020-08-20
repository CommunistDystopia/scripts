# +----------------------
# |
# | HIDDEN MASK
# |
# | Hide your identity.
# |
# +----------------------
#
# @author devnodachi
# @date 2020/08/19
# @denizen-build REL-1714
#

Hidden_Mask_Command:
    type: command
    debug: false
    name: hiddenmask
    description: Minecraft Hidden Mask system.
    usage: /hiddenmask
    tab complete:
        - if !<player.is_op||<context.server>>:
            - stop
        - choose <context.args.size>:
            - case 0:
                - determine <list[1|2|3|4|5|6|7|8]>
            - case 1:
                - if "!<context.raw_args.ends_with[ ]>":
                    - determine <list[1|2|3|4|5|6|7|8].filter[starts_with[<context.args.first>]]>
    script:
        - if !<player.is_op||<context.server>>:
                - narrate "<red>You do not have permission for that command."
                - stop
        - if <context.args.size> < 1:
            - narrate "<red> USAGE: <white>/hiddenmask <yellow>[1-8]"
            - stop
        - define mask_number <context.args.get[1]>
        - if !<[mask_number].is_integer>:
            - narrate "<red> ERROR: The mask number needs to be a number!"
            - stop
        - if <[mask_number]> > 8:
            - narrate "<red> ERROR: The mask number can be only between 1-8"
            - stop
        - define mask <player.inventory.slot[<player.held_item_slot>]>
        - if <[mask].material.name> != PLAYER_HEAD:
            - narrate "<red> ERROR: You must hold a <yellow>player head <red>in your hand to config this mask!"
            - stop
        - flag server hidden_mask_<[mask_number]>:<[mask]>
        - narrate "<yellow> Mask <[mask_number]> <green>configured with the <yellow>player head <green>in your hand!"

Hidden_Mask_Script:
    type: world
    debug: false
    events:
        on player crafts placeholder_hidden_mask_*:
            - inject Hidden_Mask_Recipe_Task
        on placeholder_hidden_mask_* recipe formed:
            - inject Hidden_Mask_Recipe_Task
        on player equips helmet:
            - define action_type EQUIP
            - inject Hidden_Mask_Action_Task
        on player unequips helmet:
            - define action_type UNEQUIP
            - inject Hidden_Mask_Action_Task
        on player dies by:player:
            - define action_type DEATH
            - inject Hidden_Mask_Action_Task

Hidden_Mask_Recipe_Task:
    type: task
    debug: false
    script:
        - define mask_number <context.item.scriptname.after[placeholder_hidden_mask_]>
        - define mask_config <script[Hidden_Mask_Config].data_key[masks]||null>
        - if <[mask_config]> != null && <[mask_number].is_integer>:
            - if <[mask_config].get[<[mask_number]>]||null> != null:
                - determine <server.flag[<[mask_config].get[<[mask_number]>].get[flag]>].as_item>

Hidden_Mask_Action_Task:
    type: task
    debug: false
    script:
        - if <script[Hidden_Mask_Config].data_key[masks]||null> != null:
            - foreach <script[Hidden_Mask_Config].data_key[masks]> as:mask:
                - if <server.has_flag[<[mask].get[flag]>]>:
                    - choose <[action_type]>:
                        - case EQUIP:
                            - if <context.new_item> == <server.flag[<[mask].get[flag]>].as_item>:
                                - adjust <player> name:<element[]>
                                - foreach stop
                        - case UNEQUIP:
                            - if <context.new_item> != <server.flag[<[mask].get[flag]>].as_item> && <context.old_item> == <server.flag[<[mask].get[flag]>].as_item>:
                                - adjust <player> name:<player.name>
                                - foreach stop
                        - case DEATH:
                            - if <context.damager.inventory.find[<server.flag[<[mask].get[flag]>].as_item>]> == 40:
                                - determine NO_MESSAGE

####################
## HIDDEN MASK
## CRAFTING RECIPES
####################

placeholder_hidden_mask_1:
    type: item
    debug: false
    material: stick
    mechanisms:
        hides: enchants
    enchantments:
        - unbreaking:1
    display name: <red>Hidden Mask 1
    lore:
        - <gray>Placeholder item for Hidden Mask 1
    recipes:
        1:
            type: shaped
            input:
                - emerald_block|<script[Hidden_Mask_Config].data_key[masks].get[1].get[item]>
                - leather|leather

placeholder_hidden_mask_2:
    type: item
    debug: false
    material: stick
    mechanisms:
        hides: enchants
    enchantments:
        - unbreaking:1
    display name: <red>Hidden Mask 2
    lore:
        - <gray>Placeholder item for Hidden Mask 2
    recipes:
        1:
            type: shaped
            input:
                - emerald_block|<script[Hidden_Mask_Config].data_key[masks].get[2].get[item]>
                - leather|leather

placeholder_hidden_mask_3:
    type: item
    debug: false
    material: stick
    mechanisms:
        hides: enchants
    enchantments:
        - unbreaking:1
    display name: <red>Hidden Mask 3
    lore:
        - <gray>Placeholder item for Hidden Mask 3
    recipes:
        1:
            type: shaped
            input:
                - emerald_block|<script[Hidden_Mask_Config].data_key[masks].get[3].get[item]>
                - leather|leather

placeholder_hidden_mask_4:
    type: item
    debug: false
    material: stick
    mechanisms:
        hides: enchants
    enchantments:
        - unbreaking:1
    display name: <red>Hidden Mask 4
    lore:
        - <gray>Placeholder item for Hidden Mask 4
    recipes:
        1:
            type: shaped
            input:
                - emerald_block|<script[Hidden_Mask_Config].data_key[masks].get[4].get[item]>
                - leather|leather

placeholder_hidden_mask_5:
    type: item
    debug: false
    material: stick
    mechanisms:
        hides: enchants
    enchantments:
        - unbreaking:1
    display name: <red>Hidden Mask 5
    lore:
        - <gray>Placeholder item for Hidden Mask 5
    recipes:
        1:
            type: shaped
            input:
                - emerald_block|<script[Hidden_Mask_Config].data_key[masks].get[5].get[item]>
                - leather|leather

placeholder_hidden_mask_6:
    type: item
    debug: false
    material: stick
    mechanisms:
        hides: enchants
    enchantments:
        - unbreaking:1
    display name: <red>Hidden Mask 6
    lore:
        - <gray>Placeholder item for Hidden Mask 6
    recipes:
        1:
            type: shaped
            input:
                - emerald_block|<script[Hidden_Mask_Config].data_key[masks].get[6].get[item]>
                - leather|leather

placeholder_hidden_mask_7:
    type: item
    debug: false
    material: stick
    mechanisms:
        hides: enchants
    enchantments:
        - unbreaking:1
    display name: <red>Hidden Mask 7
    lore:
        - <gray>Placeholder item for Hidden Mask 7
    recipes:
        1:
            type: shaped
            input:
                - emerald_block|<script[Hidden_Mask_Config].data_key[masks].get[7].get[item]>
                - leather|leather

placeholder_hidden_mask_8:
    type: item
    debug: false
    material: stick
    mechanisms:
        hides: enchants
    enchantments:
        - unbreaking:1
    display name: <red>Hidden Mask 8
    lore:
        - <gray>Placeholder item for Hidden Mask 8
    recipes:
        1:
            type: shaped
            input:
                - emerald_block|<script[Hidden_Mask_Config].data_key[masks].get[8].get[item]>
                - leather|leather