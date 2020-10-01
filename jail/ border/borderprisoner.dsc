# +----------------------
# |
# | BORDERPRISONER
# |
# +----------------------
#
# @author devnodachi
# @date 2020/10/01
# @denizen-build REL-1714
# @dependency TownyAdvanced/Towny
#

Command_BorderPrisoner:
    type: command
    debug: false
    name: borderprisoner
    description: Minecraft Towny Jail [Border Prisoner] system.
    usage: /borderprisoner
    tab complete:
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
    permission: border.borderprisoner.all
    script:
        - define action <context.args.get[1]>
        - if <[action]> == list:
            - run List_Task_Script def:server|border_prisoners|Prisoner|<context.args.get[2]||null>|true|Border
            - stop
        - if <context.args.size> < 2:
            - narrate "<red>ERROR: <white>ERROR: Not enough arguments. Follow the command syntax."
            - stop
        - define username <server.match_offline_player[<context.args.get[2]>]||null>
        - if <[username]> == null:
            - narrate "<red> ERROR: <white>Invalid player username."
            - stop
        - if <[action]> == remove:
            - if !<[username].has_flag[border_prisoner]>:
                - narrate "The player is not a prisoner of the border"
                - stop
            - flag server border_prisoners:<-:<[username]>
            - flag <[username]> border_prisoner:!
            - flag <[username]> border_prisoner_timer:!
            - narrate "<green> Prisoner <yellow><[username].name> <red>removed <green>from the jail of the border"
            - if <[username].is_online>:
                - if <location[border_spawn]||null> != null:
                    - teleport <[username]> <location[border_spawn]>
                - narrate "<yellow>[Border] <white>You are free of the border jail!" targets:<[username]>
            - stop
        - narrate "<red>ERROR: <white>Syntax error. Follow the command syntax."

BorderPrisoner_Script:
    type: world
    debug: false
    events:
        after player respawns priority:1:
            - if !<player.has_flag[prisoner_timer]> && <player.has_flag[border_prisoner]>:
                - if <location[border_jail_spawn]||null> == null:
                    - stop
                - narrate "<white> Welcome to the jail <yellow>Prisoner <white>of the border <yellow><player.flag[border_prisoner]>"
                - teleport <player> <location[border_jail_spawn]>
        on system time secondly:
            - foreach <server.online_players.filter[has_flag[border_prisoner]]> as:server_player:
                - flag <[server_player].as_player> border_prisoner_timer:--
                - actionbar "<yellow>Time Remaining in Border Jail: <red><[server_player].flag[border_prisoner_timer]>s" targets:<[server_player]>
                - if <[server_player].flag[border_prisoner_timer]> == 0:
                    - flag server border_prisoners:<-:<[server_player]>
                    - flag <[server_player].as_player> border_prisoner_timer:!
                    - narrate "<yellow>[Border] <white>You are free of the border jail!" targets:<[server_player]>
                    - flag <[server_player].as_player> border_prisoner:!
                    - if <location[Border_spawn]||null> != null:
                        - teleport <[server_player]> <location[Border_spawn]>
        on command:
            - if <context.source_type> == PLAYER:
                - if <player.has_flag[border_prisoner]>:
                    - if <context.command> == tpa:
                        - determine FULFILLED
                    - if <context.args.size> < 1:
                        - stop
                    - if <context.command> == t || <context.command> == town:
                        - if <context.args.get[1]> == spawn:
                            - determine FULFILLED
