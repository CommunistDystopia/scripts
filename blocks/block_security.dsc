# +----------------------
# |
# | BLOCK SECURITY
# |
# +----------------------
#
# @author devnodachi
# @date 2020/08/02
# @denizen-build REL-1714
# @dependency mcmonkey/cuboid_tool
#
# Commands
# /blocksecurity <name>
# After selecting with the cuboid tool, save the region with this name.
# The region will be protected from block break/place.
# And the containers within the region can't be opened.
#

Region_Command:
    type: command
    debug: false
    name: blocksecurity
    aliases:
    - blocksec
    description: Saves your selected region.
    usage: /blocksecurity [name]
    script:
    - if !<player.is_op>:
        - narrate "<red>You do not have permission for that command."
        - stop
    - if !<player.has_flag[ctool_selection]>:
        - narrate "<red>You don't have any region selected."
        - stop
    - if <context.args.size> != 1:
        - narrate "/region [name]"
        - stop
    - if <context.args.get[1].contains_all_text[region]>:
        - narrate "<red> Don't use region in the name of the region"
        - stop
    - note <player.flag[ctool_selection]> as:region_<context.args.get[1]>
    - inject cuboid_tool_status_task
    - narrate "<green>Region <aqua><context.args.get[1]><green> noted with <[message]>."
    - flag <player> ctool_selection:!

Region_Script:
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
            - if !<player.is_op> && <context.item.has_inventory>:
                - determine cancelled