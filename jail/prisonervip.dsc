# +----------------------
# |
# | PRISONERVIP [GODVIP]
# |
# +----------------------
#
# @author devnodachi
# @date 2020/08/15
# @denizen-build REL-1714
# @dependency devnodachi/jails devnodachi/prisoners
# @soft-dependency devnodachi/prisoners_auction
#
# Commands
# /prisonervip free [username] - A Godvip frees a prisoner

Command_Slavevip:
    type: command
    debug: false
    name: prisonervip
    description: Minecraft prisonervip system.
    usage: /prisonervip
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
                    - determine <server.online_players.filter[in_group[prisoner]].parse[name]>
            - case 2:
                - if "!<context.raw_args.ends_with[ ]>":
                    - determine <server.online_players.filter[in_group[prisoner]].parse[name]>
    script:
        - if !<player.is_op||<context.server>> && !<player.in_group[godvip]>:
            - narrate "<red>You do not have permission for that command."
            - stop
        - if <context.args.size> < 2:
            - goto syntax_error
        - define action <context.args.get[1]>
        - define prisoner <server.match_player[<context.args.get[2]>]||null>
        - if <[prisoner]> == null:
            - narrate "<red> ERROR: Invalid player username OR the player is offline."
            - stop
        - if !<[prisoner].in_group[prisoner]>:
            - narrate "<red> ERROR: <[prisoner].name> isn't a prisoner"
            - stop
        - if !<[prisoner].has_flag[owner]>:
            - narrate "<red> ERROR: <[prisoner].name> isn't a valid prisoner"
            - stop
        - if <[action]> == free:
            - if <[prisoner].has_flag[owner]> && !<[prisoner].flag[owner].starts_with[jail_]>:
                - if !<[prisoner].flag[owner].contains_all_case_sensitive_text[<player.uuid>]>:
                    - narrate "<red>ERROR: <yellow><[prisoner].name> <red>isnt't your prisoner."
                    - stop
            - flag <[prisoner]> owner:!
            - if <[prisoner].has_flag[prisoner_groups]>:
                - foreach <[prisoner].flag[prisoner_groups]> as:group:
                    - execute as_server "lp user <[prisoner].name> parent add <[group]>" silent
            - flag <[prisoner]> prisoner_groups:!
            - execute as_server "lp user <[prisoner].name> parent remove prisoner" silent
            - narrate "<green> The prisoner <red><[prisoner].name> <green>is now free!"
            - stop
        - mark syntax_error
        - narrate "<red> USAGE: <white>/prisonervip free [username]"