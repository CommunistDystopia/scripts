Rotten_Silverfish_Script:
    type: world
    debug: false
    events:
        on player closes inventory:
            - if <context.inventory.inventory_type> == SMOKER || <context.inventory.inventory_type> == FURNACE || <context.inventory.inventory_type> == CHEST:
                - define map_inv <context.inventory.map_slots>
                - foreach <[map_inv].keys> as:inv_slot:
                    - if <context.inventory.slot[<[inv_slot]>].material.is_edible>:
                        - inventory adjust slot:<[inv_slot]> lore:expires_in:<util.time_now.add[1d].to_utc.format> d:<context.inventory>
        on player opens inventory:
            - if <context.inventory.inventory_type> != CRAFTING && <context.inventory.inventory_type> != PLAYER:
                - define items_with_lore <context.inventory.list_contents.filter[has_lore]>
                - foreach <[items_with_lore]> as:item_for:
                    - if <[item_for].material.is_edible>:
                        - define food_expiration_date <[item_for].lore.filter[contains[expires_in:]]>
                        - if !<[food_expiration_date].is_empty>:
                            - define space " "
                            - define expiration_time <time[<[food_expiration_date].first.after[expires_in:].replace_text[<[space]>].with[_]>]>
                            - define time_now <util.time_now.to_utc>
                            - if <[time_now].is_after[<[expiration_time]>]>:
                                - inventory exclude d:<context.inventory.location> o:<[item_for]>
                                - spawn silverfish <player.location>
        after player drags in inventory:
                - if <context.item.has_lore> && <context.item.material.is_edible>:
                    - foreach <context.slots> as:slot_for:
                        - inventory adjust slot:<[slot_for]> lore:<list[]>