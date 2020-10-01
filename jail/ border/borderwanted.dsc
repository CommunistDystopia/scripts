# +----------------------
# |
# | BORDERWANTED
# |
# +----------------------
#
# @author devnodachi
# @date 2020/10/01
# @denizen-build REL-1714
# @dependency TownyAdvanced/Towny
#

Command_AdminBorderWanted:
    type: command
    debug: false
    name: aborderwanted
    description: Minecraft Towny Jail [Wanted] system.
    usage: /aborderwanted
    permission: border.borderwanted.all
    script:
        - if <context.args.size> < 2:
            - narrate "<red>ERROR: <white>ERROR: Not enough arguments. Follow the command syntax."
            - stop
        - if <town[<context.args.get[1]>]||null> == null:
            - narrate "<red> ERROR: <white>The town name is invalid."
            - stop
        - define town <context.args.get[1]>
        - define args_used 1
        - inject BorderWanted_Task

Command_BorderWanted:
    type: command
    debug: false
    name: borderwanted
    description: Minecraft Towny Jail [Wanted] system.
    usage: /borderwanted
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
    permission: border.borderwanted.town;border.borderwanted.all
    script:
        - if !<player.has_town>:
            - narrate "<red> ERROR: <white>You need to be in a Town to use this command."
            - stop
        - define town <player.town.name>
        - define args_used 0
        - inject BorderWanted_Task

BorderWanted_Task:
    type: task
    debug: false
    script:
        - define action <context.args.get[<[args_used].add[1]>]>
        - if <[action]> == list:
            - run List_Task_Script def:server|<[town]>_border_wanteds|Wanted|<context.args.get[<[args_used].add[3]>]||null>|true|Border
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
            - if <server.has_flag[<[town]>_border_wanteds]> && <server.flag[<[town]>_border_wanteds].contains[<[username]>]>:
                - narrate "<red> ERROR: <white>The player is a wanted of the town border"
                - stop
            - flag server <[town]>_border_wanteds:|:<[username]>
            - narrate "<green> Player <yellow><[username].name> <green>added as a Wanted of the town border <yellow><[town]>"
            - stop
        - if <[action]> == remove:
            - flag server <[town]>_border_wanteds:<-:<[username]>
            - narrate "<green> Player <yellow><[username].name> <red>removed <green>as a Wanted of the town border <yellow><[town]>"
            - if <[username].is_online>:
                - narrate "<yellow>[<[town]>] <white>You were <red>removed <white>from the Border Wanteds!"
            - stop
        - narrate "<red>ERROR: <white>Syntax error. Follow the command syntax."
