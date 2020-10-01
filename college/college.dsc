# +----------------------
# |
# | COLLEGE
# |
# | Time to get a job!
# |
# +----------------------
#
# @author devnodachi
# @date 2020/09/12
# @denizen-build REL-1714
# @soft-dependency devnodachi/criminal_record
#
# Commands
# /college [exam] [username] - Starts or resumes an exam for that username.

Command_College:
    type: command
    debug: false
    name: college
    description: Minecraft College system.
    usage: /college
    script:
        - if <context.args.size> < 1:
            - narrate "<red> ERROR: Not enough arguments. <white>Follow the command syntax: <yellow>/college [exam]"
            - stop
        - define target <context.args.get[1]>
        - if <[target]> == soldier
        - if !<player.is_op||<context.server>>:
            - if <[target]> == soldier && !<player.in_group[conscript]>:
                - narrate "<red>You do not have permission for that command."
                - stop
            - if <[target]> != soldier && !<player.in_group[student]>:
                - narrate "<red>You do not have permission for that command."
                - stop
        - if !<server.has_file[data/college/config.yml]>:
            - narrate "<red> ERROR: <white>The config file of the college is missing."
            - narrate "<white> Please report this error to a higher rank or open a ticket in Discord."
            - stop
        - if !<player.is_op> && !<player.in_group[conscript]>:
            - ~yaml load:data/college/config.yml id:college_data
            - if !<yaml[college_data].read[job_groups].shared_contents[<player.groups>].is_empty>:
                - narrate "<red> You already have a job. Only players without a job can enter the college"
                - stop
            - yaml unload id:college_data
        - if <player.has_flag[criminal_record]>:
            - narrate "<red> You have a criminal record, you can't a take an exam"
            - stop
        - if !<script.cooled_down[<player>]>:
            - narrate "<red> ERROR: <white>You failed a exam recently. Wait <yellow><script.cooldown.in_seconds.truncate> seconds <white>before trying again."
            - stop
        - if !<server.has_file[data/college/<[target]>.yml]>:
            - narrate "<red> ERROR: <white>The exam <red><[target]> <white>doesn't exist."
            - stop
        - ~yaml load:data/college/<[target]>.yml id:<[target]>_data
        - if <location[<[target]>_college_spawn]||null> == null:
            - narrate "<red> ERROR: Spawn is not set for the <yellow><[target]> <red>in the college."
            - narrate "<white> Please report this error to a higher rank or open a ticket in Discord."
            - stop
        - if !<player.has_flag[college_current_exam]>:
            - flag <player> college_current_exam:<[target]>
        - if <yaml[<[target]>_data].read[stages_config].size> > 1 && <script[<[target]>_Stages_Task]||null> != null:
            - run <[target]>_Stages_Task
            - stop
        - narrate "<white> Welcome to the written test, future <red><[target].to_titlecase>"
        - wait 1s
        - narrate "<white> Your written exam will start in <red>5 seconds..."
        - wait 5s
        - run Written_Exam_Task def:<[target]>

College_Script:
    type: world
    debug: false
    events:
        on player enters *_stage_*_player_zone:
            - if <player.is_op> || <context.cause> != TELEPORT:
                - stop
            - if <player.has_flag[college_current_stage]>:
                - if <player.flag[college_current_stage]> > 1 && <context.area.note_name.ends_with[_stage_2_player_zone]>:
                    - stop
                - if <player.flag[college_current_stage]> > 2 && <context.area.note_name.ends_with[_stage_3_player_zone]>:
                    - stop
                - if <player.flag[college_current_stage]> > 3 && <context.area.note_name.ends_with[_stage_4_player_zone]>:
                    - stop
            - define allowed_players <context.area.note_name.before[_zone]>s
            - if <server.has_flag[<[allowed_players]>]>:
                - if <server.flag[<[allowed_players]>].parse[uuid].find[<player.uuid>]> != -1:
                    - stop
            - determine cancelled
        on entity prespawns because NATURAL in:*_stage_*_player_zone:
            - if <entity.is_npc||null> != null && <entity.is_npc>:
                - stop
            - determine cancelled
        after player logs in for the first time:
            - if <server.has_file[data/college/config.yml]>:
                - ~yaml load:data/college/config.yml id:college_data
                - flag <player> college_lock_timer:<yaml[college_data].read[college_lock_timer]>
        on system time minutely:
            - foreach <server.online_players> as:server_player:
                - if <[server_player].has_flag[college_lock_timer]>:
                    - flag <[server_player]> college_lock_timer:-:1
                    - if <[server_player].flag[college_lock_timer]> <= 0:
                        - flag <[server_player]> college_lock_timer:!

Failed_College_Task:
    type: task
    debug: false
    definitions: target
    script:
        - if !<script.cooled_down[<player>]>:
            - stop
        - narrate "<red> ! -> <yellow><player.name> <red>FAILED <white>the <red>TEST <white>for <yellow><[target].to_uppercase>" targets:<server.online_players>
        - cooldown 10m script:Failed_College_Task