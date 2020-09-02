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
            - ratelimit <player> 1s
            - run Fill_Machine_Task def:<player.inventory>|<context.location.inventory>|Emerald_Washer|0
        on DROPPER dispenses item:
            - define machine_inventory <context.location.inventory>
            - define item_drop <context.item>
            - define machine_name Emerald_Washer
            - define upgrade_amount 0
            - inject Machine_Task instantly
        on player breaks dropper:
            - define machine_slot <context.location.inventory.find_imperfect[Emerald_Washer]>
            - inject Security_Machine_Task instantly
        on player right clicks dropper:
            - define machine_slot <context.location.inventory.find_imperfect[Emerald_Washer]>
            - inject Security_Machine_Task instantly
        after item moves from inventory:
            - run Filter_Machine_Task def:Emerald_Washer|<context.destination>|<context.item>

# EMERALD WASHER #

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
        - <gray>Default ratio
        - <gray>1 <white>Gold Ingot
        - <gray>1 <white>Green Crystal
        - <gray>Result: <green>Emerald
    recipes:
        1:
            type: shaped
            input:
                - emerald_block|water_bucket|emerald_block
                - emerald_block|water_bucket|emerald_block