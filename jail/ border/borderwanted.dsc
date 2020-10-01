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

Command_BorderWanted:
    type: command
    debug: false
    name: borderwanted
    description: Minecraft Towny Jail [Wanted] system.
    usage: /borderwanted
    tab complete:
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
    permission: border.borderwanted.all
    script:
        - define action <context.args.get[1]>
        - if <[action]> == list:
            - run List_Task_Script def:server|border_wanteds|Wanted|<context.args.get[2]||null>|true|Border
            - stop
        - if <context.args.size> < 2:
            - narrate "<red>ERROR: <white>ERROR: Not enough arguments. Follow the command syntax."
            - stop
        - define username <server.match_offline_player[<context.args.get[2]>]||null>
        - if <[username]> == null:
            - narrate "<red> ERROR: <white>Invalid player username."
            - stop
        - if <[action]> == add:
            - if <server.has_flag[border_prisoners]> && <server.flag[border_prisoners].contains[<[username]>]>:
                - narrate "<red> ERROR: <white>The player is a prisoner of the border"
                - stop
            - if <server.has_flag[border_wanteds]> && <server.flag[border_wanteds].contains[<[username]>]>:
                - narrate "<red> ERROR: <white>The player is a wanted of the border"
                - stop
            - flag server border_wanteds:|:<[username]>
            - narrate "<green> Player <yellow><[username].name> <green>added as a Wanted of the border"
            - stop
        - if <[action]> == remove:
            - flag server border_wanteds:<-:<[username]>
            - narrate "<green> Player <yellow><[username].name> <red>removed <green>as a Wanted of the border"
            - if <[username].is_online>:
                - narrate "<yellow>[Border] <white>You were <red>removed <white>from the Border Wanteds!"
            - stop
        - narrate "<red>ERROR: <white>Syntax error. Follow the command syntax."
