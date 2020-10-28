Thirst_Script:
    type: world
    debug: false
    events:
        on delta time minutely:
            - foreach <server.online_players> as:server_player:
                - if !<[server_player].has_flag[drink_water]>:
                    - flag <[server_player]> thirst:90
                    - flag <[server_player]> drink_water:false
                - if !<[server_player].has_flag[thirst]> || <[server_player].gamemode> != SURVIVAL:
                    - stop
                - flag <[server_player]> thirst:--
                - if <[server_player].flag[thirst]> <= 0:
                    - flag <[server_player]> thirst:!
        on delta time secondly:
            - define dehydrated_players <server.online_players.filter_tag[<[filter_value].has_flag[drink_water].and[<[filter_value].has_flag[thirst].not>].and[<[filter_value].gamemode.contains_text[SURVIVAL]>]>]>
            - hurt <[dehydrated_players]>
            - title subtitle:<&chr[EFF2].repeat[10]> targets:<[dehydrated_players]> stay:5s
        on player consumes potion:
            - if <context.item.potion_base_type> == WATER:
                - flag <player> thirst:90
                - run Thirst_Show_Task def:<player>
        on player respawns:
            - flag <player> thirst:90
            - run Thirst_Show_Task def:<player>

Thirst_Show_Task:
    type: task
    debug: false
    definitions: target
    script:
        - if <[target].has_flag[thirst]>:
            - define full_thirst <[target].flag[thirst].div[9].round_to[0]>
            - define empty_thirst <element[10].sub[<[full_thirst]>]>
            - title subtitle:<&chr[EFF4].repeat[<[full_thirst]>]><&chr[EFF2].repeat[<[empty_thirst]>]> targets:<[target]> stay:5s
        - else:
            - title subtitle:<&chr[EFF2].repeat[10]> targets:<[target]> stay:5s

Thirst_Command:
    type: command
    debug: false
    name: thirst
    description: Minecraft thirst system.
    usage: /thirst
    script:
        - if !<player.has_flag[drink_water]>:
            - flag <player> thirst:90
            - flag <player> drink_water:false
        - run Thirst_Show_Task def:<player>