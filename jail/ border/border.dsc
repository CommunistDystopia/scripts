# +----------------------
# |
# | BORDER
# |
# +----------------------
#
# @author devnodachi
# @date 2020/10/01
# @denizen-build REL-1714
# @dependency TownyAdvanced/Towny blocks/block_security
#

Command_Border:
    type: command
    debug: false
    name: border
    description: Minecraft Towny Border Jail system.
    usage: /border
    tab complete:
        - choose <context.args.size>:
            - case 0:
                - determine <list[set|spawn|remove|jail]>
            - case 1:
                - if "!<context.raw_args.ends_with[ ]>":
                    - determine <list[set|spawn|remove|jail].filter[starts_with[<context.args.first>]]>
                - else:
                    - if <context.args.get[1]> == jail:
                        - determine <list[set|spawn|check]>
    permission: border.all
    script:
        - if <context.args.size> < 2:
            - narrate "<red>ERROR: <white>ERROR: Not enough arguments. Follow the command syntax."
            - stop
        - define town 0
        - if !<context.server>:
            - if <town[<context.args.get[1]>]||null> == null:
                - narrate "<red> ERROR: <white>The town name is invalid."
                - stop
            - define town <context.args.get[1]>
        - else:
            - define town <context.args.get[1]>
        - define action <context.args.get[2]>
        - if <[action]> == set:
            - if <context.args.size> < 3:
                - narrate "<red>ERROR: <white>ERROR: Not enough arguments. Follow the command syntax."
                - stop
            - define blocksec <context.args.get[3]>
            - if <cuboid[region_<[blocksec]>]||null> == null:
                - narrate "<red> ERROR: <white>You should provide the name of a block security region!"
                - narrate "<white> Do <yellow>/blocksec list <white>to check the names of the regions"
                - stop
            - flag server <[town]>_border:region_<[blocksec]>
            - narrate "<green> The area has been marked as a town border of the town <yellow><[town]>"
            - narrate "<white> Do <yellow>/border [town] spawn <white>inside the area to set the spawn of the border"
            - stop
        - if <[action]> == remove:
            - if !<server.has_flag[<[town]>_border]>:
                - narrate "<red> ERROR: <white>The town doesn't have a border set!"
                - stop
            - flag server <[town]>_border:!
            - if <location[<[town]>_border_spawn]||null> != null:
                - note remove as:<[town]>_border_spawn
            - if <cuboid[<[town]>_border_jail]||null> != null:
                - note remove as:<[town]>_border_jail
                - if <server.has_flag[<[town]>_border_jail_wanteds]>:
                    - flag server <[town]>_border_jail_wanteds:!
            - if <location[<[town]>_border_jail_spawn]||null> != null:
                - note remove as:<[town]>_border_jail_spawn
            - run Border_Destroy_Task def:<[town]>|prisoner
            - run Border_Destroy_Task def:<[town]>|border
            - narrate "<red> The data of the town border has been removed..."
            - stop
        - if !<server.has_flag[<[town]>_border]>:
            - narrate "<red> ERROR: <white>You should mark a block security region as a border!"
            - narrate "<white> Do <yellow>/border [town] set [region_name] <white>to mark it"
            - stop
        - define border_region <cuboid[<server.flag[<[town]>_border]>]||null>
        - if <[border_region]> == null:
            - narrate "<red> ERROR: <white>The block security region has been deleted."
            - narrate "<red> Deleting town border mark..."
            - flag server <[town]>_border:!
            - stop
        - if <[action]> == spawn:
            - if !<[border_region].contains_location[<player.location>]>:
                - narrate "<red> ERROR: <white>You should stand inside the area of the region to set the spawn!"
                - narrate "<white> Do <yellow>/blocksec check [region_name] <white>to check the area of the border marked"
                - stop
            - note <player.location> as:<[town]>_border_spawn
            - narrate "<green> Your location has been marked as the spawn of the border!"
            - narrate "<white> Do <yellow>/border [town] jail set <white>with <yellow>/ctool <white>to mark the jail area"
            - stop
        - if <[action]> == jail:
            - if <context.args.size> < 3:
                - narrate "<red> ERROR: <white>ERROR: Not enough arguments. Follow the command syntax."
                - stop
            - define secondary_action <context.args.get[3]>
            - if <[secondary_action]> == set:
                - if !<player.has_flag[ctool_selection]>:
                    - narrate "<red> ERROR: You don't have any region selected."
                    - stop
                - define ctool_cuboid <player.flag[ctool_selection].as_cuboid>
                - if !<[ctool_cuboid].is_within[<[border_region]>]>:
                    - narrate "<red> ERROR: <white>Your selection should be inside the border!"
                    - stop
                - note <[ctool_cuboid]> as:<[town]>_border_jail
                - narrate "<green> The area has been marked as the jail of the border!"
                - narrate "<white> Do <yellow>/border [town] jail spawn <white>inside the jail area to set the spawn of prisoner"
                - stop
            - if <[secondary_action]> == spawn:
                - if <cuboid[<[town]>_border_jail]||null> == null:
                    - narrate "<red>ERROR: <white>You should set the area of the jail first!"
                    - narrate "<white> Do <yellow>/border [town] jail <white>with <yellow>/ctool <white>to set the jail area"
                    - stop
                - if !<cuboid[<[town]>_border_jail].contains_location[<player.location>]>:
                    - narrate "<red> ERROR: <white>You should stand inside the area of the jail region to set the spawn!"
                    - stop
                - note <player.location> as:<[town]>_border_jail_spawn
                - narrate "<green> Your location has been marked as the spawn of the border jail!"
                - stop
            - if <[secondary_action]> == check:
                - if <cuboid[<[town]>_border_jail]||null> != null:
                    - ~run cuboid_show_task def:<cuboid[<[town]>_border_jail]>
                - else:
                    - narrate "<red> ERROR: <white>The jail of the border <yellow><[town]> <white>does not have an area set"
                    - narrate "<white> Use <yellow>/border [town] jail set <white>while selecting with <yellow>/ctool"
                - if <location[<[town]>_border_jail_spawn]||null> != null:
                    - narrate "<white> The spawn of the jail <yellow><[town]> <white>is located at <yellow>X: <location[<[town]>_border_jail_spawn].x.round_to[0]>, Y: <location[<[town]>_border_jail_spawn].y.round_to[0]>, Z: <location[<[town]>_border_jail_spawn].z.round_to[0]>"
                - else:
                    - narrate "<red> ERROR: <white>The jail of the border <yellow><[town]> <white>does not have a spawn point set"
                    - narrate "<white> Use <yellow>/border [town] jail spawn <white>while standing inside the area of the jail"
                - stop
        - narrate "<red>ERROR: <white>ERROR: Syntax error. Follow the command syntax."

Border_Destroy_Task:
    type: task
    debug: false
    definitions: town|target
    script:
        - if <server.has_flag[<[town]>_border_<[target]>s]>:
            - foreach <server.flag[<[town]>_border_<[target]>s]> as:player:
                - if <[target]> == prisoner:
                    - flag <[player].as_player> border_prisoner:!
                    - flag <[player].as_player> border_prisoner_timer:!
                - if <[target]> == border:
                    - group remove <[target]> player:<[player]>
                - if <[player].as_player.is_online>:
                    - narrate "<yellow>[<[town]>] <white>The town border has been <red>removed<white>. You are removed from <yellow><[target]> officers" targets:<[player]>
            - flag server <[town]>_border_<[target]>s:!

Border_Script:
    type: world
    debug: false
    events:
        on player dies in:region_*:
            - if !<player.has_flag[prisoner_timer]> && !<player.has_flag[border_prisoner]> && !<player.has_flag[border_prisoner]> && <player.has_town> && <server.has_flag[<player.town.name>_towborder]>:
                - if <context.location.cuboids.parse[name].filter[contains_text[<server.flag[<player.town.name>_towborder]>]].size> == 1:
                    - flag <player> border_spawn:true
        after player respawns priority:2:
            - if <player.has_flag[border_spawn]>:
                - flag <player> border_spawn:!
                - if !<player.has_town> || <player.has_flag[prisoner_timer]> || <player.has_flag[border_prisoner]> || <player.has_flag[border_prisoner]>:
                    - stop
                - if <location[<player.town.name>_towborder_spawn]||null> != null:
                    - teleport <player> <location[<player.town.name>_towborder_spawn]>