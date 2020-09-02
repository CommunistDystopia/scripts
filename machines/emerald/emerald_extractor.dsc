# +----------------------
# |
# | EMERALD EXTRACTOR
# |
# | A Machine that produces green crystals.
# |
# +----------------------
#
# @author devnodachi
# @date 2020/08/02
# @denizen-build REL-1714
# @dependency devnodachi/machine_factory
#

Emerald_Extractor_Script:
    type: world
    debug: false
    events:
        on player crafts emerald_extractor:
            - define owner <context.item.lore.include[Owner:<player.uuid>]>
            - flag <player> manager:true
            - determine <context.item.with[lore=<[owner]>]>
        on player left clicks dropper:
            - ratelimit <player> 1s
            - run Fill_Machine_Task def:<player.inventory>|<context.location.inventory>|Emerald_Extractor|0
        on player places emerald_extractor:
            - determine cancelled
        on DROPPER dispenses item:
            - define machine_inventory <context.location.inventory>
            - define item_drop <context.item>
            - define machine_name Emerald_Extractor
            - define upgrade_amount 0
            - inject Machine_Task instantly
## UPGRADE SHOP [Not removed for future usage]
#        on player clicks in Emerald_Extractor_Shop:
#            - if !<context.item.has_script>:
#                - determine cancelled
#            - define key <context.item.script.name.replace_text[_T].with[_upgrade_]>
#            - define upgrade_cost <script[Emerald_Extractor_Data].data_key[<[key]>].get[upgrade_cost]>
#            - foreach <[upgrade_cost].keys> as:upgrade_item:
#                - define item_quantity <[upgrade_cost].get[<[upgrade_item]>]>
#                - if !<player.inventory.contains[<[upgrade_item]>].quantity[<[item_quantity]>]>:
#                    - narrate "<red> ERROR: You don't have enough items to purchase this upgrade."
#                    - inventory close d:<context.inventory>
#                    - determine cancelled
#                    - stop
#            - foreach <[upgrade_cost].keys> as:upgrade_item:
#                - define item_quantity <[upgrade_cost].get[<[upgrade_item]>]>
#                - if <script[<[upgrade_item]>]||null> == null:
#                    - take material:<[upgrade_item]> from:<player.inventory> quantity:<[item_quantity]>
#                    - if <[upgrade_item]> == water_bucket || <[upgrade_item]> == lava_bucket:
#                        - give bucket to:<player.inventory>
#                - else:
#                    - take <[upgrade_item]> from:<player.inventory> quantity:<[item_quantity]>
#            - define item_lore <context.item.lore.get[1].to[<context.item.lore.size.sub[<[upgrade_cost].size.add[1]>]>]>
#            - give <context.item.with[lore=<[item_lore]>]> to:<player.inventory>
#            - narrate "<green> Thanks for buying the Emerald Extractor <blue><context.item.display><green>!"
#            - determine cancelled
        on player breaks dropper:
            - define machine_slot <context.location.inventory.find_imperfect[Emerald_Extractor]>
            - inject Security_Machine_Task instantly
        on player right clicks dropper:
            - define machine_slot <context.location.inventory.find_imperfect[Emerald_Extractor]>
            - inject Security_Machine_Task instantly
        after item moves from inventory:
            - run Filter_Machine_Task def:Emerald_Extractor|<context.destination>|<context.item>

# Green Crystal #

green_crystal:
    type: item
    debug: false
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
    debug: false
    material: coal_block
    mechanisms:
        hides: enchants
    enchantments:
        - unbreaking:1
    display name: <green>Emerald Extractor
    lore:
        - <gray>Add to a dropper to make it a machine.
        - <gray>Default ratio
        - <gray>1 <white>Coal
        - <gray>1 <white>Green Dye
        - <gray>Result: <green>Green Crystal
    recipes:
        1:
            type: shaped
            input:
                - blast_furnace|diamond_block|blast_furnace
                - blast_furnace|emerald_block|blast_furnace
                - blast_furnace|emerald_block|blast_furnace