# +----------------------
# |
# | TOWNPRISONER
# |
# +----------------------
#
# @author devnodachi
# @date 2020/10/01
# @denizen-build REL-1714
# @dependency TownyAdvanced/Towny
#

Command_AdminTownPrisoner:
    type: command
    debug: false
    name: atownprisoner
    description: Minecraft Towny Jail [Prisoner] system.
    usage: /atownprisoner
    permission: townjail.townprisoner.all
    script:
        - if <context.args.size> < 2:
            - narrate "<red>ERROR: <white>ERROR: Not enough arguments. Follow the command syntax."
            - stop
        - if <town[<context.args.get[1]>]||null> == null:
            - narrate "<red> ERROR: <white>The town name is invalid."
            - stop
        - define town <context.args.get[1]>
        - define args_used 1
        - inject TownPrisoner_Task

Command_TownPrisoner:
    type: command
    debug: false
    name: townprisoner
    description: Minecraft Towny Jail [Prisoner] system.
    usage: /townprisoner
    tab complete:
        - if <player.has_town>:
            - choose <context.args.size>:
                - case 0:
                    - determine <list[list|remove]>
                - case 1:
                    - if "!<context.raw_args.ends_with[ ]>":
                        - determine <list[list|remove].filter[starts_with[<context.args.first>]]>
                    - else:
                        - if <context.args.get[1]> == list:
                            - determine 0
                        - if <context.args.get[1]> == remove:
                            - determine <server.online_players.parse[name]>
    permission: townjail.townprisoner.town;townjail.townprisoner.all
    script:
        - if !<player.has_town>:
            - narrate "<red> ERROR: <white>You need to be in a Town to use this command."
            - stop
        - define town <player.town.name>
        - define args_used 0
        - inject TownPrisoner_Task

TownPrisoner_Task:
    type: task
    debug: false
    script:
        - define action <context.args.get[<[args_used].add[1]>]>
        - if <[action]> == list:
            - run List_Task_Script def:server|<[town]>_townjail_prisoners|Prisoner|<context.args.get[<[args_used].add[3]>]||null>|true|Town
            - stop
        - if <context.args.size> < <[args_used].add[2]>:
            - narrate "<red>ERROR: <white>ERROR: Not enough arguments. Follow the command syntax."
            - stop
        - define username <server.match_offline_player[<context.args.get[<[args_used].add[2]>]>]||null>
        - if <[username]> == null:
            - narrate "<red> ERROR: <white>Invalid player username."
            - stop
        - if <[action]> == remove:
            - if !<[username].has_flag[townjail_prisoner]> || <[username].flag[townjail_prisoner]> != <[town]>:
                - narrate "The player is not a prisoner of the town"
                - stop
            - flag server <[town]>_townjail_prisoners:<-:<[username]>
            - flag <[username]> townjail_prisoner:!
            - flag <[username]> townjail_prisoner_timer:!
            - narrate "<green> Prisoner <yellow><[username].name> <red>removed <green>from the jail of the town <yellow><[town]>"
            - if <[username].is_online>:
                - narrate "<yellow>[<[town]>] <white>You are free of the jail!" targets:<[username]>
            - stop
        - narrate "<red>ERROR: <white>Syntax error. Follow the command syntax."

TownPrisoner_Script:
    type: world
    debug: false
    events:
        after player respawns priority:1:
            - if !<player.has_flag[prisoner_timer]> && <player.has_flag[townjail_prisoner]>:
                - if <location[<player.flag[townjail_prisoner]>_townjail_spawn]||null> == null:
                    - stop
                - narrate "<white> Welcome to the jail <yellow>Prisoner <white>of the town <yellow><player.flag[townjail_prisoner]>"
                - teleport <player> <location[<player.flag[townjail_prisoner]>_townjail_spawn]>
        on delta time secondly:
            - foreach <server.online_players.filter[has_flag[townjail_prisoner]]> as:server_player:
                - flag <[server_player].as_player> townjail_prisoner_timer:--
                - actionbar "<yellow>Time Remaining in Town Jail: <red><[server_player].flag[townjail_prisoner_timer]>s" targets:<[server_player]>
                - if <[server_player].flag[townjail_prisoner_timer]> == 0:
                    - flag server <[server_player].flag[townjail_prisoner]>_townjail_prisoners:<-:<[server_player]>
                    - flag <[server_player].as_player> townjail_prisoner_timer:!
                    - narrate "<yellow>[<[server_player].flag[townjail_prisoner]>] <white>You are free of the jail!" targets:<[server_player]>
                    - flag <[server_player].as_player> townjail_prisoner:!
        on command:
            - if <context.source_type> == PLAYER:
                - if <player.has_flag[townjail_prisoner]>:
                    - if <context.command> == tpa:
                        - determine FULFILLED
                    - if <context.args.size> < 1:
                        - stop
                    - if <context.command> == t || <context.command> == town:
                        - if <context.args.get[1]> == spawn:
                            - determine FULFILLED
