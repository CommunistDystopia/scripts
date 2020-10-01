# +----------------------
# |
# | RANKBORDER
# |
# +----------------------
#
# @author devnodachi
# @date 2020/10/01
# @denizen-build REL-1714
# @dependency TownyAdvanced/Towny
#

Command_AdminRankBorder:
    type: command
    debug: false
    name: arankborder
    description: Minecraft Towny Jail [Border Officer] system.
    usage: /arankborder
    permission: border.rankborder.all
    script:
        - if <context.args.size> < 2:
            - narrate "<red>ERROR: <white>ERROR: Not enough arguments. Follow the command syntax."
            - stop
        - if <town[<context.args.get[1]>]||null> == null:
            - narrate "<red> ERROR: <white>The town name is invalid."
            - stop
        - define town <context.args.get[1]>
        - define args_used 1
        - inject RankBorder_Task

Command_RankBorder:
    type: command
    debug: false
    name: rankborder
    description: Minecraft Towny Jail [Border Officer] system.
    usage: /rankborder
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
    permission: border.rankborder.town;border.rankborder.all
    script:
        - if !<player.has_town>:
            - narrate "<red> ERROR: <white>You need to be in a Town to use this command."
            - stop
        - define town <player.town.name>
        - define args_used 0
        - inject RankBorder_Task

RankBorder_Task:
    type: task
    debug: false
    script:
        - define action <context.args.get[<[args_used].add[1]>]>
        - if <[action]> == list:
            - run List_Task_Script def:server|<[town]>_border_borders|Border|<context.args.get[<[args_used].add[3]>]||null>|true|Border
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
            - if <[username].in_group[border]>:
                - narrate "<red> ERROR: <white>The player is a Border Officer of the town <yellow><[town]>"
                - stop
            - flag server <[town]>_border_borders:|:<[username]>
            - narrate "<green> Request to be border sent to <yellow><[username].name>"
            - narrate "<green> The request will expire in 1 hour."
            - if <[username].is_online>:
                - narrate "<yellow>[<[town]>] <white>You have a request to be a border officer of the town. Do <yellow>/acceptborder <white>to accept" targets:<[username]>
            - flag <[username]> border_request:<[town]> duration:1h
            - stop
        - if <[action]> == remove:
            - flag server <[town]>_border_borders:<-:<[username]>
            - group remove border player:<[username]>
            - narrate "<green> Player <yellow><[username].name> <red>removed <green>as a Border Officer of the town <yellow><[town]>"
            - if <[username].is_online>:
                - narrate "<yellow>[<[town]>] <white>You were <red>fired <white>as border officer!" targets:<[username]>
            - stop
        - narrate "<red>ERROR: <white>Syntax error. Follow the command syntax."

Command_AcceptBorder:
    type: command
    debug: false
    name: acceptborder
    description: Minecraft Towny Jail [Border Officer] system.
    usage: /acceptborder
    script:
        - if !<player.has_flag[border_request]>:
            - narrate "<red> ERROR: <white>You don't have a request pending!"
            - stop
        - if !<player.has_town> || <player.town.name> != <player.flag[border_request]>:
            - narrate "<red> ERROR: <white>You left the town that sent the request to you!"
            - flag <player> border_request:!
            - stop
        - flag <player> border_request:!
        - flag server <player.town.name>_borders:|:<player>
        - group add border player:<player>
        - narrate "<yellow>[<player.town.name>] <green>Welcome to the border of the town!"

RankBorder_Script:
    type: world
    debug: false
    events:
        on player kills player:
            - if !<context.damager.has_town>:
                - stop
            - define town <context.damager.town.name>
            - if !<server.has_flag[<[town]>_border_wanteds]>:
                - stop
            - if <context.damager.town.mayor> == <context.damager> || <context.damager.has_permission[border.rankborder.arrest]>:
                - if <server.flag[<[town]>_border_wanteds].contains[<context.entity>]>:
                    - flag server <[town]>_border_wanteds:<-:<context.entity>
                    - flag server <[town]>_border_prisoners:|:<context.entity>
                    - flag <context.entity> border_prisoner_timer:300
                    - flag <context.entity> border_prisoner:<[town]>
