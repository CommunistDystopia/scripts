# +----------------------
# |
# | RANKCHIEF
# |
# +----------------------
#
# @author devnodachi
# @date 2020/10/01
# @denizen-build REL-1714
# @dependency TownyAdvanced/Towny
#

Command_AdminRankChief:
    type: command
    debug: false
    name: arankchief
    description: Minecraft Towny Jail [Chief] system.
    usage: /arankchief
    permission: townjail.rankchief.all
    script:
        - if <context.args.size> < 2:
            - narrate "<red>ERROR: <white>ERROR: Not enough arguments. Follow the command syntax."
            - stop
        - if <town[<context.args.get[1]>]||null> == null:
            - narrate "<red> ERROR: <white>The town name is invalid."
            - stop
        - define town <context.args.get[1]>
        - define args_used 1
        - inject RankChief_Task

Command_RankChief:
    type: command
    debug: false
    name: rankchief
    description: Minecraft Towny Jail [Chief] system.
    usage: /rankchief
    tab complete:
        - if <player.has_town>:
            - choose <context.args.size>:
                - case 0:
                    - determine <list[list|add|remove]>
                - case 1:
                    - if "!<context.raw_args.ends_with[ ]>":
                        - determine <list[list|add|remove].filter[starts_with[<context.args.first>]]>
                    - else:
                        - if <context.args.get[1]> == list:
                            - determine 0
                        - if <context.args.get[1].contains_any[add|remove]>:
                            - determine <server.online_players.parse[name]>
    permission: townjail.rankchief.town;townjail.rankchief.all
    script:
        - if !<player.has_town>:
            - narrate "<red> ERROR: <white>You need to be in a Town to use this command."
            - stop
        - define town <player.town.name>
        - define args_used 0
        - inject RankChief_Task

RankChief_Task:
    type: task
    debug: false
    script:
        - define action <context.args.get[<[args_used].add[1]>]>
        - if <[action]> == list:
            - run List_Task_Script def:server|<[town]>_townjail_chiefs|Chief|<context.args.get[<[args_used].add[3]>]||null>|true|Town
            - stop
        - if <context.args.size> < <[args_used].add[2]>:
            - narrate "<red>ERROR: <white>ERROR: Not enough arguments. Follow the command syntax."
            - stop
        - define username <server.match_offline_player[<context.args.get[<[args_used].add[2]>]>]||null>
        - if <[username]> == null:
            - narrate "<red> ERROR: <white>Invalid player username."
            - stop
        - if <[action]> == add:
            - if <[username]> == <town[<[town]>].mayor>:
                - narrate "<red> ERROR: <white>The player is the Mayor. What are you doing!?"
                - stop
            - if <[username].town> == null || <[username].town.name> != <[town]>:
                - narrate "<red> ERROR: <white>The player is not part of the town <yellow><[town]>"
                - stop
            - if <[username].in_group[chief]>:
                - narrate "<red> ERROR: <white>The player is a Chief of the town <yellow><[town]>"
                - stop
            - flag server <[town]>_townjail_chiefs:|:<[username]>
            - execute as_server "lp user <[username].name> parent add chief" silent
            - narrate "<green> Player <yellow><[username].name> <green>added as a Chief of the town <yellow><[town]>"
            - if <[username].is_online>:
                - narrate "<yellow>[<[town]>] <green>Congratuations! You were added as the <yellow>Chief <green>of the town!" targets:<[username]>
            - stop
        - if <[action]> == remove:
            - flag server <[town]>_townjail_chiefs:<-:<[username]>
            - execute as_server "lp user <[username].name> parent remove chief" silent
            - narrate "<green> Player <yellow><[username].name> <red>removed <green>as a Chief of the town <yellow><[town]>"
            - if <[username].is_online>:
                - narrate "<yellow>[<[town]>] <white>You were <red>removed <white>as the <yellow>Chief <white>of the town!" targets:<[username]>
            - stop
        - narrate "<red>ERROR: <white>Syntax error. Follow the command syntax."
