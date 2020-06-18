landminer:
    type: item
    material: iron_shovel
    mechanisms:
        durability: 249
        repair_cost: 99
        hides: attributes|enchants
        enchantments: unbreaking,1
    display name: <yellow>Landminer
    lore:
        - <gray>Right click a block to place a mine.
        - <red>Be careful!
    recipes:
        1:
            type: shaped
            input:
                - emerald|emerald|emerald
                - emerald|flint_and_steel|emerald
                - emerald|emerald|emerald

landmine:
    type: item
    material: tnt
    display name: <red>Landmine
    lore:
    - <gray>The dream destroyer.

Landmine_Script:
    type: world
    debug: false
    events:
        on player right clicks block with:landminer:
            - equip <player> hand:air
            - note <context.location.up[1]> as:landmine_<context.location.center.xyz.replace[,].with[-]>-<context.location.world>
            - narrate "<green>Landmine placed! <red>Be careful"
        on player walks over notable:
            - if <context.notable.starts_with[landmine_]>:
                - define inner_explosion_players <location[<context.notable>].find.players.within[3]>
                - define outer_explosion_players <location[<context.notable>].find.players.within[5]>
                - define current_location <location[<context.notable>]>
                - define dog_leashed <[current_location].find.entities[wolf].within[5].first.leash_holder||null>
                - if <player> == <[dog_leashed]>:
                    - define sniffing <util.random.int[0].to[100]>
                    - if <[sniffing]> <= 70:
                        - narrate "<yellow>Your dog sniffed a mine. <green>The mine is now disabled and visible."
                        - note remove as:<context.notable>
                        - stop
                - foreach <[inner_explosion_players]> as:player:
                    - equip <[player]> boots:air legs:air chest:air head:air
                - foreach <[outer_explosion_players]> as:player:
                    - define player_equipment_slots 37|38|39|40
                    - define player_equipment_without_air <[player].inventory.equipment.exclude[<item[air]>]>
                    - if !<[player_equipment_without_air].is_empty>:
                            - foreach <[player_equipment_slots]> as:armor_slot:
                                - define armor <[player].inventory.slot[<[armor_slot]>]>
                                - if <[armor]> != <item[air]>:
                                    - define new_durability <[armor].material.max_durability.add[<item[<[armor]>].durability>].div[2]>
                                    - inventory adjust slot:<[armor_slot]> durability:<[new_durability]>
                - explode power:5 <[current_location]> breakblocks
                - hurt 999 <[outer_explosion_players]>
                - note remove as:<context.notable>