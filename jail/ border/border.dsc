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
        - if <context.args.size> < 1:
            - narrate "<red>ERROR: <white>ERROR: Not enough arguments. Follow the command syntax."
            - stop
        - define action <context.args.get[1]>
        - if <[action]> == set:
            - if <context.args.size> < 2:
                - narrate "<red>ERROR: <white>ERROR: Not enough arguments. Follow the command syntax."
                - stop
            - define blocksec <context.args.get[2]>
            - if <cuboid[region_<[blocksec]>]||null> == null:
                - narrate "<red> ERROR: <white>You should provide the name of a block security region!"
                - narrate "<white> Do <yellow>/blocksec list <white>to check the names of the regions"
                - stop
            - flag server border:region_<[blocksec]>
            - narrate "<green> The area has been marked as the border"
            - narrate "<white> Do <yellow>/border spawn <white>inside the area to set the spawn of the border"
            - stop
        - if <[action]> == remove:
            - if !<server.has_flag[border]>:
                - narrate "<red> ERROR: <white>The server doesn't have a border set!"
                - stop
            - flag server border:!
            - if <location[border_spawn]||null> != null:
                - note remove as:border_spawn
            - if <cuboid[border_jail]||null> != null:
                - note remove as:border_jail
                - if <server.has_flag[border_jail_wanteds]>:
                    - flag server border_jail_wanteds:!
            - if <location[border_jail_spawn]||null> != null:
                - note remove as:border_jail_spawn
            - run Border_Destroy_Task def:prisoner
            - run Border_Destroy_Task def:border
            - narrate "<red> The data of the server border has been removed..."
            - stop
        - if !<server.has_flag[border]>:
            - narrate "<red> ERROR: <white>You should mark a block security region as a border!"
            - narrate "<white> Do <yellow>/border set [region_name] <white>to mark it"
            - stop
        - define border_region <cuboid[<server.flag[border]>]||null>
        - if <[border_region]> == null:
            - narrate "<red> ERROR: <white>The block security region has been deleted."
            - narrate "<red> Deleting server border mark..."
            - flag server border:!
            - stop
        - if <[action]> == spawn:
            - if !<[border_region].contains_location[<player.location>]>:
                - narrate "<red> ERROR: <white>You should stand inside the area of the region to set the spawn!"
                - narrate "<white> Do <yellow>/blocksec check [region_name] <white>to check the area of the border marked"
                - stop
            - note <player.location> as:border_spawn
            - narrate "<green> Your location has been marked as the spawn of the border!"
            - narrate "<white> Do <yellow>/border jail set <white>with <yellow>/ctool <white>to mark the jail area"
            - stop
        - if <[action]> == jail:
            - if <context.args.size> < 2:
                - narrate "<red> ERROR: <white>ERROR: Not enough arguments. Follow the command syntax."
                - stop
            - define secondary_action <context.args.get[2]>
            - if <[secondary_action]> == set:
                - if !<player.has_flag[ctool_selection]>:
                    - narrate "<red> ERROR: You don't have any region selected."
                    - stop
                - define ctool_cuboid <player.flag[ctool_selection].as_cuboid>
                - if !<[ctool_cuboid].is_within[<[border_region]>]>:
                    - narrate "<red> ERROR: <white>Your selection should be inside the border!"
                    - stop
                - note <[ctool_cuboid]> as:border_jail
                - narrate "<green> The area has been marked as the jail of the border!"
                - narrate "<white> Do <yellow>/border jail spawn <white>inside the jail area to set the spawn of prisoner"
                - stop
            - if <[secondary_action]> == spawn:
                - if <cuboid[border_jail]||null> == null:
                    - narrate "<red>ERROR: <white>You should set the area of the jail first!"
                    - narrate "<white> Do <yellow>/border jail <white>with <yellow>/ctool <white>to set the jail area"
                    - stop
                - if !<cuboid[border_jail].contains_location[<player.location>]>:
                    - narrate "<red> ERROR: <white>You should stand inside the area of the jail region to set the spawn!"
                    - stop
                - note <player.location> as:border_jail_spawn
                - narrate "<green> Your location has been marked as the spawn of the border jail!"
                - stop
            - if <[secondary_action]> == check:
                - if <cuboid[border_jail]||null> != null:
                    - ~run cuboid_show_task def:<cuboid[border_jail]>
                - else:
                    - narrate "<red> ERROR: <white>The jail of the border <white>does not have an area set"
                    - narrate "<white> Use <yellow>/border jail set <white>while selecting with <yellow>/ctool"
                - if <location[border_jail_spawn]||null> != null:
                    - narrate "<white> The spawn of the jail <white>is located at <yellow>X: <location[border_jail_spawn].x.round_to[0]>, Y: <location[border_jail_spawn].y.round_to[0]>, Z: <location[border_jail_spawn].z.round_to[0]>"
                - else:
                    - narrate "<red> ERROR: <white>The jail of the border <white>does not have a spawn point set"
                    - narrate "<white> Use <yellow>/border jail spawn <white>while standing inside the area of the jail"
                - stop
        - narrate "<red>ERROR: <white>ERROR: Syntax error. Follow the command syntax."

Border_Destroy_Task:
    type: task
    debug: false
    definitions: target
    script:
        - if <server.has_flag[border_<[target]>s]>:
            - foreach <server.flag[border_<[target]>s]> as:player:
                - if <[target]> == prisoner:
                    - flag <[player].as_player> border_prisoner:!
                    - flag <[player].as_player> border_prisoner_timer:!
                - if <[target]> == border:
                    - group remove <[target]> player:<[player]>
                - if <[player].as_player.is_online>:
                    - narrate "<yellow>[Border] <white>The border has been <red>removed<white>. You are removed from <yellow><[target]> officers" targets:<[player]>
            - flag server border_<[target]>s:!

Border_Script:
    type: world
    debug: false
    events:
        on player dies in:region_*:
            - if <server.has_flag[border]> &&  !<player.has_flag[prisoner_timer]> && !<player.has_flag[towjail_prisoner]> && !<player.has_flag[border_prisoner]>:
                - if <context.entity.location.cuboids.parse[note_name].filter[contains_text[<server.flag[border]>]].size> == 1:
                    - flag <player> border_spawn:true
        after player respawns priority:2:
            - if <player.has_flag[border_spawn]>:
                - flag <player> border_spawn:!
                - if <player.has_flag[prisoner_timer]> || <player.has_flag[towjail_prisoner]> || <player.has_flag[border_prisoner]>:
                    - stop
                - if <location[border_spawn]||null> != null:
                    - teleport <player> <location[border_spawn]>