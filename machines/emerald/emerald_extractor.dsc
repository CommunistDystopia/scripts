Emerald_Extractor_Script:
    type: world
    debug: false
    events:
        on player crafts emerald_extractor:
            - define owner <context.item.lore.include[Owner:<player.uuid>]>
            - determine <context.item.with[lore=<[owner]>]>
            - flag player manager:true
        on player left clicks dropper:
            - run Fill_Machine_Task def:<player.inventory>|<context.location.inventory>|Emerald_Extractor|5
        on player left clicks dropper with:wrench:
            - run Repair_Machine_Task def:<player.inventory>|<context.location.inventory>|Emerald_Extractor|5
        on player places emerald_extractor:
            - determine cancelled
        on DROPPER dispenses item:
            - define machine_inventory <context.location.inventory>
            - define item_drop <context.item>
            - define machine_name Emerald_Extractor
            - define upgrade_amount 5
            - inject Machine_Task instantly
        on player clicks in Emerald_Extractor_Shop:
            - if !<context.item.has_script>:
                - determine cancelled
            - define key <context.item.script.name.replace_text[_T].with[_upgrade_]>
            - define upgrade_cost <script[Emerald_Extractor_Data].data_key[<[key]>].get[upgrade_cost]>
            - foreach <[upgrade_cost].list_keys> as:upgrade_item:
                - define item_quantity <[upgrade_cost].get[<[upgrade_item]>]>
                - if !<player.inventory.contains[<[upgrade_item]>].quantity[<[item_quantity]>]>:
                    - narrate "<red> ERROR: You don't have enough items to purchase this upgrade."
                    - inventory close d:<context.inventory>
                    - determine cancelled
                    - stop
            - foreach <[upgrade_cost].list_keys> as:upgrade_item:
                - define item_quantity <[upgrade_cost].get[<[upgrade_item]>]>
                - if <script[<[upgrade_item]>]||null> == null:
                    - take material:<[upgrade_item]> from:<player.inventory> quantity:<[item_quantity]>
                    - if <[upgrade_item]> == water_bucket || <[upgrade_item]> == lava_bucket:
                        - give bucket to:<player.inventory>
                - else:
                    - take <[upgrade_item]> from:<player.inventory> quantity:<[item_quantity]>
            - define item_lore <context.item.lore.get[1].to[<context.item.lore.size.sub[<[upgrade_cost].size.add[1]>]>]>
            - give <context.item.with[lore=<[item_lore]>]> to:<player.inventory>
            - narrate "<green> Thanks for buying the Emerald Extractor <blue><context.item.display><green>!"
            - determine cancelled

# Green Crystal #

green_crystal:
    type: item
    material: prismarine_crystals
    mechanisms:
        hides: enchants
    enchantments:
        - unbreaking:1
    display name: <green>Green Crystal
    lore:
        - <gray>Wash to get Emeralds.

# EMERALD EXTRACTOR #

Emerald_Extractor:
    type: item
    material: coal_block
    mechanisms:
        hides: enchants
    enchantments:
        - unbreaking:1
    display name: <green>Emerald Extractor
    lore:
        - <gray>Add to a dropper to make it a machine.
        - <gray>Default ratio
        - <gray>64 <white>Coal
        - <gray>32 <white>Green Dye
        - <gray>Result: <green>Green Crystal
    recipes:
        1:
            type: shaped
            input:
                - blast_furnace|diamond_block|blast_furnace
                - blast_furnace|emerald_block|blast_furnace
                - blast_furnace|emerald_block|blast_furnace

# UPGRADES #

Emerald_Extractor_T1:
    type: item
    material: enchanted_book
    display name: <yellow>Upgrade T1
    lore:
        - <gray>Lower the ratio to
        - <gray>32 <white>Coal
        - <gray>16 <white>Green Dye
        - <gray>Works with: <green>Emerald Extractor
        - Price
        - <green>3 <white>Emerald Block
        
Emerald_Extractor_T2:
    type: item
    material: enchanted_book
    display name: <yellow>Upgrade T2
    lore:
        - <gray>Lower the ratio to
        - <gray>16 <white>Coal
        - <gray>8 <white>Green Dye
        - <gray>Works with: <green>Emerald Extractor
        - Price
        - <blue>3 <white>Diamond Block
        - <green>3 <white>Emerald Block

Emerald_Extractor_T3:
    type: item
    material: enchanted_book
    display name: <yellow>Upgrade T3
    lore:
        - <gray>Lower the ratio to
        - <gray>8 <white>Coal
        - <gray>4 <white>Green Dye
        - <gray>Works with: <green>Emerald Extractor
        - Price
        - <green>6 <white>Emerald Block

Emerald_Extractor_T4:
    type: item
    material: enchanted_book
    display name: <yellow>Upgrade T4
    lore:
        - <gray>Lower the ratio to
        - <gray>4 <white>Coal
        - <gray>2 <white>Green Dye
        - <gray>Works with: <green>Emerald Extractor
        - Price
        - <blue>3 <white>Diamond Block
        - <green>6 <white>Emerald Block

Emerald_Extractor_T5:
    type: item
    material: enchanted_book
    display name: <yellow>Upgrade T5
    lore:
        - <gray>Lower the ratio to
        - <gray>2 <white>Coal
        - <gray>1 <white>Green Dye
        - <gray>Works with: <green>Emerald Extractor
        - Price
        - <green>9 <white>Emerald Block

# SHOP #

Emerald_Extractor_Shop:
    type: inventory
    inventory: chest
    title: Emerald Extractor Shop
    size: 9
    slots:
        - [Emerald_Extractor_T1] [Emerald_Extractor_T2] [Emerald_Extractor_T3] [Emerald_Extractor_T4] [Emerald_Extractor_T5] [] [] [] []
