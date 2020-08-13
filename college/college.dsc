# +----------------------
# |
# | COLLEGE
# |
# | Time to get a job!
# |
# +----------------------
#
# @author devnodachi
# @date 2020/08/10
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
        - if !<player.is_op||<context.server>> && !<player.in_group[student]>:
            - narrate "<red>You do not have permission for that command."
            - stop
        - if <context.args.size> < 1:
            - narrate "<yellow>#<red> ERROR: Not enough arguments. Follow the command syntax."
            - stop
        - if !<player.is_op>:
            - define job_groups <script[College_Config].data_key[job_groups]||null>
            - if <[job_groups]> == null:
                - narrate " <red>ERROR: The college config file has been corrupted!"
                - narrate " <white>Please report this error to a higher rank or open a ticket in Discord."
                - stop
            - if !<[job_groups].shared_contents[<player.groups>].is_empty>:
                - narrate "<red> You already have a job. Only players without a job can enter the college"
                - stop
        - define target <context.args.get[1]>
        - if <player.has_flag[criminal_record]>:
            - narrate "<red> You have a criminal record, you can't a take an exam"
            - stop
        - if !<script.cooled_down[<player>]>:
            - narrate "<red> ERROR: <white>You failed a exam recently. Wait <yellow><script.cooldown.in_seconds.truncate> seconds <white>before trying again."
            - stop
        - define data <script[<[target]>_Exam_Data]||null>
        - if <[data]> == null:
            - narrate "<red> ERROR: The <[target]> exam doesn't exist."
            - narrate "<white> Be sure that the first line in your config file is <[target].to_titlecase>_Exam_Data:" targets:<player>
            - stop
        - if <location[<[target]>_college_spawn]||null> == null:
            - narrate " <red>ERROR: Spawn is not set for the <yellow><[target]> <red>in the college." targets:<player>
            - narrate " <white>Please report this error to a higher rank or open a ticket in Discord." targets:<player>
            - stop
        - if !<player.has_flag[college_current_exam]>:
            - flag <player> college_current_exam:<[target]>
        - if <[data].data_key[stages_config].size> > 1 && <script[<[target]>_Stages_Task]||null> != null:
            - run <[target]>_Stages_Task
            - stop
        - narrate "<white> Welcome to the written test, future <red><[target].to_titlecase>" targets:<player>
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
            - flag <player> college_lock_timer:<script[College_Config].data_key[college_lock_timer]>
        on system time minutely:
            - if <player.has_flag[college_lock_timer]>:
                - flag <player> college_lock_timer:-:1
                - if <player.flag[college_lock_timer]> <= 0:
                    - flag <player> college_lock_timer:!

Failed_College_Task:
    type: task
    debug: false
    definitions: target
    script:
        - if !<script.cooled_down[<player>]>:
            - stop
        - narrate "<red> ! -> <yellow><player.name> <red>FAILED <white>the <red>TEST <white>for <yellow><[target].to_uppercase>" targets:<server.online_players>
        - cooldown 10m script:Failed_College_Task