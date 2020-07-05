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

Emerald_Extractor_T2:
    type: item
    material: enchanted_book
    display name: <yellow>Upgrade T2
    lore:
        - <gray>Lower the ratio to
        - <gray>16 <white>Coal
        - <gray>8 <white>Green Dye
        - <gray>Works with: <green>Emerald Extractor

Emerald_Extractor_T3:
    type: item
    material: enchanted_book
    display name: <yellow>Upgrade T3
    lore:
        - <gray>Lower the ratio to
        - <gray>8 <white>Coal
        - <gray>4 <white>Green Dye
        - <gray>Works with: <green>Emerald Extractor

Emerald_Extractor_T4:
    type: item
    material: enchanted_book
    display name: <yellow>Upgrade T4
    lore:
        - <gray>Lower the ratio to
        - <gray>4 <white>Coal
        - <gray>2 <white>Green Dye
        - <gray>Works with: <green>Emerald Extractor

Emerald_Extractor_T5:
    type: item
    material: enchanted_book
    display name: <yellow>Upgrade T5
    lore:
        - <gray>Lower the ratio to
        - <gray>2 <white>Coal
        - <gray>1 <white>Green Dye
        - <gray>Works with: <green>Emerald Extractor