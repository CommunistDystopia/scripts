explosive_vest:
    type: item
    material: leather_chestplate
    mechanisms:
        repair_cost: 99
        hides: attributes|enchants
    enchantments:
        - unbreaking:1
        - vanishing_curse
    display name: <red>Explosive Vest
    lore:
        - <gray>It will detonate on player death.
        - <red>Be careful with your friends!
    recipes:
        1:
            type: shaped
            input:
                - tnt|emerald|tnt
                - tnt|leather_chestplate|tnt
                - tnt|landminer|tnt

Explosive_Vest_Script:
    type: world
    debug: false
    events:
        on player death:
            - if <player.inventory.equipment.get[3]> == <item[explosive_vest]>:
                - define inner_explosion_players <player.location.find.players.within[3]>
                - define outer_explosion_players <player.location.find.players.within[5]>
                - define current_location <player.location>
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
