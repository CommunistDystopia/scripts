# +----------------------
# |
# | TOWNJAIL
# |
# +----------------------
#
# @author devnodachi
# @date 2020/10/01
# @denizen-build REL-1714
# @dependency TownyAdvanced/Towny
#

Command_AdminTownJail:
    type: command
    debug: false
    name: atownjail
    description: Minecraft Towny Jail system.
    usage: /atownjail
    permission: townjail.all
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
        - define args_used 1
        - inject TownJail_Task

Command_TownJail:
    type: command
    debug: false
    name: townjail
    description: Minecraft Towny Jail system.
    usage: /townjail
    tab complete:
        - choose <context.args.size>:
            - case 0:
                - determine <list[check|set|spawn|remove]>
            - case 1:
                - if "!<context.raw_args.ends_with[ ]>":
                    - determine <list[check|set|spawn|remove].filter[starts_with[<context.args.first>]]>
    permission: townjail.town;townjail.all
    script:
        - if !<player.has_town>:
            - narrate "<red> ERROR: <white>You need to be in a Town to use this command."
            - stop
        - define town <player.town.name>
        - define args_used 0
        - inject TownJail_Task

TownJail_Task:
    type: task
    debug: false
    script:
        - define action <context.args.get[<[args_used].add[1]>]>
        - if <[action]> == check:
            - if <cuboid[<[town]>_townjail]||null> != null:
                - ~run cuboid_show_task def:<cuboid[<[town]>_townjail]>
            - else:
                - narrate "<red> ERROR: <white>The jail of the town <yellow><[town]> <white>does not have an area set"
                - narrate "<white> Use <yellow>/townjail set <white>while selecting with <yellow>/ctool"
            - if <location[<[town]>_townjail_spawn]||null> != null:
                - narrate "<white> The spawn of the jail <yellow><[town]> <white>is located at <yellow>X: <location[<[town]>_border_jail_spawn].x.round_to[0]>, Y: <location[<[town]>_border_jail_spawn].y.round_to[0]>, Z: <location[<[town]>_border_jail_spawn].z.round_to[0]>"
            - else:
                - narrate "<red> ERROR: <white>The jail of the town <yellow><[town]> <white>does not have a spawn point set"
                - narrate "<white> Use <yellow>/townjail spawn <white>while standing inside the area of the jail"
            - stop
        - if <[action]> == set:
            - if !<player.has_permission[cuboidtool.ctool]>:
                - narrate "<red> ERROR: <white>You need the permission cuboidtool.ctool to set the jail of your town!"
                - narrate "<white> Open a ticket in Discord with this information."
                - stop
            - if !<player.has_flag[ctool_selection]>:
                - narrate "<red> ERROR: You don't have any region selected."
                - stop
            - define ctool_chunks_cuboid <player.flag[ctool_selection].as_cuboid.partial_chunks.parse[cuboid]>
            - foreach <[ctool_chunks_cuboid]> as:cuboid:
                - if !<[cuboid].as_cuboid.has_town>:
                    - narrate "<red> ERROR: <white>You can't make a jail in the wilderness!"
                    - stop
                - if <[cuboid].as_cuboid.has_town> && <[cuboid].as_cuboid.list_towns.parse[name].exclude[<[town]>].size> > 0:
                    - narrate "<red> ERROR: <white>Your town should be the only one selected!"
                    - stop
            - note <player.flag[ctool_selection]> as:<[town]>_townjail
            - flag <player> ctool_selection:!
            - if <location[<[town]>_townjail_spawn]||null> != null:
                - note remove as:<[town]>_townjail_spawn
            - narrate "<green> The area of the jail is set."
            - narrate "<white>Do <yellow>/townjail spawn <white>inside the area to set the spawn of the prisoners!"
            - stop
        - if <[action]> == spawn:
            - if <cuboid[<[town]>_townjail]||null> == null:
                - narrate "<red> ERROR: <white>You need to set the area of the jail first."
                - narrate "<white> Do <yellow>/townjail set <white>while selecting with <yellow>/ctool"
                - stop
            - if !<cuboid[<[town]>_townjail].contains_location[<player.location>]>:
                - narrate "<red> ERROR: <white>You should be inside the area of the jail to set the spawn!"
                - narrate "<white> Do <yellow>/townjail check <white>to see the area of the jail"
                - stop
            - note <player.location> as:<[town]>_townjail_spawn
            - narrate "<green> The spawn of prisoners in the jail is set!"
            - stop
        - if <[action]> == remove:
            - if <cuboid[<[town]>_townjail]||null> != null:
                - note remove as:<[town]>_townjail
                - narrate "<green> The area of the town jail has been <red>removed"
            - if <location[<[town]>_townjail_spawn]||null> != null:
                - note remove as:<[town]>_townjail_spawn
                - narrate "<green> The spawn of the town jail has been <red>removed"
            - run TownJail_Destroy_Task def:<[town]>|prisoner
            - run TownJail_Destroy_Task def:<[town]>|chief
            - run TownJail_Destroy_Task def:<[town]>|police
            - run TownJail_Destroy_Task def:<[town]>|wanted
            - narrate "<green> The existing data of the town jail has been <red>removed"
            - stop
        - narrate "<red>ERROR: <white>Syntax error. Follow the command syntax."

TownJail_Destroy_Task:
    type: task
    debug: false
    definitions: town|target
    script:
        - if <server.has_flag[<[town]>_townjail_<[target]>s]>:
            - foreach <server.flag[<[town]>_townjail_<[target]>s]> as:player:
                - if <[target]> == prisoner:
                    - flag <[player].as_player> townjail_prisoner:!
                    - flag <[player].as_player> townjail_prisoner_timer:!
                - if <[target]> == chief || <[target]> == police:
                    - group remove <[target]> player:<[player]>
                - if <[player].as_player.is_online>:
                    - narrate "<yellow>[<[town]>] <white>The town jail has been <red>removed<white>. You are removed from <yellow><[target]>" targets:<[player]>
            - flag server <[town]>_townjail_<[target]>s:!
