Emerald_Washer_Script:
    type: world
    debug: false
    events:
        on player places emerald_washer:
            - determine cancelled
        on DROPPER dispenses item:
            - define dropper_inv <context.location.inventory>
            - define dropper_inv_inc <context.location.inventory.include[<context.item>]>
            - define washer_slot <[dropper_inv_inc].find_imperfect[emerald_washer]>
            - if <[washer_slot]> != -1:
                - define washer_lore_last <[dropper_inv_inc].slot[<[washer_slot]>].lore.last>
                - if <[washer_lore_last]> == "<red>Damaged":
                    - determine cancelled
                    - stop
                - if !<[dropper_inv].contains_any[ew_upgrade_1|ew_upgrade_2|ew_upgrade_3|ew_upgrade_4|ew_upgrade_5]>:
                    - if <context.item> != <item[ew_upgrade_1]> && <context.item> != <item[ew_upgrade_2]> && <context.item> != <item[ew_upgrade_3]> && <context.item> != <item[ew_upgrade_4]> && <context.item> != <item[ew_upgrade_5]>:
                        - if <[dropper_inv].quantity.material[gold_ingot]> < 64 || <[dropper_inv].quantity[green_crystal]> < 32 || <[dropper_inv].quantity.material[water_bucket]> < 1:
                            - determine cancelled
                            - stop
                        - take material:gold_ingot quantity:64 from:<context.location.inventory>
                        - take <item[green_crystal]> quantity:32 from:<context.location.inventory>
                        - take material:water_bucket quantity:1 from:<context.location.inventory>
                        - give bucket to:<context.location.inventory>
                        - determine <item[emerald]>
                        - determine passively cancelled:false
                        - stop
                - if <[dropper_inv].contains[ew_upgrade_1]> || <context.item> == <item[ew_upgrade_1]>:
                    - if <[dropper_inv].quantity.material[gold_ingot]> < 32 || <[dropper_inv].quantity[green_crystal]> < 26 || <[dropper_inv].quantity.material[water_bucket]> < 1:
                        - determine cancelled
                        - stop
                    - take material:gold_ingot quantity:32 from:<context.location.inventory>
                    - take <item[green_crystal]> quantity:26 from:<context.location.inventory>
                    - take material:water_bucket quantity:1 from:<context.location.inventory>
                    - give bucket to:<context.location.inventory>
                    - determine <item[emerald]>
                    - determine passively cancelled:false
                    - stop
                - if <[dropper_inv].contains[ew_upgrade_2]> || <context.item> == <item[ew_upgrade_2]>:
                    - if <[dropper_inv].quantity.material[gold_ingot]> < 16 || <[dropper_inv].quantity[green_crystal]> < 20 || <[dropper_inv].quantity.material[water_bucket]> < 1:
                        - determine cancelled
                        - stop
                    - take material:gold_ingot quantity:16 from:<context.location.inventory>
                    - take <item[green_crystal]> quantity:20 from:<context.location.inventory>
                    - take material:water_bucket quantity:1 from:<context.location.inventory>
                    - give bucket to:<context.location.inventory>
                    - determine <item[emerald]>
                    - determine passively cancelled:false
                    - stop
                - if <[dropper_inv].contains[ew_upgrade_3]> || <context.item> == <item[ew_upgrade_3]>:
                    - if <[dropper_inv].quantity.material[gold_ingot]> < 8 || <[dropper_inv].quantity[green_crystal]> < 15 || <[dropper_inv].quantity.material[water_bucket]> < 1:
                        - determine cancelled
                        - stop
                    - take material:gold_ingot quantity:8 from:<context.location.inventory>
                    - take <item[green_crystal]> quantity:15 from:<context.location.inventory>
                    - take material:water_bucket quantity:1 from:<context.location.inventory>
                    - give bucket to:<context.location.inventory>
                    - determine <item[emerald]>
                    - determine passively cancelled:false
                    - stop
                - if <[dropper_inv].contains[ew_upgrade_4]> || <context.item> == <item[ew_upgrade_4]>:
                    - if <[dropper_inv].quantity.material[gold_ingot]> < 4 || <[dropper_inv].quantity[green_crystal]> < 10 || <[dropper_inv].quantity.material[water_bucket]> < 1:
                        - determine cancelled
                        - stop
                    - take material:gold_ingot quantity:4 from:<context.location.inventory>
                    - take <item[green_crystal]> quantity:10 from:<context.location.inventory>
                    - take material:water_bucket quantity:1 from:<context.location.inventory>
                    - give bucket to:<context.location.inventory>
                    - determine <item[emerald]>
                    - determine passively cancelled:false
                    - stop
                - if <[dropper_inv].contains[ew_upgrade_5]> || <context.item> == <item[ew_upgrade_5]>:
                    - if <[dropper_inv].quantity.material[gold_ingot]> < 2 || <[dropper_inv].quantity[green_crystal]> < 5 || <[dropper_inv].quantity.material[water_bucket]> < 1:
                        - determine cancelled
                        - stop
                    - take material:gold_ingot quantity:2 from:<context.location.inventory>
                    - take <item[green_crystal]> quantity:5 from:<context.location.inventory>
                    - take material:water_bucket quantity:1 from:<context.location.inventory>
                    - give bucket to:<context.location.inventory>
                    - determine <item[emerald]>
                    - determine passively cancelled:false
                    - stop

# EMERALD EXTRACTOR #

emerald_washer:
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

ew_upgrade_1:
    type: item
    material: enchanted_book
    display name: <yellow>Upgrade T1
    lore:
        - <gray>Lower the ratio to
        - <gray>32 <white>Gold Ingot
        - <gray>26 <white>Green Crystal
        - <gray>Works with: <green>Emerald Washer

ew_upgrade_2:
    type: item
    material: enchanted_book
    display name: <yellow>Upgrade T2
    lore:
        - <gray>Lower the ratio to
        - <gray>16 <white>Gold Ingot
        - <gray>20 <white>Green Crystal
        - <gray>Works with: <green>Emerald Washer

ew_upgrade_3:
    type: item
    material: enchanted_book
    display name: <yellow>Upgrade T3
    lore:
        - <gray>Lower the ratio to
        - <gray>8 <white>Gold Ingot
        - <gray>15 <white>Green Crystal
        - <gray>Works with: <green>Emerald Washer

ew_upgrade_4:
    type: item
    material: enchanted_book
    display name: <yellow>Upgrade T4
    lore:
        - <gray>Lower the ratio to
        - <gray>4 <white>Gold Ingot
        - <gray>10 <white>Green Crystal
        - <gray>Works with: <green>Emerald Washer

ew_upgrade_5:
    type: item
    material: enchanted_book
    display name: <yellow>Upgrade T5
    lore:
        - <gray>Lower the ratio to
        - <gray>2 <white>Gold Ingot
        - <gray>5 <white>Green Crystal
        - <gray>Works with: <green>Emerald Washer