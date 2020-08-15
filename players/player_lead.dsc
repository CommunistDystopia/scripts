# +----------------------
# |
# | PLAYER LEAD
# |
# | Force players to follow you using a lead.
# |
# +----------------------
#
# @author devnodachi
# @date 2020/08/15
# @denizen-build REL-1714
# @soft-dependency devnodachi/slaves
#
# Commands
# /lead releaseall - Release all leaded players
# /lead start [username] - Forces the player to follow you within X blocks.
# /lead limit [username] [10-100] - Sets the space between the leaded player and you. [Default: 20] [Min: 10] [Max: 100]
# /lead release [username] - Release a leaded player

Command_Player_Lead:
    type: command
    debug: false
    name: lead
    description: Minecraft player lead system.
    usage: /lead
    tab complete:
        - if <context.server>:
            - stop
        - choose <context.args.size>:
            - case 0:
                - determine <list[start|limit|release|releaseall]>
            - case 1:
                - if "!<context.raw_args.ends_with[ ]>":
                    - determine <list[start|limit|release|releaseall].filter[starts_with[<context.args.first>]]>
                - else:
                    - determine <server.online_players.parse[name]>
            - case 2:
                - if "!<context.raw_args.ends_with[ ]>":
                    - determine <server.online_players.parse[name]>
    script:
        - if <context.server>:
            - stop
        - if <context.args.size> < 1:
            - goto syntax_error
        - define action <context.args.get[1]>
        - if <[action]> == releaseall:
            - inject Player_Lead_Stop_All_Task instantly
            - stop
        - if <context.args.size> < 2:
            - goto syntax_error
        - define username <server.match_player[<context.args.get[2]>]||null>
        - if <[username]> == null:
            - narrate "<red> ERROR: Invalid player username OR the player is offline."
            - stop
        - if <player.is_op> && <[action]> == start:
            - inject Player_Lead_Task instantly
        - if <[action]> == limit && <context.args.size> == 3:
            - if !<[username].has_flag[lead_owner]>:
                - narrate "<red> ERROR: This player isn't being leaded"
                - stop
            - if !<[username].flag[lead_owner].as_player.uuid.contains_all_case_sensitive_text[<player.uuid>]>:
                - narrate "<red> ERROR: You aren't leading that player to change the block limit"
                - stop
            - define limit_number <context.args.get[3]>
            - if <[limit_number]> < 10 && <[limit_number]> > 100:
                - narrate "<red> ERROR: The space limit between <[username].name> and you needs to be in the range of <yellow>10-100 <red>blocks"
                - stop
            - flag <[username]> lead_block_limit:<[limit_number]>
            - narrate "<green> The space between <[username].name> and you will be <yellow><[limit_number]> <green>blocks"
            - stop
        - if <[action]> == release:
            - inject Player_Lead_Stop_Task instantly
            - stop
        - mark syntax_error
        - narrate "<yellow>#<red> ERROR: Syntax error. Follow the command syntax:"
        - narrate "<yellow>-<red> Release all leaded players: <white>/lead releaseall"
        - narrate "<yellow>-<red> Limit the blocks between the leaded player: <white>/lead limit <yellow>username [10-100]"
        - narrate "<yellow>-<red> Release a leaded player: <white>/lead release <yellow>username"

Player_Lead_Script:
    type: world
    debug: false
    events:
        on player right clicks player with:LEAD:
            - define username <context.entity>
            - ratelimit <player> 5s
            - if !<player.is_op>:
                - inject Player_Lead_Check_Task instantly
            - inject Player_Lead_Start_Task instantly
        on player quits:
            - inject Player_Lead_Stop_All_Task instantly
            - if <player.has_flag[lead_owner]> || <player.has_flag[lead_queue]>:
                - flag <player.flag[lead_owner]> players_in_lead:<-:<player>
                - flag <player> lead_owner:!
                - flag <player> lead_block_limit:!
                - flag <player> lead_queue:!
                - flag <player> spawn_on_jail:true
        after player joins:
            - wait 5s
            - if <player.is_online> && <player.has_flag[spawn_on_jail]>:
                - if <player.in_group[slave]>:
                    - narrate "<red> You tried to escape from the lead of the <yellow>Supreme Warden<red>. Good try"
                    - teleport <player> <location[<player.flag[owner]>_spawn]>
                    - flag <player> spawn_on_jail:!
                - else:
                    - flag <player> spawn_on_jail:!

Player_Lead_Check_Task:
    type: task
    debug: false
    definitions: username
    script:
        - define lead_groups <script[Player_Lead_Config].data_key[groups]||null>
        - if <[lead_groups]> == null:
            - narrate " <red>ERROR: The lead config file has been corrupted!"
            - narrate " <white>Please report this error to a higher rank or open a ticket in Discord."
            - stop
        - define isValidGroup false
        - foreach <[lead_groups].keys> as:lead_group:
            - if <player.in_group[<[lead_group]>]>:
                - define valid_groups <[lead_groups].get[<[lead_group]>]>
                - foreach <[valid_groups]> as:valid_group:
                    - if <[username].in_group[<[valid_group]>]>:
                        - define isValidGroup true
                        - foreach stop
                - if <[isValidGroup]>:
                    - foreach stop
        - if !<[isValidGroup]>:
            - narrate "<red> You can't lead that player!"
            - stop
        - if <[username].in_group[slave]>:
            - if <[username].has_flag[owner]>:
                - if <player.in_group[godvip]> && !<[username].flag[owner].starts_with[jail_]>:
                    - if !<[username].flag[owner].contains_all_case_sensitive_text[<player.uuid>]>:
                        - narrate "<red> You can't lead that player!"
                        - stop
            - else:
                - if <player.in_group[supremewarden]> && !<player.in_group[godvip]>:
                    - narrate "<red> You can't lead that player!"
                    - stop

Player_Lead_Start_Task:
    type: task
    debug: false
    definitions: username
    script:
        - inject Player_Lead_Stop_Task instantly
        - flag <[username]> lead_owner:<player>
        - flag <[username]> lead_block_limit:20
        - flag <[username]> lead_queue:<queue>
        - flag <player> players_in_lead:|:<[username]>
        - narrate "<green> Starting to force the player <red><[username].name> <green>to stay within <yellow><[username].flag[lead_block_limit]> <green>blocks"
        - narrate "<yellow> Be aware. <green>It will work until you or the player goes offline."
        - narrate "<red> You are now forced to stay with <yellow><player.name>" targets:<[username]>
        - while <player.is_online> && <[username].is_online> && <[username].has_flag[lead_owner]>:
            - if <player.location.points_between[<[username].location>].size> > <[username].flag[lead_block_limit]>:
                - teleport <[username]> <player.location>
            - wait 1s
        - if !<[username].has_flag[lead_owner]>:
            - flag <[username]> lead_block_limit:!
            - flag <[username]> lead_queue:!
            - flag <player> players_in_lead:<-:<[username]>

Player_Lead_Stop_Task:
    type: task
    debug: false
    definitions: username
    script:
        - if <[username].has_flag[lead_queue]>:
            - if <player.has_flag[players_in_lead]> && <player.flag[players_in_lead].find[<[username]>]> != -1:
                - queue <[username].flag[lead_queue]> stop
                - flag <player> players_in_lead:<-:<[username]>
                - if <[username].has_flag[lead_owner]>:
                    - flag <[username]> lead_owner:!
                    - flag <[username]> lead_block_limit:!
                    - flag <[username]> lead_queue:!
                    - if <[username].is_online> && <[username].in_group[slave]> && <[username].has_flag[owner]> && <[username].flag[owner].starts_with[jail_]>:
                        - teleport <[username]> <location[<[username].flag[owner]>_spawn]>
                        - narrate "<yellow> <player.name> <red>released you. <green>Welcome back to Jail" targets:<[username]>
                    - narrate "<green> The Lead on <red><[username].name> <green>stopped"
            - else:
                - narrate " <red> ERROR: You can't start or stop the lead of <yellow><[username].name><red>. The player is being leaded by <yellow><[username].flag[lead_owner].name>"
            - stop

Player_Lead_Stop_All_Task:
    type: task
    debug: false
    script:
        - if <player.has_flag[players_in_lead]>:
            - foreach <player.flag[players_in_lead]> as:lead_player:
                - define username <[lead_player].as_player>
                - flag <[username]> lead_owner:!
                - flag <[username]> lead_block_limit:!
                - flag <[username]> lead_queue:!
                - if <[username].is_online> && <[username].in_group[slave]> && <[username].has_flag[owner]> && <[username].flag[owner].starts_with[jail_]>:
                    - teleport <[username]> <location[<[username].flag[owner]>_spawn]>
                    - narrate "<yellow> <player.name> <red>released you. <green>Welcome back to Jail" targets:<[username]>
            - flag <player> players_in_lead:!
            - if <player.is_online>:
                - narrate "<green> All players linked to the lead has been <red>released"
        - else:
            - if <player.is_online>:
                - narrate "<red> ERROR: You aren't leading anyone"