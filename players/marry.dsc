# +----------------------
# |
# | MARRY
# |
# | The Good, The Bad and The Ugly.
# |
# +----------------------
#
# @author devnodachi
# @date 2020/09/19
# @denizen-build REL-1714
# @dependency devnodachi/slaves
#

Marry_Command_Script:
    type: command
    debug: false
    name: marry
    description: Minecraft Marry system.
    usage: /marry
    tab complete:
        - choose <context.args.size>:
            - case 0:
                - determine <server.online_players.parse[name].include_single[deny]>
            - case 1:
                - if "!<context.raw_args.ends_with[ ]>":
                    - determine <server.online_players.parse[name].include_single[deny]>
    script:
        - if <context.args.size> < 1:
            - narrate "<white> USAGE: <yellow>/marry [username] <white>to accept or <yellow>/marry deny <white>to deny"
            - stop
        - if <context.args.get[1]> == deny:
            - if <player.has_flag[marry]>:
                - narrate "<red> ERROR: <white>You are already married with <yellow><player.flag[marry].as_player.name>"
                - stop
            - if !<player.has_flag[marry_request]>:
                - narrate "<red> ERROR: <white>You don't have a marry request to deny."
                - stop
            - narrate "<green> Marry request canceled from <yellow><player.flag[marry_request].as_player.name>"
            - if <player.flag[marry_request].as_player.is_online>:
                - narrate "<yellow> <player.name> <white>cancelled the marry request" targets:<player.flag[marry_request].as_player>
            - flag <player.flag[marry_request].as_player> marry_request:!
            - flag <player> marry_request:!
            - stop
        - define username <server.match_player[<context.args.get[1]>]||null>
        - if <[username]> == null:
            - narrate "<red> ERROR: <white>Invalid player username OR the player is offline."
            - stop
        - if <[username]> == <player>:
            - narrate "<red> ERROR: <white>You can't marry yourself."
            - stop
        - if <[username].has_flag[marry]>:
            - narrate "<red> ERROR: <white><[username].name> is already married."
            - stop
        - if <player.has_flag[marry_request]>:
            - if <player.flag[marry_request]> == <[username].name>:
                - narrate "<red> ERROR: <white>Wait for <yellow><player.flag[marry_request]> <white>to accept or deny your request"
                - stop
            - if !<player.flag[marry_request].as_player.uuid.contains_all_case_sensitive_text[<[username].uuid>]>:
                - narrate "<red> ERROR: <white>You have a marry request pending from <player.flag[marry_request].as_player.name>"
                - narrate "<white> Do <yellow>/marry deny <white>to deny or <yellow>/marry <player.flag[marry_request].as_player.name> <white>to accept"
                - stop
            - narrate "<green>CONGRATULATIONS! <white>You're marry with <yellow><[username].name>"
            - narrate "<green>CONGRATULATIONS! <white>You're marry with <yellow><player.name>" targets:<[username]>
            - flag <player> marry_request:!
            - flag <[username]> marry_request:!
            - flag <player> marry:<[username]>
            - flag <[username]> marry:<player>
            - stop
        - else:
            - if <[username].has_flag[marry_request]>:
                - narrate "<red> ERROR: <yellow><[username].name> <white>have a marry request"
                - stop
            - flag <player> marry_request:<[username].name>
            - flag <[username]> marry_request:<player>
            - narrate "<yellow> <player.name> <white>wants to marry you. Do <yellow>/marry <player.name> <white>to accept or <yellow>/marry deny <white>to deny" targets:<[username]>
            - narrate "<green> Marry request sent to <yellow><[username].name><white>. Do <yellow>/marry deny <white>if you want to cancel it."
            - stop

Marry_Script:
    type: world
    debug: false
    events:
        after player joins:
            - if <player.has_flag[marry_jail]>:
                - wait 3s
                - if <player.is_online>:
                    - flag <player> marry_jail:!
                    - execute as_server "slaves add <player.flag[marry].as_player.flag[marry_jail].after[jail_]> <player.name>" silent
                    - narrate "<white> Your couple is in <red>JAIL<white>... Welcome to your new <green>HOME<white>."

MarryInfo_Command_Script:
    type: command
    debug: false
    name: marryinfo
    description: Minecraft Marriage Information.
    usage: /marryinfo
    script:
        - if <context.args.size> < 1:
            - narrate "<white> USAGE: <yellow>/marryinfo [username]"
            - stop
        - define username <server.match_offline_player[<context.args.get[1]>]||null>
        - if <[username]> == null:
            - narrate "<red> ERROR: <white>Invalid player username OR the player is offline."
            - stop
        - if !<[username].has_flag[marry]>:
            - narrate "<red> ERROR: <yellow><[username].name> <white>is not married."
            - stop
        - narrate "<yellow> <[username].name> <white>is married with <yellow><[username].flag[marry].as_player.name><white>."

Divorce_Command_Script:
    type: command
    debug: false
    name: divorce
    description: Minecraft Divorce system.
    usage: /divorce
    script:
        - if !<player.has_flag[marry]>:
            - narrate "<red> ERROR: <white>You are not married with anyone."
            - stop
        - if <player.has_flag[divorce]>:
            - if <player.flag[marry].as_player.is_online>:
                - narrate "<yellow> <player.name> <white>divorced from you." targets:<player.flag[marry]>
            - narrate " <white>You divorced from <yellow><player.flag[marry].as_player.name>"
            - flag <player.flag[marry].as_player> marry:!
            - flag <player.flag[marry].as_player> divorce:!
            - flag <player.flag[marry].as_player> marry_jail:!
            - flag <player> marry:!
            - flag <player> divorce:!
            - flag <player> marry_jail:!
            - stop
        - if <player.flag[marry].as_player.has_flag[divorce]>:
            - flag <player.flag[marry].as_player> divorce:!
            - narrate "<green> Divorce request <red>cancelled<green>."
        - else:
            - flag <player.flag[marry].as_player> divorce:true
            - if <player.flag[marry].as_player.is_online>:
                - narrate "<yellow> <player.name> <white>wants to divorce from you." targets:<player.flag[marry].as_player>
                - narrate "<green> Do <yellow>/divorce <green>to accept the divorce request." targets:<player.flag[marry].as_player>
            - narrate "<green> Divorce request sent to <yellow><player.flag[marry].as_player.name><green>."

ForceDivorce_Command_Script:
    type: command
    debug: false
    name: forcedivorce
    description: Minecraft ForceDivorce system.
    usage: /forcedivorce
    script:
        - if !<player.has_flag[marry]>:
            - narrate "<red> ERROR: <white>You are not married with anyone."
            - stop
        - if <player.money> < 100:
            - narrate "<red> ERROR: <white> You don't have enogh money in the bank!"
            - stop
        - if <player.flag[marry].as_player.is_online>:
            - narrate "<yellow> <player.name> <white>divorced from you." targets:<player.flag[marry]>
        - narrate " <white>You divorced from <yellow><player.flag[marry].as_player.name>"
        - money take quantity:100
        - flag <player.flag[marry].as_player> marry:!
        - flag <player.flag[marry].as_player> divorce:!
        - flag <player.flag[marry].as_player> marry_jail:!
        - flag <player> marry:!
        - flag <player> divorce:!
        - flag <player> marry_jail:!