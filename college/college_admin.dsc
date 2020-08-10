# +----------------------
# |
# | COLLEGE [ADMIN]
# |
# | Setup for the college
# |
# +----------------------
#
# @author devnodachi
# @date 2020/08/10
# @denizen-build REL-1714
# @dependency devnodachi/college mcmonkey/cuboid_tool
#
# Commands
# /admincollege [exam] set spawn - Sets the place where the student spawn if they fail a test.
# /admincollege [exam] set stage spawn [#] - Sets the place where the student spawn in each stage.
# /admincollege [exam] set stage zone [#] - Sets the zone with /ctool as the Anti-teleport zone
# /admincollege [exam] set custom places - Show a clickable list of places [location].
# /admincollege [exam] set custom zones - Show a clickable list of zones [cuboid].

Command_Admin_College:
    type: command
    debug: false
    name: admincollege
    description: Minecraft [Admin] College system.
    usage: /admincollege
    aliases:
        - acollege
    script:
        - if !<player.is_op||<context.server>>:
            - narrate "<red>You do not have permission for that command."
            - stop
        - if <context.args.size> < 3:
            - narrate "<yellow>#<red> ERROR: Not enough arguments. Follow the command syntax."
            - stop
        - define exam <context.args.get[1]>
        - define action <context.args.get[2]>
        - define target <context.args.get[3]>
        - define dev_data <script[College_Config_Dev]||null>
        - define data <script[<[exam]>_Exam_Data]||null>
        - if <[dev_data]> == null:
            - narrate "ERROR: Developer data missing. Contact the developer."
            - stop
        - if <[data]> == null:
            - narrate "<red> ERROR: This exam doesn't exist."
            - narrate " The first line in your config file should be <red><[exam].to_titlecase>_Exam_Data"
            - stop
        - if <[action]> == set:
            - if <[target]> == spawn:
                - note <player.location> as:<[exam]>_college_spawn
                - narrate "<green> SUCCESS: The place where you're standing is the new spawn for the <[exam]> in the college"
                - narrate "<white> To change it, run the command again."
                - stop
            - if <[target]> == stage:
                - if <context.args.size> < 5:
                    - narrate "<yellow>#<red> ERROR: Not enough arguments. Follow the command syntax."
                    - stop
                - define secondary_target <context.args.get[4]>
                - define stage_number <context.args.get[5]>
                - if <[stage_number]> > <[data].data_key[stages_config].size>:
                    - narrate "<red> ERROR: The value is higher than the highest stage number. Please try a lower value."
                    - stop
                - if <[secondary_target]> == spawn:
                    - note <player.location> as:<[exam]>_stage_<[stage_number]>_spawn
                    - narrate "<green> SUCCESS: The place where you're standing is the new spawn for the <[exam]> stage <[stage_number]>"
                    - narrate "<white> To change it, run the command again."
                    - stop
                - if <[secondary_target]> == zone:
                    - if !<player.has_flag[ctool_selection]>:
                        - narrate "<red> ERROR: You don't have any zone selected."
                        - narrate "<white> Use <red>/ctool <white>to select one"
                        - stop
                    - note <player.flag[ctool_selection]> as:<[exam]>_stage_<[stage_nuber]>_player_zone
                    - inject cuboid_tool_status_task
                    - narrate "<green> SUCCESS: The selection has been set as the Anti-Teleport zone for the <[exam]> stage <[stage_number]>"
                    - flag <player> ctool_selection:!
                    - stop
            - if <[target]> == custom:
                - if <context.args.size> < 4:
                    - narrate "<yellow>#<red> ERROR: Not enough arguments. Follow the command syntax."
                    - stop
                - define secondary_target <context.args.get[4]>
                - if <[secondary_target]> == places:
                    - define custom_locations <[dev_data].data_key[custom_locations].keys.filter[starts_with[<[exam]>_]]>
                    - if <[custom_locations].size> < 1:
                        - narrate "<red> ERROR: The exam doesn't have any custom places"
                        - stop
                    - narrate "<red> # <[exam].to_titlecase> <green>Custom <yellow>Places <red>[Location]:"
                    - narrate "<red> -> <yellow>CLICK <green>a <yellow>PLACE <green>to configure it"
                    - narrate "<red> -> <green>The <yellow>PLACE <green>where you are <yellow>STANDING <green>will be saved"
                    - narrate "<red> -> <green>[SET] = READY <white>- <red>[UNSET] = NOT READY"
                    - narrate "<red> =========================="
                    - foreach <[custom_locations]> as:custom_location:
                        - define location <[custom_location].after[soldier_]>
                        - define isSet <location[<[dev_data].data_key[custom_locations].get[<[custom_location]>]>]||null>
                        - if <[isSet]> != null:
                            - narrate " <element[<white><[loop_index]>. <yellow><[location].to_titlecase> <green>[SET]].on_click[/customcollege <[exam]> location <[custom_location]>]>"
                        - else:
                            - narrate " <element[<white><[loop_index]>. <yellow><[location].to_titlecase> <red>[NOT SET]].on_click[/customcollege <[exam]> location <[custom_location]>]>"
                        - narrate "<red> =========================="
                    - stop
                - if <[secondary_target]> == zones:
                    - define custom_cuboids <[dev_data].data_key[custom_cuboids].keys.filter[starts_with[<[exam]>_]]>
                    - if <[custom_cuboids].size> < 1:
                        - narrate "<red> ERROR: The exam doesn't have any custom zones"
                        - stop
                    - narrate "<red> # <[exam].to_titlecase>: <green>Custom <yellow>Zones <red>[Cuboid]:"
                    - narrate "<red> -> <yellow>CLICK <green>a <yellow>ZONE <green>to configure it"
                    - narrate "<red> -> <green>Be sure to have something selected with <yellow>/ctool"
                    - narrate "<red> -> <green>[SET] = READY <white>- <red>[UNSET] = NOT READY"
                    - narrate "<red> =========================="
                    - foreach <[custom_cuboids]> as:custom_cuboid:
                        - define cuboid <[custom_cuboid].after[soldier_]>
                        - define isSet <cuboid[<[dev_data].data_key[custom_cuboids].get[<[custom_cuboid]>]>]||null>
                        - if <[isSet]> != null:
                            - narrate " <element[<white><[loop_index]>. <yellow><[cuboid].to_titlecase> <green>[SET]].on_click[/customcollege <[exam]> cuboid <[custom_cuboid]>]>"
                        - else:
                            - narrate " <element[<white><[loop_index]>. <yellow><[cuboid].to_titlecase> <red>[NOT SET]].on_click[/customcollege <[exam]> cuboid <[custom_cuboid]>]>"
                        - narrate "<red> =========================="
                    - stop
        - narrate "<yellow>#<red> ERROR: Syntax error. Follow the command syntax:"

Command_Custom_College:
    type: command
    debug: false
    name: customcollege
    description: Minecraft [Custom] [Admin] College system.
    usage: /customcollege
    script:
        - if !<player.is_op||<context.server>>:
            - narrate "<red>You do not have permission for that command."
            - stop
        - if <context.args.size> < 3:
            - narrate "<yellow>#<red> ERROR: Not enough arguments. Follow the command syntax."
            - stop
        - define exam <context.args.get[1]>
        - define notable_type <context.args.get[2]>
        - define key <context.args.get[3]>
        - define dev_data <script[College_Config_Dev]||null>
        - if <[dev_data]> == null:
            - narrate "ERROR: Developer data missing. Contact the developer."
            - stop
        - define notable_name <[dev_data].data_key[custom_<[notable_type]>s].get[<[key]>]>
        - if <[notable_type]> == location:
            - note <player.location> as:<[notable_name]>
            - narrate "<white> Custom PLACE [Location]: <red><[key].after[<[exam]>_]> <green>[SET]"
            - stop
        - if <[notable_type]> == cuboid:
            - if !<player.has_flag[ctool_selection]>:
                - narrate "<red> ERROR: You don't have any zone selected."
                - narrate "<white> Use <red>/ctool <white>to select one"
                - stop
            - note <player.flag[ctool_selection]> as:<[notable_name]>
            - inject cuboid_tool_status_task
            - narrate "<white> Custom ZONE [Cuboid]: <red><[key].after[<[exam]>_]> <green>[SET]"
            - flag <player> ctool_selection:!
            - stop
        - narrate "<yellow>#<red> ERROR: Syntax error. Follow the command syntax:"
