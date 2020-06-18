explosive_vest:
    type: item
    material: leather_chestplate
    mechanisms:
        repair_cost: 99
        hides: attributes|enchants
        enchantments: unbreaking,1
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
                - inventory exclude o:<player.inventory.equipment.get[3]>
                - explode power:5 <player.location> breakblocks
                - hurt 999 <player.location.find.players.within[3]>
