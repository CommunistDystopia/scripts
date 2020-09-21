# +----------------------
# |
# | CRIMINAL RECORD
# |
# | Going to jail wil add one to you.
# |
# +----------------------
#
# @author devnodachi
# @date 2020/08/06
# @denizen-build REL-1714
# @dependency devnodachi/jails devnodachi/slaves
#
# Commands
# /criminalrecord check <username> <#> - Check the criminal record of the player
# /criminalrecord clear <username> - Clears the criminal record of the player

Command_Criminal_Record:
    type: command
    debug: false
    name: criminalrecord
    description: Minecraft criminal record system.
    usage: /criminalrecord
    aliases:
        - cr
    tab complete:
        - if !<player.is_op||<context.server>> && !<player.has_permission[criminalrecord.check]>:
            - stop
        - choose <context.args.size>:
            - case 0:
                - determine <list[check|clear]>
            - case 1:
                - if "!<context.raw_args.ends_with[ ]>":
                    - determine <list[check|clear].filter[starts_with[<context.args.first>]]>
                - else:
                    - determine <server.online_players.parse[name]>
            - case 2:
                - if "!<context.raw_args.ends_with[ ]>":
                    - determine <server.online_players.parse[name]>
                - else:
                    - if <context.args.get[1]> == check:
                        - determine 0
            - case 3:
                - if "!<context.raw_args.ends_with[ ]>":
                    - if <context.args.get[1]> == check:
                        - determine 0
    script:
        - if <context.args.size> < 2:
            - goto syntax_error
        - define action <context.args.get[1]>
        - define username <server.match_offline_player[<context.args.get[2]>]||null>
        - if <[username]> == null:
            - narrate "<red> ERROR: Invalid player username."
            - stop
        - if <[action]> == check:
            - if !<player.is_op||<context.server>> && !<player.has_permission[criminalrecord.check]>:
                - narrate "<red>You do not have permission for that command."
                - stop
            - if <context.args.size> < 3:
                - goto syntax_error
            - define list_page <context.args.get[3]>
            - run List_Task_Script def:<[username]>|criminal_record|Record|<[list_page]>|false
            - stop
        - if <[action]> == clear:
            - if !<player.is_op||<context.server>>:
                - narrate "<red>You do not have permission for that command."
                - stop
            - if !<[username].has_flag[criminal_record]>:
                - narrate "<red> ERROR: This player doesn't have any criminal record"
            - flag <[username]> criminal_record:!
            - narrate "<blue><[username].name> <green>got their <yellow>Criminal Record <green>cleared!"
            - stop
        - mark syntax_error
        - narrate "<yellow>#<red> ERROR: Syntax error. Follow the command syntax:"
        - narrate "<yellow>-<red> To check a criminal record: <white>/criminalrecord check <yellow>username <yellow>number"
        - narrate "<yellow>-<red> To clear a criminal record: <white>/criminalrecord clear <yellow>username"