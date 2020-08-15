# +----------------------
# |
# | L A B O R D E P
# |
# | Head of workers.
# |
# +----------------------
#
# @author devnodachi
# @date 2020/08/15
# @denizen-build REL-1714
#
# Commands
# /labordep demand [username] - Forces a jobless player to be a worker.
# /labordep pull [username] - Teleports the username to you.

Command_Labordep:
    type: command
    debug: false
    name: labordep
    description: Minecraft player labor deputy system.
    usage: /labordep
    tab complete:
        - if <context.server>:
            - stop
        - choose <context.args.size>:
            - case 0:
                - determine <list[pull|request]>
            - case 1:
                - if "!<context.raw_args.ends_with[ ]>":
                    - determine <list[pull|request].filter[starts_with[<context.args.first>]]>
                - else:
                    - determine <server.online_players.parse[name]>
            - case 2:
                - if "!<context.raw_args.ends_with[ ]>":
                    - determine <server.online_players.parse[name]>
    script:
        - if <player.is_op> && <player.in_group[labordep]>:
            - narrate "<red>You do not have permission for that command."
            - stop
        - if <context.args.size> < 2:
            - goto syntax_error
        - define action <context.args.get[1]>
        - define username <server.match_player[<context.args.get[2]>]||null>
        - if <[username]> == null:
            - narrate "<red> ERROR: Invalid player username OR the player is offline."
            - stop
        - if <[action]> == demand:
            - define validjobs <script[College_Config].data_key[job_groups]||null>
            - if <[validjobs]> == null:
                - narrate "<red>ERROR: The college config file used for the valid jobs has been corrupted!"
                - narrate "<white>Please report this error to a higher rank or open a ticket in Discord."
                - stop
            - foreach <[validjobs]> as:job:
                - if <[username].in_group[<[job]>]>:
                    - narrate "<red> ERROR: <yellow><[username].name> <red>has a job."
                    - stop
            - execute as_server "lp user <[username].name> parent add worker"
            - narrate "<green> You were selected for labour under <yellow><player.name>'s authority." targets:<[username]>
            - teleport <[username]> <player.location>
            - narrate "<yellow> <[username].name> <green>is ready to work and teleported to you."
            - stop
        - if <[action]> == pull:
            - if !<[username].in_group[worker]>:
                - narrate "<red>ERROR: <yellow><[username].name> <red>is not a worker!"
                - stop
            - teleport <[username]> <player.location>
            - narrate "<yellow> <[username].name> <green>teleported to you."
            - narrate "<green> A <yellow>Labor Deputy <green>demands your presence. Teleporting to... <yellow><player.name><green>." targets:<[username]>
            - stop
        - mark syntax_error
        - narrate "<yellow>#<red> ERROR: Syntax error. Follow the command syntax:"
        - narrate "<yellow>-<red> To demand someone to be a worker: <white>/labordep demand <yellow>username"
        - narrate "<yellow>-<red> To pull a worker to you: <white>/labordep pull <yellow>username"