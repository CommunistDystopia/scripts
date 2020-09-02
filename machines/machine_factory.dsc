# +----------------------
# |
# | MACHINE FACTORY
# |
# | Used to make machines.
# |
# +----------------------
#
# @author devnodachi
# @date 2020/08/02
# @denizen-build REL-1714
#

Machine_Task:
    type: task
    debug: false
    definitions: machine_inventory|item_drop|machine_name|upgrade_amount
    script:
        - define machine_inventory_inc <[machine_inventory].include[<[item_drop]>]>
        - define machine_slot <[machine_inventory_inc].find_imperfect[<[machine_name]>]>
        - if <[machine_slot]> != -1:
            - if <[upgrade_amount]> > 0:
                - repeat <[upgrade_amount]>:
                    - if <[machine_inventory].find_imperfect[<[machine_name]>_T<[value]>]> != -1 || <[item_drop].script.name||null> == <script[<[machine_name]>_T<[value]>].name>:
                        - define machine_data <script[<[machine_name]>_Data].data_key[<[machine_name]>_Upgrade_<[value]>]>
                        - foreach <[machine_data].get[required_items].keys> as:machine_item:
                            - define item_quantity <[machine_data].get[required_items].get[<[machine_item]>]>
                            - if <script[<[machine_item]>]||null> == null:
                                - if <[machine_inventory].quantity.material[<[machine_item]>]> < <[item_quantity]>:
                                    - determine cancelled
                                    - stop
                            - else:
                                - if <[machine_inventory].quantity[<[machine_item]>]> < <[item_quantity]>:
                                    - determine cancelled
                                    - stop
                        - foreach <[machine_data].get[required_items].keys> as:machine_item:
                            - define item_quantity <[machine_data].get[required_items].get[<[machine_item]>]>
                            - if <script[<[machine_item]>]||null> == null:
                                - take material:<[machine_item]> from:<[machine_inventory]> quantity:<[item_quantity]>
                                - if <[machine_item]> == water_bucket || <[machine_item]> == lava_bucket:
                                    - give bucket to:<[machine_inventory]>
                            - else:
                                - take <[machine_item]> from:<[machine_inventory]> quantity:<[item_quantity]>
                        - determine <item[<script[<[machine_name]>_Data].data_key[product]>]>
                        - stop
            - define machine_default_data <script[<[machine_name]>_Data].data_key[<[machine_name]>_Default]>
            - foreach <[machine_default_data].get[required_items].keys> as:machine_item:
                - define item_quantity <[machine_default_data].get[required_items].get[<[machine_item]>]>
                - if <script[<[machine_item]>]||null> == null:
                    - if <[machine_inventory].quantity.material[<[machine_item]>]> < <[item_quantity]>:
                        - determine cancelled
                        - stop
                - else:
                    - if <[machine_inventory].quantity[<[machine_item]>]> < <[item_quantity]>:
                        - determine cancelled
                        - stop
            - foreach <[machine_default_data].get[required_items].keys> as:machine_item:
                - define item_quantity <[machine_default_data].get[required_items].get[<[machine_item]>]>
                - if <script[<[machine_item]>]||null> == null:
                    - take material:<[machine_item]> from:<[machine_inventory]> quantity:<[item_quantity]>
                    - if <[machine_item]> == water_bucket || <[machine_item]> == lava_bucket:
                        - give bucket to:<[machine_inventory]>
                - else:
                    - take <[machine_item]> from:<[machine_inventory]> quantity:<[item_quantity]>
            - determine <item[<script[<[machine_name]>_Data].data_key[product]>]>

Fill_Machine_Task:
    type: task
    debug: false
    definitions: filler_inventory|machine_inventory|machine_name|upgrade_amount
    script:
        - define machine_slot <[machine_inventory].find_imperfect[<[machine_name]>]>
        - if <[machine_slot]> != -1:
            - if <[upgrade_amount]> > 0:
                - repeat <[upgrade_amount]>:
                    - if <[machine_inventory].find_imperfect[<[machine_name]>_T<[value]>]> != -1:
                        - define machine_data <script[<[machine_name]>_Data].data_key[<[machine_name]>_Upgrade_<[value]>]>
                        - foreach <[machine_data].get[required_items].keys> as:machine_item:
                            - define item_quantity <[machine_data].get[required_items].get[<[machine_item]>]>
                            - if <script[<[machine_item]>]||null> == null:
                                - if !<[filler_inventory].contains[<[machine_item]>].quantity[<[item_quantity]>]>:
                                    - foreach next
                                - take material:<[machine_item]> from:<[filler_inventory]> quantity:<[item_quantity]>
                            - else:
                                - if !<[filler_inventory].contains[<[machine_item]>].quantity[<[item_quantity]>]>:
                                    - foreach next
                                - take <[machine_item]> from:<[filler_inventory]> quantity:<[item_quantity]>
                            - give <[machine_item]> to:<[machine_inventory]> quantity:<[item_quantity]>
                            - narrate "<green> Machine filled. You lost <red><[item_quantity]> <[machine_item]>."
            - define machine_default_data <script[<[machine_name]>_Data].data_key[<[machine_name]>_Default]>
            - foreach <[machine_default_data].get[required_items].keys> as:machine_item:
                - define item_quantity <[machine_default_data].get[required_items].get[<[machine_item]>]>
                - if <script[<[machine_item]>]||null> == null:
                    - if !<[filler_inventory].contains.material[<[machine_item]>].quantity[<[item_quantity]>]>:
                        - foreach next
                    - take material:<[machine_item]> from:<[filler_inventory]> quantity:<[item_quantity]>
                - else:
                    - if !<[filler_inventory].contains[<[machine_item]>].quantity[<[item_quantity]>]>:
                        - foreach next
                    - take <[machine_item]> from:<[filler_inventory]> quantity:<[item_quantity]>
                - give <[machine_item]> to:<[machine_inventory]> quantity:<[item_quantity]>
                - narrate "<green> Machine filled. You lost <red><[item_quantity]> <[machine_item]>."

Security_Machine_Task:
    type: task
    debug: false
    definitions: machine_slot
    script:
        - if <[machine_slot]> != -1 && !<player.is_op>:
            - define owner <player[<context.location.inventory.slot[<[machine_slot]>].lore.filter[starts_with[owner:]].first.after[owner:]>]>
            - if !<[owner].uuid.contains_all_case_sensitive_text[<player.uuid>]>:
                - if !<[owner].has_flag[trusted_players]>:
                    - determine cancelled
                - if <[owner].flag[trusted_players].find[<player.uuid>]> == -1:
                    - determine cancelled

Filter_Machine_Task:
    type: task
    debug: false
    definitions: machine_name|machine_inventory|item_to_filter
    script:
        - if <[machine_inventory].find_imperfect[<[machine_name]>]> != -1:
            - define machine_default_data <script[<[machine_name]>_Data].data_key[<[machine_name]>_Default]>
            - define required_items <[machine_default_data].get[required_items].keys>
            - if <[item_to_filter].has_script>:
                - if <[required_items].find[<[item_to_filter].script.name>]> == -1:
                    - take <[item_to_filter]> from:<[machine_inventory]>
            - else:
                - if <[required_items].find[<[item_to_filter].material.name>]> == -1:
                    - take <[item_to_filter]> from:<[machine_inventory]>
