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
                - determine <list[quit]>
            - case 1:
                - if "!<context.raw_args.ends_with[ ]>":
                    - determine <list[quit].filter[starts_with[<context.args.first>]]>
    script:
        - if <context.server>:
            - narrate "<red> ERROR: This command is only runnable by players!"
        - if <context.args.size> < 1:
            - narrate "<red> USAGE: <white>/job quit"
            - stop
        - define action <context.args.get[1]>
        - if <[action]> == quit:
            - define validjobs <script[College_Config].data_key[job_groups]||null>
            - if <[validjobs]> == null:
                - narrate "<red>ERROR: The college config file used for the valid jobs has been corrupted!"
                - narrate "<white>Please report this error to a higher rank or open a ticket in Discord."
                - stop
            - define player_jobs <[validjobs].shared_contents[<player.groups>]>
            - if <[player_jobs].is_empty>:
                - narrate "<red> ERROR: You don't have a valid job to quit"
                - stop
            - foreach <[player_jobs]> as:job:
                - if <player.in_group[<[job]>]>:
                    - if <[job]> == soldier:
                        - if <player.has_flag[soldier_jail]>:
                            - flag server <player.flag[soldier_jail]>_soldiers:<-:<player>
                            - flag <player> soldier_jail:!
                    - group remove <[job]>
                    - narrate " <red> Job <yellow><[job]> <red>quit"
            - narrate "<green> All valid jobs has been <red>removed"