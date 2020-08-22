# +----------------------
# |
# | D O C T O R
# |
# | Cure the effect of drugs.
# | Open job for the Doctor group.
# |
# +----------------------
#
# @author devnodachi
# @date 2020/08/02
# @denizen-build REL-1714
# @dependency devnodachi/drugs
#

Doctor_Script:
    type: world
    debug: false
    events:
        on player crafts medicine_drug:
            - if !<player.has_permission[craft.medicine.drug]>:
                - determine cancelled
        on player right clicks block with:medicine_drug:
            - if <player.has_flag[withdrawal_duration]>:
                - take medicine_drug from:<player.inventory>
                - flag <player> withdrawal_duration:!
                - flag <player> drug_used:!
                - flag <player> withdrawal_cooldown:!
                - flag <player> withdrawal_message_cooldown:!
                - cast SLOW remove
                - cast BLINDNESS remove
                - narrate "<green> You feel a lot better after drinking the medicine"
            - determine cancelled

medicine_drug:
    type: item
    debug: false
    material: potion
    mechanisms:
        hides: enchants
    enchantments:
        - unbreaking:1
    display name: <green>Drug Medicine
    lore:
        - <green>Cure the withdrawal effect from drugs
    recipes:
        1:
            type: shaped
            input:
                - air|poppy|air
                - red_mushroom|bubble_coral_fan|red_mushroom
                - emerald|air|emerald