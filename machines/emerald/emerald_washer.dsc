Emerald_Washer_Script:
    type: world
    debug: false
    events:
        on player crafts emerald_washer:
            - define owner <context.item.lore.include[Owner:<player.uuid>]>
            - determine <context.item.with[lore=<[owner]>]>
            - flag player manager:true
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

# EMERALD EXTRACTOR #

Emerald_Washer:
    type: item
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
    material: enchanted_book
    display name: <yellow>Upgrade T1
    lore:
        - <gray>Lower the ratio to
        - <gray>32 <white>Gold Ingot
        - <gray>26 <white>Green Crystal
        - <gray>Works with: <green>Emerald Washer

Emerald_Washer_T2:
    type: item
    material: enchanted_book
    display name: <yellow>Upgrade T2
    lore:
        - <gray>Lower the ratio to
        - <gray>16 <white>Gold Ingot
        - <gray>20 <white>Green Crystal
        - <gray>Works with: <green>Emerald Washer

Emerald_Washer_T3:
    type: item
    material: enchanted_book
    display name: <yellow>Upgrade T3
    lore:
        - <gray>Lower the ratio to
        - <gray>8 <white>Gold Ingot
        - <gray>15 <white>Green Crystal
        - <gray>Works with: <green>Emerald Washer

Emerald_Washer_T4:
    type: item
    material: enchanted_book
    display name: <yellow>Upgrade T4
    lore:
        - <gray>Lower the ratio to
        - <gray>4 <white>Gold Ingot
        - <gray>10 <white>Green Crystal
        - <gray>Works with: <green>Emerald Washer

Emerald_Washer_T5:
    type: item
    material: enchanted_book
    display name: <yellow>Upgrade T5
    lore:
        - <gray>Lower the ratio to
        - <gray>2 <white>Gold Ingot
        - <gray>5 <white>Green Crystal
        - <gray>Works with: <green>Emerald Washer