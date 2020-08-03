# +----------------------
# |
# | EMERALD EXTRACTOR
# |
# | A Machine that produces emeralds with green crystals.
# |
# +----------------------
#
# @author devnodachi
# @date 2020/08/02
# @denizen-build REL-1714
# @dependency devnodachi/machine_factory devnodachi/emerald/emerald_extractor
#

Emerald_Washer_Script:
    type: world
    debug: false
    events:
        on player crafts emerald_washer:
            - define owner <context.item.lore.include[Owner:<player.uuid>]>
            - flag <player> manager:true
            - determine <context.item.with[lore=<[owner]>]>
        on player places emerald_washer:
            - determine cancelled
        on player left clicks dropper:
            - run Fill_Machine_Task def:<player.inventory>|<context.location.inventory>|Emerald_Washer|5
        on player left clicks dropper with:wrench:
            - run Repair_Machine_Task def:<player.inventory>|<context.location.inventory>|Emerald_Washer|5
        on DROPPER dispenses item:
            - define machine_inventory <context.location.inventory>
            - define item_drop <context.item>
            - define machine_name Emerald_Washer
            - define upgrade_amount 5
            - inject Machine_Task instantly
        on player clicks in Emerald_Washer_Shop:
            - if !<context.item.has_script>:
                - determine cancelled
            - define key <context.item.script.name.replace_text[_T].with[_upgrade_]>
            - define upgrade_cost <script[Emerald_Washer_Data].data_key[<[key]>].get[upgrade_cost]>
            - foreach <[upgrade_cost].keys> as:upgrade_item:
                - define item_quantity <[upgrade_cost].get[<[upgrade_item]>]>
                - if !<player.inventory.contains[<[upgrade_item]>].quantity[<[item_quantity]>]>:
                    - narrate "<red> ERROR: You don't have enough items to purchase this upgrade."
                    - inventory close d:<context.inventory>
                    - determine cancelled
                    - stop
            - foreach <[upgrade_cost].keys> as:upgrade_item:
                - define item_quantity <[upgrade_cost].get[<[upgrade_item]>]>
                - if <script[<[upgrade_item]>]||null> == null:
                    - take material:<[upgrade_item]> from:<player.inventory> quantity:<[item_quantity]>
                    - if <[upgrade_item]> == water_bucket || <[upgrade_item]> == lava_bucket:
                        - give bucket to:<player.inventory>
                - else:
                    - take <[upgrade_item]> from:<player.inventory> quantity:<[item_quantity]>
            - define item_lore <context.item.lore.get[1].to[<context.item.lore.size.sub[<[upgrade_cost].size.add[1]>]>]>
            - give <context.item.with[lore=<[item_lore]>]> to:<player.inventory>
            - narrate "<green> Thanks for buying the Emerald Washer <blue><context.item.display><green>!"
            - determine cancelled
        on player breaks dropper:
            - define machine_slot <context.location.inventory.find_imperfect[Emerald_Washer]>
            - inject Security_Machine_Task instantly
        on player right clicks dropper:
            - define machine_slot <context.location.inventory.find_imperfect[Emerald_Washer]>
            - inject Security_Machine_Task instantly
        after item moves from inventory:
            - run Filter_Machine_Task def:Emerald_Washer|<context.destination>|<context.item>


# EMERALD EXTRACTOR #

Emerald_Washer:
    type: item
    debug: false
    material: tube_coral_block
    mechanisms:
        hides: enchants
    enchantments:
        - unbreaking:1
    display name: <green>Emerald Washer
    lore:
        - <gray>Add to a dropper to make it a machine.
        - <gray>Must have: <white>Water Bucket
        - <gray>Default ratio
        - <gray>64 <white>Gold Ingot
        - <gray>32 <white>Green Crystal
        - <gray>Result: <green>Emerald
    recipes:
        1:
            type: shaped
            input:
                - horn_coral_block|horn_coral_block|horn_coral_block
                - emerald_block|water_bucket|emerald_block
                - emerald_block|honeycomb_block|emerald_block

# UPGRADES #

Emerald_Washer_T1:
    type: item
    debug: false
    material: enchanted_book
    display name: <yellow>Upgrade T1
    lore:
        - <gray>Lower the ratio to
        - <gray>32 <white>Gold Ingot
        - <gray>26 <white>Green Crystal
        - <gray>Works with: <green>Emerald Washer
        - Price
        - <green>3 <white>Emerald Block

Emerald_Washer_T2:
    type: item
    debug: false
    material: enchanted_book
    display name: <yellow>Upgrade T2
    lore:
        - <gray>Lower the ratio to
        - <gray>16 <white>Gold Ingot
        - <gray>20 <white>Green Crystal
        - <gray>Works with: <green>Emerald Washer
        - Price
        - <blue>3 <white>Diamond Block
        - <green>3 <white>Emerald Block

Emerald_Washer_T3:
    type: item
    debug: false
    material: enchanted_book
    display name: <yellow>Upgrade T3
    lore:
        - <gray>Lower the ratio to
        - <gray>8 <white>Gold Ingot
        - <gray>15 <white>Green Crystal
        - <gray>Works with: <green>Emerald Washer
        - Price
        - <green>6 <white>Emerald Block

Emerald_Washer_T4:
    type: item
    debug: false
    material: enchanted_book
    display name: <yellow>Upgrade T4
    lore:
        - <gray>Lower the ratio to
        - <gray>4 <white>Gold Ingot
        - <gray>10 <white>Green Crystal
        - <gray>Works with: <green>Emerald Washer
        - Price
        - <blue>3 <white>Diamond Block
        - <green>6 <white>Emerald Block

Emerald_Washer_T5:
    type: item
    debug: false
    material: enchanted_book
    display name: <yellow>Upgrade T5
    lore:
        - <gray>Lower the ratio to
        - <gray>2 <white>Gold Ingot
        - <gray>5 <white>Green Crystal
        - <gray>Works with: <green>Emerald Washer
        - Price
        - <green>9 <white>Emerald Block

# SHOP #

Emerald_Washer_Shop:
    type: inventory
    inventory: chest
    title: Emerald Washer Shop
    size: 9
    slots:
        - [Emerald_Washer_T1] [Emerald_Washer_T2] [Emerald_Washer_T3] [Emerald_Washer_T4] [Emerald_Washer_T5] [] [] [] []
