# +----------------------
# |
# | BLOCK SECURITY
# |
# | Protect your blocks.
# |
# +----------------------
#
# @author devnodachi
# @date 2020/08/02
# @denizen-build REL-1714
# @dependency mcmonkey/cuboid_tool
#
# Commands
# /blocksecurity create <name>
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
                - determine <list[create|delete|list]>
            - case 1:
                - if "!<context.raw_args.ends_with[ ]>":
                    - determine <list[create|delete|list].filter[starts_with[<context.args.first>]]>
    script:
    - if !<player.is_op||<context.server>>:
        - narrate "<red>You do not have permission for that command."
        - stop
    - if <context.args.size> < 2:
        - goto syntax_error
    - define action <context.args.get[1]>
    - define value <context.args.get[2]>
    - if <[action]> == list:
        - run List_Task_Script def:server|block_security_regions|Region|<[value]>|false
        - stop
    - if <[action]> == create:
        - if !<player.has_flag[ctool_selection]>:
            - narrate "<red> ERROR: You don't have any region selected."
            - stop
        - if <[value].contains_all_text[region]>:
            - narrate "<red> ERROR: Don't use region in the name of the block security region"
            - stop
        - if <server.has_flag[block_security_regions]>:
            - foreach <server.flag[block_security_regions]> as:region:
                - if <player.flag[ctool_selection].as_cuboid.intersects[<cuboid[<[region]>]>]>:
                    - narrate "<red> ERROR: Your region conflicts with other region. Try to change the location of your region."
                    - stop
        - note <player.flag[ctool_selection]> as:region_<[value]>
        - flag server block_security_regions:|:region_<[value]>
        - inject cuboid_tool_status_task
        - narrate "<green>Block Security Region <aqua><[value]><green> added with <[message]>."
        - flag <player> ctool_selection:!
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
    - narrate "<yellow>#<red> ERROR: Syntax error. Follow the command syntax:"
    - narrate "<yellow>-<white> To create a block security region: /blocksecurity create <yellow>name"
    - narrate "<yellow>-<white> To delete a block security region: /blocksecurity delete <yellow>name"
    - narrate "<yellow>-<white> To list the block security regions: /blocksecurity list"
    
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
            - if !<player.is_op> && <context.location.material.item.has_inventory>:
                - determine cancelled