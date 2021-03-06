# +----------------------
# |
# | BLOCK SECURITY
# |
# | Protect your blocks.
# |
# +----------------------
#
# @author devnodachi
# @date 2020/10/30
# @denizen-build REL-1714
# @dependency mcmonkey/cuboid_tool
#
# Commands
# /blocksecurity create <name>
# /blocksecurity check <name>
# /blocksecurity delete <name>
# /blocksecurity list <#>
# After selecting with the cuboid tool, save the region with this name.
# The region will be protected from block break/place.
# And the containers within the region can't be opened.
#

Block_Security_Command:
    type: command
    debug: false
    name: blocksecurity
    aliases:
    - blocksec
    description: Saves your selected region.
    usage: /blocksecurity [name]
    tab complete:
        - if !<player.is_op||<context.server>>:
            - stop
        - choose <context.args.size>:
            - case 0:
                - determine <list[create|delete|list|check]>
            - case 1:
                - if "!<context.raw_args.ends_with[ ]>":
                    - determine <list[create|delete|list|check].filter[starts_with[<context.args.first>]]>
    script:
    - if !<player.is_op||<context.server>>:
        - narrate "<red>You do not have permission for that command."
        - stop
    - define action <context.args.get[1]>
    - if <[action]> == list:
        - run List_Task_Script def:server|block_security_regions|Region|<context.args.get[2]||null>|false|server|region_
        - stop
    - if <context.args.size> < 2:
        - goto syntax_error
    - define value <context.args.get[2]>
    - if <[action]> == create:
        - if !<player.has_flag[ctool_selection]>:
            - narrate "<red> ERROR: You don't have any region selected."
            - stop
        - if <[value].contains_all_text[region]>:
            - narrate "<red> ERROR: Don't use region in the name of the block security region"
            - stop
        - note <player.flag[ctool_selection]> as:region_<[value]>
        - flag server block_security_regions:|:region_<[value]>
        - inject cuboid_tool_status_task
        - narrate "<green>Block Security Region <aqua><[value]><green> added with <[message]>."
        - flag <player> ctool_selection:!
        - stop
    - if <[action]> == check:
        - if <cuboid[region_<[value]>]||null> == null:
            - narrate "<red> ERROR: That block security region doesn't exist"
            - stop
        - narrate "<green> Loading region data..."
        - ~run cuboid_show_task def:<cuboid[region_<[value]>]>
        - stop
    - if <[action]> == delete:
        - if <cuboid[region_<[value]>]||null> == null:
            - narrate "<red> ERROR: That block security region doesn't exist"
            - stop
        - note remove as:region_<[value]>
        - flag server block_security_regions:<-:region_<[value]>
        - narrate "<green> Block Security Region <red><[value]> <green>removed"
        - stop
    - mark syntax_error
    - narrate "<yellow>#<red> ERROR: Syntax error. Follow the command syntax."

Block_Security_Script:
    type: world
    debug: false
    events:
        on player breaks block in:region_* priority:-1 ignorecancelled:true:
            - if !<player.is_op>:
                - determine cancelled
        on player places block in:region_* priority:-1 ignorecancelled:true:
            - if !<player.is_op>:
                - determine cancelled
        on player right clicks block in:region_* priority:-1 ignorecancelled:true:
            - if <context.click_type> == RIGHT_CLICK_BLOCK && !<player.is_op>:
                - if <context.location.material.name> == CHEST || <context.location.material.name> == BARREL || <context.location.material.name> == DISPENSER || <context.location.material.name> == DROPPER || <context.location.material.name.contains_any_text[SHULKER_BOX]>:
                    - determine cancelled
        on player clicks ARMOR_STAND|ITEM_FRAME in:region_* priority:-1 ignorecancelled:true:
            - if !<player.is_op>:
                - determine cancelled