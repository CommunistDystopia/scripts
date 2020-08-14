# +----------------------
# |
# | J O B S
# |
# +----------------------
#
# @author devnodachi
# @date 2020/08/12
# @denizen-build REL-1714
# @dependency devnodachi/college_config
# @soft-dependency devnodachi/soldiers
#

Command_Job:
    type: command
    debug: false
    name: job
    description: Minecraft Job system.
    usage: /job
    tab complete:
        - if <context.server>:
            - stop
        - choose <context.args.size>:
            - case 0:
                - determine <list[clear|quit]>
            - case 1:
                - if "!<context.raw_args.ends_with[ ]>":
                    - determine <list[clear|quit].filter[starts_with[<context.args.first>]]>
                - else:
                    - if <context.args.get[1]> == clear:
                        - determine <server.online_players.parse[name]>
            - case 2:
                - if "!<context.raw_args.ends_with[ ]>":
                    - if <context.args.get[1]> == clear:
                        - determine <server.online_players.parse[name]>
    script:
        - if <context.server>:
            - narrate "<red> ERROR: This command is only runnable by players!"
        - if <context.args.size> < 1:
            - narrate "<red> USAGE: <white>/job quit"
            - stop
        - define action <context.args.get[1]>
        - if <[action]> == quit:
            - run Job_Group_Clear_Task def:<player>
            - stop
        - if <[action]> == clear && <player.is_op>:
            - if <context.args.size> < 2:
                - narrate "<red> USAGE: <white>/job clear [username]"
                - stop
            - define username <server.match_player[<context.args.get[2]>]||null>
            - if <[username]> == null:
                - narrate "<red> ERROR: Invalid player username OR the player is offline."
                - stop
            - run Job_Group_Clear_Task def:<[username]>

Job_Group_Clear_Task:
    type: task
    debug: false
    definitions: username
    script:
        - define validjobs <script[College_Config].data_key[job_groups]||null>
        - if <[validjobs]> == null:
            - narrate "<red>ERROR: The college config file used for the valid jobs has been corrupted!"
            - narrate "<white>Please report this error to a higher rank or open a ticket in Discord."
            - stop
        - define player_jobs <[validjobs].shared_contents[<[username].groups>]>
        - if <[player_jobs].is_empty>:
            - if <queue.player||null> != null && <queue.player> == <[username]>:
                - narrate "<red> ERROR: You don't have a valid job to quit!"
            - else:
                - narrate "<red> ERROR: <[username].name> doesn't have a valid job to quit!"
            - stop
        - foreach <[player_jobs]> as:job:
            - if <player.in_group[<[job]>]>:
                - if <[job]> == soldier:
                    - if <player.has_flag[soldier_jail]>:
                        - flag server <player.flag[soldier_jail]>_soldiers:<-:<player>
                        - flag <player> soldier_jail:!
                - group remove <[job]>
                - narrate " <red> Job <yellow><[job]> <red>quit"
            - if <queue.player||null> != null && <queue.player> == <[username]>:
                - narrate "<green> DONE! Job(s) removed. Go ahead and pick a new career if you want!"
            - else:
                - narrate "<green> DONE! <yellow><[username].name> <green>job(s) has been removed."

Job_Script:
    type: world
    debug: false
    events:
        on lp command:
            - if <context.args.size> == 5:
                - if <context.args.get[1]> == user && <context.args.get[3]> == parent && <context.args.get[4]> == add:
                    - define username <server.match_offline_player[<context.args.get[2]>]||null>
                    - if <[username]> == null:
                        - stop
                    - adjust <queue> linked_player:<[username]>
                    - define group <context.args.get[5]>
                    - define validjobs <script[College_Config].data_key[job_groups]||null>
                    - if <[validjobs]> == null:
                        - narrate "<red>ERROR: The college config file used for the valid jobs has been corrupted!"
                        - narrate "<white>Please report this error to a higher rank or open a ticket in Discord."
                        - stop
                    - if <[validjobs].find[<[group]>]> == -1:
                        - stop
                    - define player_jobs <[validjobs].shared_contents[<player.groups>]>
                    - if <[player_jobs].is_empty>:
                        - stop
                    - foreach <[player_jobs]> as:job:
                        - if <player.in_group[<[job]>]>:
                            - if <[job]> == soldier:
                                - if <player.has_flag[soldier_jail]>:
                                    - flag server <player.flag[soldier_jail]>_soldiers:<-:<player>
                                    - flag <player> soldier_jail:!
                            - group remove <[job]>