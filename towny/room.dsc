# +----------------------
# |
# | TOWNROOMS
# |
# | Rooms in Towny towns.
# |
# +----------------------
#
# @author devnodachi
# @date 2020/09/21
# @denizen-build REL-1714
# @dependency TownyAdvanced/Towny
#
# - Notables
# [TownName]_Rooms_[RoomName]
# - Flags
# [TownName]_Rooms - Rooms of a Town.
# [TownName]_Rooms_[RoomName] - Information about the players in the room.
# [TownName]_Rooms_Tax - The tax of a town.
# [TownName]_Rooms_[RoomName]_Tax - The tax of a room.
# - Commands
# /townrooms create [room_name] - Selected with ctool
# /townrooms delete [room_name]
# /townrooms tax (room_name) [amount]
# /townrooms set [room_name] [username]
# /townrooms kick [room_name] [username]
# /townrooms info [room_name] - List all the players living in that room.
# /townrooms list - List all the rooms in a town.
# ---
# () = optional
# [] = required

Command_AdminTownRoom:
    type: command
    debug: false
    name: atownrooms
    description: Clean data from Landmines and Block Security.
    usage: /atownrooms
    tab complete:
        - choose <context.args.size>:
            - case 0:
                - determine <list[list|tax|create|delete|set|kick|info]>
            - case 1:
                - if "!<context.raw_args.ends_with[ ]>":
                    - determine <list[list|tax|create|delete|set|kick|info].filter[starts_with[<context.args.first>]]>
    permission: townroom.all
    aliases:
        - atrooms
    script:
        - if <context.args.size> < 2:
            - narrate "<red>ERROR: <white>ERROR: Not enough arguments. Follow the command syntax."
            - stop
        - define town <context.args.get[1]>
        - if <town[<[town]>]||null> == null:
            - narrate "<red> ERROR: <white>The name of the Town is invalid."
            - stop
        - define action <context.args.get[2]>
        - define args_used:1
        - inject TownRoom_Task_Script

Command_TownRoom:
    type: command
    debug: false
    name: townrooms
    description: Clean data from Landmines and Block Security.
    usage: /townrooms
    tab complete:
        - if <player.has_town>:
            - define rooms <empty>
            - if <server.has_flag[<player.town.name>_rooms]>:
                - define rooms <server.flag[<player.town.name>_rooms].parse[after[<player.town.name>_rooms_]]>
            - choose <context.args.size>:
                - case 0:
                    - determine <list[list|tax|create|delete|set|kick|info]>
                - case 1:
                    - if "!<context.raw_args.ends_with[ ]>":
                        - determine <list[list|tax|create|delete|set|kick|info].filter[starts_with[<context.args.first>]]>
                    - else:
                        - if <context.args.get[1]> == list:
                            - determine 0
                        - if <context.args.get[1]> == tax:
                            - determine <list[0].include[<[rooms]>]>
                        - if <context.args.get[1].contains_any[delete|set|kick|info]>:
                            - determine <[rooms]>
                - case 2:
                    - if "!<context.raw_args.ends_with[ ]>":
                        - if <context.args.get[1]> == list:
                            - determine 0
                        - if <context.args.get[1]> == tax:
                            - determine <list[0].include[<[rooms]>]>
                        - if <context.args.get[1].contains_any[delete|set|kick|info]>:
                            - determine <[rooms]>
                    - else:
                        - determine <server.online_players.parse[name]>
    permission: townroom.town
    aliases:
        - trooms
    script:
        - if <context.args.size> < 1:
            - narrate "<red>ERROR: <white>ERROR: Not enough arguments. Follow the command syntax."
            - stop
        - define action <context.args.get[1]>
        - define town <player.town.name||null>
        - if <[town]> == null:
            - narrate "<red> ERROR: <white>You don't belong to a Town."
            - stop
        - define args_used:0
        - inject TownRoom_Task_Script

TownRoom_Task_Script:
    type: task
    debug: false
    script:
        - if <[action]> == list:
            - if !<server.has_flag[<[town]>_Rooms]>:
                - narrate "<white> The town <yellow><[town]> <white>have <red>0 rooms"
                - stop
            - if <server.flag[<[town]>_Rooms].size> < 10:
                - run List_Task_Script def:server|<[town]>_Rooms|Room|0|false|server|<[town]>_Rooms
            - else:
                - if <context.args.size> < <[args_used].add[2]>:
                    - narrate "<red>ERROR: <white>ERROR: Not enough arguments. Follow the command syntax."
                    - stop
                - define list_page <context.args.get[<[args_used].add[2]>]>
                - run List_Task_Script def:server|<[town]>_Rooms|Room|<[list_page]>|false|server|<[town]>_Rooms
            - stop
        - if <context.args.size> < <[args_used].add[2]>:
            - narrate "<red>ERROR: <white>ERROR: Not enough arguments. Follow the command syntax."
            - stop
        - define target <context.args.get[<[args_used].add[2]>]>
        - if <[action]> == tax:
            - if <context.args.size> == <[args_used].add[2]> && <[target].is_decimal>:
                - flag server <[town]>_Rooms_Tax:<[target]>
                - narrate "<green> The new <yellow>Tax <green>for the rooms in <yellow><[town]> <green>will be <yellow>$<[target]>"
                - stop
            - if <context.args.size> == <[args_used].add[3]>:
                - if <cuboid[<[town]>_Rooms_<[target]>]||null> == null:
                    - narrate "<red> ERROR: <white>The room <yellow><[target]> <white>doesn't exist for the town <yellow><[town]>"
                    - stop
                - define amount <context.args.get[<[args_used].add[3]>]>
                - if <[amount].is_decimal>:
                    - flag server <[town]>_Rooms_<[target]>_Tax:<[amount]>
                    - narrate "<green> The new <yellow>Tax <green>for the room <yellow><[target]> <green>in <yellow><[town]> <green>will be <yellow>$<[amount]>"
                    - stop
        - if <[action]> == create:
            - if !<server.has_flag[<[town]>_Rooms_Tax]>:
                - narrate "<red> ERROR: <white>Please set the default tax of the rooms first with: /townrooms tax [number]"
                - stop
            - if <[target].contains_any[_|prison|jail|region|room|null]>:
                - narrate "<red> ERROR: <white>Invalid room name. To avoid conflicts with other plugins don't use that name."
                - stop
            - if <cuboid[<[town]>_Rooms_<[target]>]||null> != null:
                - narrate "<red> ERROR: <white>The room <yellow><[target]> <white>already exist for the town <yellow><[town]>"
                - stop
            - if !<player.has_flag[ctool_selection]>:
                - narrate "<red> ERROR: <white>You don't have any area selected for the room"
                - stop
            - if !<player.flag[ctool_selection].as_cuboid.has_town>:
                - narrate "<red> ERROR: <white>The area selected doesn't contain the town <[town]>"
                - stop
            - else:
                - if <player.flag[ctool_selection].as_cuboid.list_towns.parse[name].filter[contains_all_text[<[town]>]].size> != 1:
                    - narrate "<red> ERROR: <white>You are selecting multiple towns. Please pick an area within the town <[town]> for the room"
                    - stop
                - else:
                    - if !<player.flag[ctool_selection].as_cuboid.min.has_town> || !<player.flag[ctool_selection].as_cuboid.max.has_town>:
                        - narrate "<red> ERROR: <white>The area selected should contain only the town <[town]>"
                        - stop
            - note <player.flag[ctool_selection]> as:<[town]>_Rooms_<[target]>
            - inject cuboid_tool_status_task
            - flag <player> ctool_selection:!
            - flag server <[town]>_Rooms:|:<[town]>_Rooms_<[target]>
            - narrate "<green> Room <yellow><[target]> <green>setup correctly for the town <yellow><[town]>"
            - stop
        - if <[action]> == delete:
            - if <cuboid[<[town]>_Rooms_<[target]>]||null> == null:
                - narrate "<red> ERROR: <white>The room <yellow><[target]> <white>doesn't exist for the town <yellow><[town]>"
                - stop
            - note remove as:<[town]>_Rooms_<[target]>
            - flag server <[town]>_Rooms_<[target]>:!
            - flag server <[town]>_Rooms_<[target]>_Tax:!
            - flag server <[town]>_Rooms:<-:<[town]>_Rooms_<[target]>
            - narrate "<green> The room <yellow><[target]> <green>has been <red>deleted <green>correctly in the town <yellow><[town]>"
            - stop
        - if <[action].contains_any[set|kick]> && <context.args.size> == <[args_used].add[3]>:
            - if <cuboid[<[town]>_Rooms_<[target]>]||null> == null:
                - narrate "<red> ERROR: <white>The room <yellow><[target]> <white>doesn't exist for the town <yellow><[town]>"
                - stop
            - define username <server.match_offline_player[<context.args.get[<[args_used].add[3]>]>]||null>
            - if <[username]> == null:
                - narrate "<red> ERROR: Invalid player username."
                - stop
            - if <[action]> == set:
                - if <server.has_flag[<[town]>_Rooms_<[target]>]>:
                    - if <server.flag[<[town]>_Rooms_<[target]>].contains[<[username]>]>:
                        - narrate "<red> ERROR: <white>The room <yellow><[target]> <white>already has the player <yellow><[username].name>"
                        - stop
                    - flag server <[town]>_Rooms_<[target]>:|:<[username]>
                - else:
                    - flag server <[town]>_Rooms_<[target]>:|:<[username]>
                - narrate "<green> The player <yellow><[username].name> <green>was added to the room <yellow><[target]> <green>in the town <yellow><[town]>"
            - else:
                - if !<server.has_flag[<[town]>_Rooms_<[target]>]>:
                    - narrate "<red> ERROR: <white>The room <yellow><[target]> <white>doesn't have any players"
                    - stop
                - flag server <[town]>_Rooms_<[target]>:<-:<[username]>
                - narrate "<green> The player <yellow><[username].name> <green>was <red>removed <green>from the room <yellow><[target]> <green>in the town <yellow><[town]>"
            - stop
        - if <[action]> == info:
            - if <cuboid[<[town]>_Rooms_<[target]>]||null> == null:
                - narrate "<red> ERROR: <white>The room <yellow><[target]> <white>doesn't exist for the town <yellow><[town]>"
                - stop
            - if <server.flag[<[town]>_Rooms_<[target]>].size> < 10:
                - run List_Task_Script def:server|<[town]>_Rooms_<[target]>|Roommate|0|true|Room
            - else:
                - if <context.args.size> < <[args_used].add[3]>:
                    - narrate "<red>ERROR: <white>ERROR: Not enough arguments. Follow the command syntax."
                    - stop
                - define list_page <context.args.get[<[args_used].add[3]>]>
                - run List_Task_Script def:server|<[town]>_Rooms_<[target]>|Roommate|<[list_page]>|true|Room
            - stop
        - narrate "<red>ERROR: <white>ERROR: Syntax error. Follow the command syntax."

TownRoom_Script:
    type: world
    debug: false
    events:
        on player breaks block in:*_Rooms_* bukkit_priority:HIGHEST ignorecancelled:true:
            - if <player.has_town>:
                - foreach <context.location.cuboids.parse[note_name].filter[starts_with[<player.town.name>_]]> as:room:
                    - if <server.has_flag[<[room]>]> && <server.flag[<[room]>].contains[<player>]>:
                        - determine cancelled:false
        after player places block in:*_Rooms_* bukkit_priority:HIGHEST ignorecancelled:true:
            - if <player.has_town>:
                - foreach <context.location.cuboids.parse[note_name].filter[starts_with[<player.town.name>_]]> as:room:
                    - if <server.has_flag[<[room]>]> && <server.flag[<[room]>].contains[<player>]>:
                        - inventory adjust slot:<player.held_item_slot> quantity:<player.inventory.slot[<player.held_item_slot>].quantity.sub[1]>
                        - modifyblock <context.location> <context.material.name>
                        - stop
        on system time hourly every:24:
            - foreach <towny.list_towns> as:town:
                - if <server.has_flag[<[town].name>_rooms]> && <server.has_flag[<[town].name>_rooms_tax]>:
                    - define tax <server.flag[<[town].name>_rooms_tax]>
                    - foreach <server.flag[<[town].name>_rooms]> as:room:
                        - if <server.has_flag[<[room]>]>:
                            - foreach <server.flag[<[room]>]> as:roommate:
                                - if <server.has_flag[<[room]>_tax]>:
                                    - define tax <server.flag[<[room]>_tax]>
                                - if <[roommate].as_player.money> < <[tax]>:
                                    - flag server <[room]>:<-:<[roommate]>
                                    - if <[roommate].is_online>:
                                        - narrate "<red> [Somalia] <white>You were kicked out of your room in <yellow><[town].name> <white>because you don't have enough money to pay the tax." targets:<[roommate].as_player>
                                - else:
                                    - money take quantity:<[tax]> players:<[roommate].as_player>
                                    - if <[roommate].is_online>:
                                        - narrate "<red> [Somalia] <white>You have paid your taxes for your room in <yellow><[town].name><white>. Glory to Somalia!" targets:<[roommate].as_player>

