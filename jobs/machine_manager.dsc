Command_Manager:
    type: command
    debug: false
    name: manager
    description: Minecraft machine manager system.
    usage: /manager
    script:
        - if !<player.is_op||<context.server>> && !<player.has_flag[manager]>:
            - narrate "<red>You do not have permission for that command."
            - stop
        - if <context.args.size> < 2:
            - narrate "<yellow>#<red> ERROR: Not enough arguments. Follow the command syntax:"
            - narrate "<yellow>-<red> To toggle the trust of a player <white>/manager trust <yellow>username"
            - narrate "<yellow>-<red> To buy a machine upgrade: <white>/manager upgrade <yellow>machine_name"
            - stop
        - define action <context.args.get[1]>
        - define target <context.args.get[2]>
        - if <[action]> == trust:
            - define username <server.match_player[<[target]>]||null>
            - if <[username]> == null:
                - narrate "<red> ERROR: Invalid player username OR the player is offline."
                - stop
            - if !<player.has_flag[trusted_players]>:
                - flag player trusted_players:|:<[username]>
                - narrate "<green>You successfully trusted <blue><[username].name>"
                - stop
            - if <player.flag[trusted_players].find[<[username]>]>
                - flag player trusted_players:<-:<[username]>
                - narrate "<green>You successfully <red>untrusted <blue><[username].name>"
                - stop
            - flag player trusted_players:|:<[username]>
            - narrate "<green>You successfully trusted <blue><[username].name>"
            - stop
        - if <[action]> == upgrade:
            - if <script[<[target]>]||null> == null:
                - narrate "<red> ERROR: Invalid machine name. Maybe you forgot to add an underscore instead of spaces?"
            - inventory open d:<[target]>_shop