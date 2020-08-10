# +----------------------
# |
# | SOLDIER STAGES
# |
# | [College] Soldier Exam
# |
# +----------------------
#
# @author devnodachi
# @date 2020/08/10
# @denizen-build REL-1714
# @dependency devnodachi/college
#

Soldier_Stages_Task:
    type: task
    debug: false
    definitions: username
    script:
        - define stage 1
        - if <[username].has_flag[college_current_stage]>:
            - define stage <[username].flag[college_current_stage]>
        - else:
            - flag <[username]> college_current_stage:1
        - if <[stage]> > 1 && <location[soldier_stage_<[stage]>_spawn]||null> == null:
            - narrate " <red>ERROR: Spawn is not set for the <yellow>STAGE <[stage]><red> [SOLDIER]" targets:<[username]>
            - narrate " <white>Please report this error to a higher rank or open a ticket in Discord." targets:<[username]>
            - stop
        - if <[stage]> > 1 && <cuboid[soldier_stage_<[stage]>_player_zone]||null> == null:
            - narrate " <red>ERROR: Anti-teleport Zone is not set for the <yellow>STAGE <[stage]><red> [SOLDIER]" targets:<[username]>
            - narrate " <white>Please report this error to a higher rank or open a ticket in Discord." targets:<[username]>
            - stop
        - choose <[stage]>:
            - case 1:
                - if <server.has_flag[college_stage_1_players]>:
                    - if <server.flag[college_stage_1_players].parse[uuid].find[<[username].uuid>]> == -1:
                        - flag server college_stage_1_players:|:<[username]>
                - else:
                    - flag server college_stage_1_players:|:<[username]>
                - teleport <[username]> <location[college_stage_1_spawn]>
                - narrate "<white> Welcome to the first stage of the college, future member of the <red>Peoples Army" targets:<[username]>
                - wait 1s
                - narrate "<white> Your written exam will start in <red>5 seconds..."
                - wait 5s
                - execute as_server "writtenexam soldier <[username].name>" silent
            - case 2:
                - run Soldier_Stage_2_Task def:<[username]>

####################
## STAGE 2 - SCRIPTS
## SHOOTING ZONE
####################

Soldier_Stage_2_Task:
    type: task
    debug: false
    definitions: username
    script:
        - if <cuboid[soldier_stage_2_shooting_zone]||null> == null:
            - narrate " <red>ERROR: Shooting Zone is not set for this stage [SOLDIER]" targets:<[username]>
            - narrate " <white>Please report this error to a higher rank or open a ticket in Discord." targets:<[username]>
            - stop
        - if <server.has_flag[soldier_stage_2_players]>:
            - narrate "It seems that someone is currently doing that stage. Try again in a few seconds" targets:<[username]>
            - stop
        - else:
            - flag server soldier_stage_2_players:|:<[username]>
        - teleport <[username]> <location[soldier_stage_2_spawn]>
        - inventory clear d:<[username].inventory>
        - give <crackshot.weapon[Desert_Eagle_CSP]> to:<[username].inventory>
        - narrate "<white> Welcome to the second stage of the college, future member of the <red>Peoples Army" targets:<[username]>
        - define space " "
        - narrate "<white> To <green>PASS <white>this stage you need to <red>SHOOT <white>the <yellow><script[Soldier_Exam_Data].data_key[stages_config].get[2].get[target_block].to_titlecase.replace[_].with[<[space]>]> <white>to lower the <green>POINTS <white>in the right side" targets:<[username]>
        - narrate "<white> When you hit the block, the <green>POINTS <white>will decrease by 1." targets:<[username]>
        - narrate "<white> If you <red>FAIL<white>, you will start again in this stage when you try again the exam." targets:<[username]>
        - wait 3s
        - narrate "<green> The stage will start in <red>10 seconds<green>..." targets:<[username]>
        - wait 10s
        - define time_remaining <script[Soldier_Exam_Data].data_key[stages_config].get[2].get[timer]>
        - define points_left <script[Soldier_Exam_Data].data_key[stages_config].get[2].get[points]>
        - define target_block <script[Soldier_Exam_Data].data_key[stages_config].get[2].get[target_block]>
        - define background_block <script[Soldier_Exam_Data].data_key[stages_config].get[2].get[background_block]>
        - flag <[username]> soldier_stage_2_points_left:<[points_left]>
        - repeat <[time_remaining]>:
            - define current_time <[value].sub[1]>
            - define time_remaining_text "<green> TIME REMAINING: <white><[time_remaining].sub[<[current_time]>]>"
            - define points_left_text "<green> POINTS: <yellow><[username].flag[soldier_stage_2_points_left]>"
            - sidebar set "title:<white>== <yellow>STAGE 2: <white>Soldier Exam" values:<[time_remaining_text]>|<[points_left_text]> players:<[username]>
            - modifyblock <cuboid[soldier_stage_2_shooting_zone]> <[background_block]>|<[target_block]> 80|20
            - if <[username].flag[soldier_stage_2_points_left]> == 0:
                - repeat stop
            - wait 1s
        - sidebar remove players:<[username]>
        - inventory clear d:<[username].inventory>
        - modifyblock <cuboid[soldier_stage_2_shooting_zone]> <[background_block]>
        - flag server soldier_stage_2_players:!
        - if <[username].flag[soldier_stage_2_points_left]> > 0:
            - flag <[username]> soldier_stage_2_points_left:!
            - teleport <[username]> <location[soldier_college_spawn]>
            - narrate "<red> FAILED: <white>Try again the exam. Keep trying" targets:<[username]>
            - stop
        - if <[username].has_flag[college_current_stage]>:
            - flag <[username]> college_current_stage:++
        - flag <[username]> soldier_stage_2_points_left:!
        - narrate "<red> Comrade<green>. Congratulations for passing the second stage" targets:<[username]>
        - narrate "<white> Go to the <red>SIGN<white>, <red>RIGHT CLICK IT <white>to start the <red>NEXT STAGE" targets:<[username]>

Soldier_Stage_2_Script:
    type: world
    debug: false
    events:
        on projectile hits block in:soldier_stage_2_shooting_zone:
            - if <server.has_flag[soldier_stage_2_players]>:
                - if <context.shooter||null> != null && <server.flag[soldier_stage_2_players].parse[uuid].filter[contains_all_case_sensitive_text[<context.shooter.uuid>]].size> == 1:
                    - if <context.location.material.name.contains_all_text[<script[Soldier_Exam_Data].data_key[stages_config].get[2].get[target_block]>]>:
                        - flag <context.shooter> soldier_stage_2_points_left:--
                        - define points_left_text "<green> POINTS LEFT: <yellow><player.flag[soldier_stage_2_points_left]>"
                        - sidebar set_line score:1 values:<[points_left_text]>