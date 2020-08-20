# +----------------------
# |
# | SLAVEVIP [GODVIP]
# |
# +----------------------
#
# @author devnodachi
# @date 2020/08/15
# @denizen-build REL-1714
# @dependency devnodachi/jails devnodachi/slaves
# @soft-dependency devnodachi/slaves_auction
#
# Commands
# /slavevip free [username] - A Godvip frees a slave

Command_Slavevip:
    type: command
    debug: false
    name: slavevip
    description: Minecraft slavevip system.
    usage: /slavevip
    tab complete:
        - if !<player.is_op||<context.server>> && !<player.in_group[godvip]>:
            - stop
        - choose <context.args.size>:
            - case 0:
                - determine <list[free]>
            - case 1:
                - if "!<context.raw_args.ends_with[ ]>":
                    - determine <list[free].filter[starts_with[<context.args.first>]]>
                - else:
                    - determine <server.online_players.filter[in_group[slave]].parse[name]>
            - case 2:
                - if "!<context.raw_args.ends_with[ ]>":
                    - determine <server.online_players.filter[in_group[slave]].parse[name]>
    script:
        - if !<player.is_op||<context.server>> && !<player.in_group[godvip]>:
            - narrate "<red>You do not have permission for that command."
            - stop
        - if <context.args.size> < 2:
            - goto syntax_error
        - define action <context.args.get[1]>
        - define slave <server.match_player[<context.args.get[2]>]||null>
        - if <[slave]> == null:
            - narrate "<red> ERROR: Invalid player username OR the player is offline."
            - stop
        - if !<[slave].in_group[slave]>:
            - narrate "<red> ERROR: <[slave].name> isn't a slave"
            - stop
        - if !<[slave].has_flag[owner]>:
            - narrate "<red> ERROR: <[slave].name> isn't a valid slave"
            - stop
        - if <[action]> == free:
            - if <[slave].has_flag[owner]> && !<[slave].flag[owner].starts_with[jail_]>:
                - if !<[slave].flag[owner].contains_all_case_sensitive_text[<player.uuid>]>:
                    - narrate "<red>ERROR: <yellow><[slave].name> <red>isnt't your slave."
                    - stop
            - flag <[slave]> owner:!
            - if <[slave].has_flag[slave_groups]>:
                - foreach <[slave].flag[slave_groups]> as:group:
                    - execute as_server "lp user <[slave].name> parent add <[group]>" silent
            - flag <[slave]> slave_groups:!
            - execute as_server "lp user <[slave].name> parent remove slave" silent
            - narrate "<green> The slave <red><[slave].name> <green>is now free!"
            - stop
        - mark syntax_error
        - narrate "<red> USAGE: <white>/slavevip free [username]"