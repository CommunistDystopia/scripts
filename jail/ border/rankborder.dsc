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

Command_RankBorder:
    type: command
    debug: false
    name: rankborder
    description: Minecraft Towny Jail [Border Officer] system.
    usage: /rankborder
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
    permission: border.rankborder.all
    script:
        - define action <context.args.get[1]>
        - if <[action]> == list:
            - run List_Task_Script def:server|border_officers|Officer|<context.args.get[2]||null>|true|Border
            - stop
        - if <context.args.size> < 2:
            - narrate "<red>ERROR: <white>ERROR: Not enough arguments. Follow the command syntax."
            - stop
        - define username <server.match_offline_player[<context.args.get[2]>]||null>
        - if <[username]> == null:
            - narrate "<red> ERROR: <white>Invalid player username."
            - stop
        - if <[action]> == add:
            - if <server.has_flag[border_officers]> && <server.flag[border_officers].contains[<[username]>]>:
                - narrate "<red> ERROR: <white>The player is a Border Officer"
                - stop
            - flag server border_officers:|:<[username]>
            - execute as_server "lp user <[username].name> parent add border" silent
            - narrate "<green> Player <yellow><[username].name> <red>added <green>as a Border Officer"
            - if <[username].is_online>:
                - narrate "<yellow>[Border] <green>Welcome to the border!" targets:<[username]>
            - stop
        - if <[action]> == remove:
            - flag server border_officers:<-:<[username]>
            - execute as_server "lp user <[username].name> parent remove border" silent
            - narrate "<green> Player <yellow><[username].name> <red>removed <green>as a Border Officer"
            - if <[username].is_online>:
                - narrate "<yellow>[Border] <white>You were <red>fired <white>as border officer!" targets:<[username]>
            - stop
        - narrate "<red>ERROR: <white>Syntax error. Follow the command syntax."

RankBorder_Script:
    type: world
    debug: false
    events:
        on player kills player:
            - if <location[border_jail_spawn]||null> == null:
                - stop
            - if !<context.damager.has_permission[border.rankborder.arrest]>:
                - stop
            - if !<context.damager.is_op>:
                - if !<server.has_flag[border_officers]>:
                    - determine cancelled
                - if !<server.flag[border_officers].contains[<context.damager>]>:
                    - determine cancelled
            - if <server.has_flag[border_wanteds]> && <server.flag[border_wanteds].contains[<context.entity>]>:
                - flag server border_wanteds:<-:<context.entity>
                - inject locally send_to_jail
            - if <context.damager.item_in_hand.has_script> && <context.damager.item_in_hand.scriptname> == border_stick:
                - inject locally send_to_jail
        on entity damaged by player with:border_stick:
            - if !<context.damager.has_permission[border.rankborder.arrest]>:
                - determine cancelled
            - if !<context.damager.is_op>:
                - if !<server.has_flag[border_officers]>:
                    - determine cancelled
                - if !<server.flag[border_officers].contains[<context.damager>]>:
                    - determine cancelled
            - if !<server.has_flag[border]>:
                - determine cancelled
            - if <cuboid[<server.flag[border]>]||null> == null:
                - determine cancelled
            - define border <cuboid[<server.flag[border]>]>
            - if !<[border].contains_location[<context.damager.location>]>:
                - determine cancelled
        on player drops border_stick:
            - remove <context.entity>
    send_to_jail:
        - if <server.has_flag[border_prisoners]> && <server.flag[border_prisoners].contains[<context.entity>]>:
            - stop
        - flag server border_prisoners:|:<context.entity>
        - flag <context.entity> border_prisoner_timer:300
        - flag <context.entity> border_prisoner:true
        - stop

Command_BorderStick:
    type: command
    debug: false
    name: borderstick
    description: Minecraft Towny Jail [Border Officer] sword system.
    usage: /borderstick
    script:
        - if !<player.is_op||<context.server>>:
            - narrate "<red>You do not have permission for that command."
            - stop
        - if <context.args.size> < 1:
            - narrate "<red>ERROR: <white>ERROR: Not enough arguments. Follow the command syntax."
            - stop
        - define username <server.match_player[<context.args.get[1]>]||null>
        - if <[username]> == null:
            - narrate "<red> ERROR: <white>Invalid player username or the player is offline."
            - stop
        - give border_stick to:<[username].inventory>

border_stick:
    type: item
    debug: false
    material: diamond_sword
    mechanisms:
        repair_cost: 99
        hides: enchants
        enchantments: sharpness,5|unbreaking,10
    display name: <aqua>Border Stick
    lore:
        - <gray>Kill players to send them to the border jail
        - <red>Only works in the border!