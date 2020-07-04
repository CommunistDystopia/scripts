Emerald_Extractor_Script:
    type: world
    debug: false
    events:
        on player places emerald_extractor:
            - determine cancelled
        on DROPPER dispenses item:
            - define dropper_inv <context.location.inventory>
            - define dropper_inv_inc <context.location.inventory.include[<context.item>]>
            - define extractor_slot <[dropper_inv_inc].find_imperfect[emerald_extractor]>
            - if <[extractor_slot]> != -1:
                - define ex_lore_last <[dropper_inv_inc].slot[<[extractor_slot]>].lore.last>
                - if <[ex_lore_last]> == <red>Damaged:
                    - determine cancelled
                    - stop
                - if !<[dropper_inv].contains_any[ex_upgrade_1|ex_upgrade_2|ex_upgrade_3|ex_upgrade_4|ex_upgrade_5]>:
                    - if <context.item> != <item[ex_upgrade_1]> && <context.item> != <item[ex_upgrade_2]> && <context.item> != <item[ex_upgrade_3]> && <context.item> != <item[ex_upgrade_4]> && <context.item> != <item[ex_upgrade_5]>:
                        - if <[dropper_inv].quantity.material[coal]> < 64 || <[dropper_inv].quantity.material[green_dye]> < 32:
                            - determine cancelled
                            - stop
                        - take material:coal quantity:64 from:<context.location.inventory>
                        - take material:green_dye quantity:32 from:<context.location.inventory>
                        - determine <item[green_crystal]>
                        - determine passively cancelled:false
                        - stop
                - if <[dropper_inv].contains[ex_upgrade_1]> || <context.item> == <item[ex_upgrade_1]>:
                    - if <[dropper_inv].quantity.material[coal]> < 32 || <[dropper_inv].quantity.material[green_dye]> < 16:
                        - determine cancelled
                        - stop
                    - take material:coal quantity:32 from:<context.location.inventory>
                    - take material:green_dye quantity:16 from:<context.location.inventory>
                    - determine <item[green_crystal]>
                    - determine passively cancelled:false
                    - stop
                - if <[dropper_inv].contains[ex_upgrade_2]> || <context.item> == <item[ex_upgrade_2]>:
                    - if <[dropper_inv].quantity.material[coal]> < 16 || <[dropper_inv].quantity.material[green_dye]> < 8:
                        - determine cancelled
                        - stop
                    - take material:coal quantity:16 from:<context.location.inventory>
                    - take material:green_dye quantity:8 from:<context.location.inventory>
                    - determine <item[green_crystal]>
                    - determine passively cancelled:false
                    - stop
                - if <[dropper_inv].contains[ex_upgrade_3]> || <context.item> == <item[ex_upgrade_3]>:
                    - if <[dropper_inv].quantity.material[coal]> < 8 || <[dropper_inv].quantity.material[green_dye]> < 4:
                        - determine cancelled
                        - stop
                    - take material:coal quantity:8 from:<context.location.inventory>
                    - take material:green_dye quantity:4 from:<context.location.inventory>
                    - determine <item[green_crystal]>
                    - determine passively cancelled:false
                    - stop
                - if <[dropper_inv].contains[ex_upgrade_4]> || <context.item> == <item[ex_upgrade_4]>:
                    - if <[dropper_inv].quantity.material[coal]> < 4 || <[dropper_inv].quantity.material[green_dye]> < 2:
                        - determine cancelled
                        - stop
                    - take material:coal quantity:4 from:<context.location.inventory>
                    - take material:green_dye quantity:2 from:<context.location.inventory>
                    - determine <item[green_crystal]>
                    - determine passively cancelled:false
                    - stop
                - if <[dropper_inv].contains[ex_upgrade_5]> || <context.item> == <item[ex_upgrade_5]>:
                    - if <[dropper_inv].quantity.material[coal]> < 2 || <[dropper_inv].quantity.material[green_dye]> < 1:
                        - determine cancelled
                        - stop
                    - take material:coal quantity:2 from:<context.location.inventory>
                    - take material:green_dye quantity:1 from:<context.location.inventory>
                    - determine <item[green_crystal]>
                    - determine passively cancelled:false
                    - stop

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

emerald_extractor:
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

ex_upgrade_1:
    type: item
    material: enchanted_book
    display name: <yellow>Upgrade T1
    lore:
        - <gray>Lower the ratio to
        - <gray>32 <white>Coal
        - <gray>16 <white>Green Dye
        - <gray>Works with: <green>Emerald Extractor

ex_upgrade_2:
    type: item
    material: enchanted_book
    display name: <yellow>Upgrade T2
    lore:
        - <gray>Lower the ratio to
        - <gray>16 <white>Coal
        - <gray>8 <white>Green Dye
        - <gray>Works with: <green>Emerald Extractor

ex_upgrade_3:
    type: item
    material: enchanted_book
    display name: <yellow>Upgrade T3
    lore:
        - <gray>Lower the ratio to
        - <gray>8 <white>Coal
        - <gray>4 <white>Green Dye
        - <gray>Works with: <green>Emerald Extractor

ex_upgrade_4:
    type: item
    material: enchanted_book
    display name: <yellow>Upgrade T4
    lore:
        - <gray>Lower the ratio to
        - <gray>4 <white>Coal
        - <gray>2 <white>Green Dye
        - <gray>Works with: <green>Emerald Extractor

ex_upgrade_5:
    type: item
    material: enchanted_book
    display name: <yellow>Upgrade T5
    lore:
        - <gray>Lower the ratio to
        - <gray>2 <white>Coal
        - <gray>1 <white>Green Dye
        - <gray>Works with: <green>Emerald Extractor