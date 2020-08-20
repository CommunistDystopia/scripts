# +----------------------
# |
# | SOLDIER STAGES
# |
# | [College] Soldier Exam
# |
# +----------------------
#
# @author devnodachi
# @date 2020/08/19
# @denizen-build REL-1714
# @dependency devnodachi/college
#

Soldier_Stages_Task:
    type: task
    debug: false
    script:
        - define stage 1
        - if <player.has_flag[college_current_stage]>:
            - define stage <player.flag[college_current_stage]>
        - else:
            - flag <player> college_current_stage:1
        - if <[stage]> > 1 && <location[soldier_stage_<[stage]>_spawn]||null> == null:
            - narrate " <red>ERROR: Spawn is not set for the <yellow>STAGE <[stage]><red> [SOLDIER]"
            - narrate " <white>Please report this error to a higher rank or open a ticket in Discord."
            - stop
        - if <[stage]> > 1 && <cuboid[soldier_stage_<[stage]>_player_zone]||null> == null:
            - narrate " <red>ERROR: Anti-teleport Zone is not set for the <yellow>STAGE <[stage]><red> [SOLDIER]"
            - narrate " <white>Please report this error to a higher rank or open a ticket in Discord."
            - stop
        - choose <[stage]>:
            - case 1:
                - narrate "<white> Welcome to the first stage of the university, future member of the <red>Peoples Army"
                - wait 1s
                - narrate "<white> Your written exam will start in <red>5 seconds..."
                - wait 5s
                - run Written_Exam_Task def:soldier
            - case 2:
                - run Soldier_Stage_2_Task
            - case 3:
                - run Soldier_Stage_3_Task
            - case 4:
                - run Soldier_Stage_4_Task

Soldier_Stages_Script:
    type: world
    debug: false
    events:
        on projectile hits block in:soldier_stage_2_shooting_zone:
            - if <server.has_flag[soldier_stage_2_players]>:
                - if <context.shooter||null> != null && <server.flag[soldier_stage_2_players].parse[uuid].filter[contains_all_case_sensitive_text[<context.shooter.uuid>]].size> == 1:
                    - if <context.location.material.name.contains_all_text[<script[Soldier_Exam_Data].data_key[stages_config].get[2].get[target_block]>]>:
                        - flag <context.shooter> soldier_stage_2_points:++
                        - define points_left_text "<green> POINTS LEFT: <yellow><player.flag[soldier_stage_2_points]>"
                        - sidebar set_line score:1 values:<[points_left_text]>
        on player exits soldier_stage_*_player_zone:
            - if !<player.is_op>:
                - inventory clear d:<player.inventory>
            - if <context.area.note_name.contains_all_text[soldier_stage_2_player_zone]>:
                - flag <player> soldier_stage_2_points:!
                - flag server soldier_stage_2_players:!
            - if <context.area.note_name.contains_all_text[soldier_stage_3_player_zone]>:
                - if <server.has_flag[soldier_stage_3_players]> && <server.flag[soldier_stage_3_players].parse[uuid].find[<player.uuid>]> != -1:
                    - adjust <player> collidable:true
                    - flag server soldier_stage_3_players:<-:<player>
                    - cooldown 1m script:Command_College
                    - narrate "<red> FAILED: <white>Try again the exam. Keep trying"
                    - teleport <player> <location[soldier_college_spawn]>
                    - run Failed_College_Task def:Soldier
            - if <context.area.note_name.contains_all_text[soldier_stage_4_player_zone]>:
                - flag server soldier_stage_4_players:!
        on player dies by:NPC:
            - if <server.has_flag[soldier_stage_4_players]>:
                - flag server soldier_stage_4_players:!
                - if !<player.is_op>:
                    - determine <list[]> passively
                - determine "<player.name> was killed by a Raider in the Soldier test"
        on player enters soldier_stage_*_parkour_zone:
            - if <server.has_flag[soldier_stage_3_players]> && <server.flag[soldier_stage_3_players].parse[uuid].find[<player.uuid>]> == 1:
                - flag server soldier_stage_3_players:<-:<player>
                - if <player.has_flag[college_current_stage]>:
                    - adjust <player> collidable:true
                    - flag <player> college_current_stage:++
                    - narrate "<red> Comrade<green>. Congratulations for passing the third stage"
                    - execute as_player "college soldier"

####################
## STAGE 2 - SCRIPTS
## SHOOTING ZONE
####################

Soldier_Stage_2_Task:
    type: task
    debug: false
    script:
        - if <cuboid[soldier_stage_2_shooting_zone]||null> == null:
            - narrate " <red>ERROR: The stage 2 Shooting Zone is not set [SOLDIER]"
            - narrate " <white>Please report this error to a higher rank or open a ticket in Discord."
            - stop
        - define time_remaining <script[Soldier_Exam_Data].data_key[stages_config].get[2].get[timer]||null>
        - define points <script[Soldier_Exam_Data].data_key[stages_config].get[2].get[points]||null>
        - define target_block <script[Soldier_Exam_Data].data_key[stages_config].get[2].get[target_block]||null>
        - define background_block <script[Soldier_Exam_Data].data_key[stages_config].get[2].get[background_block]||null>
        - if <[time_remaining]> == null || <[points]> == null || <[target_block]> == null || <[background_block]> == null:
            - narrate " <red>ERROR: The stage 2 config file has been corrupted! [SOLDIER]"
            - narrate " <white>Please report this error to a higher rank or open a ticket in Discord."
            - stop
        - if <server.has_flag[soldier_stage_2_players]>:
            - narrate "It seems that someone is currently doing that stage. Try again later"
            - stop
        - else:
            - flag server soldier_stage_2_players:|:<player>
        - teleport <player> <location[soldier_stage_2_spawn]>
        - if !<player.is_op>:
            - inventory clear d:<player.inventory>
        - give <crackshot.weapon[Desert_Eagle_CSP]> to:<player.inventory>
        - narrate "<white> Welcome to the second stage of the university, future member of the <red>Peoples Army"
        - define space " "
        - narrate "<white> To <green>PASS <white>this stage you need to <red>SHOOT <white>the <yellow><script[Soldier_Exam_Data].data_key[stages_config].get[2].get[target_block].to_titlecase.replace[_].with[<[space]>]> <red><[points]> TIMES <white> to <green>WIN!"
        - narrate "<white> If you <red>FAIL<white>, you will start again in this stage when you try again the exam."
        - wait 5s
        - flag <player> soldier_stage_2_points:0
        - repeat <[time_remaining]>:
            - if !<player.has_flag[soldier_stage_2_points]>:
                - repeat stop
            - define current_time <[value].sub[1]>
            - define time_remaining_text "<green> TIME REMAINING: <white><[time_remaining].sub[<[current_time]>]>"
            - define points_left_text "<green> POINTS: <yellow><player.flag[soldier_stage_2_points]>"
            - sidebar set "title:<white>== <yellow>STAGE 2: <white>Soldier Exam" values:<[time_remaining_text]>|<[points_left_text]> players:<player>
            - modifyblock <cuboid[soldier_stage_2_shooting_zone]> <[background_block]>|<[target_block]> 80|20
            - if <player.flag[soldier_stage_2_points]> >= <[points]>:
                - repeat stop
            - wait 1s
        - sidebar remove players:<player>
        - if !<player.is_op>:
            - inventory clear d:<player.inventory>
        - modifyblock <cuboid[soldier_stage_2_shooting_zone]> <[background_block]>
        - flag server soldier_stage_2_players:!
        - if !<player.has_flag[soldier_stage_2_points]> || <player.flag[soldier_stage_2_points]> < <[points]>:
            - flag <player> soldier_stage_2_points:!
            - teleport <player> <location[soldier_college_spawn]>
            - cooldown 1m script:Command_College
            - narrate "<red> FAILED: <white>Try again the exam. Keep trying"
            - run Failed_College_Task def:Soldier
            - stop
        - if <player.has_flag[college_current_stage]>:
            - flag <player> college_current_stage:++
        - flag <player> soldier_stage_2_points:!
        - narrate "<red> Comrade<green>. Congratulations for passing the second stage"
        - execute as_player "college soldier"

####################
## STAGE 3 - SCRIPTS
## PARKOUR
####################

Soldier_Stage_3_Task:
    type: task
    debug: false
    script:
        - define parkour_zone <cuboid[soldier_stage_3_parkour_zone]||null>
        - if <[parkour_zone]> == null:
            - narrate " <red>ERROR: The stage 3 Parkour Zone is not set [SOLDIER]"
            - narrate " <white>Please report this error to a higher rank or open a ticket in Discord."
            - stop
        - teleport <player> <location[soldier_stage_3_spawn]>
        - adjust <player> collidable:false
        - if <server.has_flag[soldier_stage_3_players]>:
            - if <server.flag[soldier_stage_3_players].parse[uuid].find[<player.uuid>]> == -1:
                - flag server soldier_stage_3_players:|:<player>
        - else:
            - flag server soldier_stage_3_players:|:<player>
        - narrate "<white> Welcome to the third stage of the university, future member of the <red>Peoples Army"
        - narrate "<white> To <green>PASS <white>you need to complete the <yellow>PARKOUR"
        - narrate "<white> If you <red>LEAVE<white>, you will start again in this stage when you try again the exam."

####################
## STAGE 4 - SCRIPTS
## ARENA
####################

Soldier_Stage_4_Task:
    type: task
    debug: false
    script:
        - define npc_amount <script[Soldier_Exam_Data].data_key[stages_config].get[4].get[npc_amount]||null>
        - define npc_weapon <script[Soldier_Exam_Data].data_key[stages_config].get[4].get[npc_weapon]||null>
        - define spawn_distance <script[Soldier_Exam_Data].data_key[stages_config].get[4].get[spawn_distance]||null>
        - define player_weapon <script[Soldier_Exam_Data].data_key[stages_config].get[4].get[player_weapon]||null>
        - define time_remaining <script[Soldier_Exam_Data].data_key[stages_config].get[4].get[timer]||null>
        - if <[npc_amount]> == null || <[npc_weapon]> == null || <[spawn_distance]> == null || <[player_weapon]> == null || <[time_remaining]> == null:
            - narrate " <red>ERROR: The stage 4 config file has been corrupted! [SOLDIER]"
            - narrate " <white>Please report this error to a higher rank or open a ticket in Discord."
            - stop
        - if <server.has_flag[soldier_stage_4_players]>:
            - narrate "It seems that someone is currently doing that stage. Try again later"
            - stop
        - else:
            - flag server soldier_stage_4_players:|:<player>
        - if !<server.has_flag[soldier_stage_4_npcs]>:
            - repeat <[npc_amount]>:
                - create player Raider save:raider
                - wait 1T
                - equip <entry[raider].created_npc> hand:<[npc_weapon]>
                - wait 1T
                - adjust <entry[raider].created_npc> speed:<util.random.decimal[1.2].to[1.4]>
                - wait 1T
                - trait npc:<entry[raider].created_npc> state:true sentinel
                - execute as_server "sentinel addtarget player --id <entry[raider].created_npc.id>" silent
                - execute as_server "sentinel respawntime 0 --id <entry[raider].created_npc.id>" silent
                - execute as_server "sentinel safeshot true --id <entry[raider].created_npc.id>" silent
                - execute as_server "sentinel addignore npc --id <entry[raider].created_npc.id>" silent
                - flag server soldier_stage_4_npcs:|:<entry[raider].created_npc.as_npc>
            - wait 1s
        - if !<player.is_op>:
            - inventory clear d:<player.inventory>
        - teleport <player> <location[soldier_stage_4_spawn]>
        - narrate "<white> Welcome to the fourth stage of the university, future member of the <red>Peoples Army"
        - narrate "<white> To <green>PASS <white>you need to survive against the <red>RAIDERS <white>for a given time"
        - narrate "<white> If you <red>FAIL<white>, you will start again in this stage when you try again the exam."
        - wait 3s
        - give <[player_weapon]> to:<player.inventory>
        - foreach <server.flag[soldier_stage_4_npcs]> as:npc:
            - define spawn_tries:3
            - while !<[npc].is_spawned> && <[spawn_tries]> > 0:
                - random:
                    - if <player.location.add[<[spawn_distance]>,0,0].material.name> == AIR && <player.location.add[<[spawn_distance]>,0,0].above.material.name> == AIR:
                        - adjust <[npc]> spawn:<player.location.add[<[spawn_distance]>,0,0]>
                    - if <player.location.sub[<[spawn_distance]>,0,0].material.name> == AIR && <player.location.sub[<[spawn_distance]>,0,0].above.material.name> == AIR:
                        - adjust <[npc]> spawn:<player.location.sub[<[spawn_distance]>,0,0]>
                    - if <player.location.add[0,0,<[spawn_distance]>].material.name> == AIR && <player.location.add[0,0,<[spawn_distance]>].above.material.name> == AIR:
                        - adjust <[npc]> spawn:<player.location.add[0,0,<[spawn_distance]>]>
                    - if <player.location.sub[0,0,<[spawn_distance]>].material.name> == AIR && <player.location.sub[0,0,<[spawn_distance]>].above.material.name> == AIR:
                        - adjust <[npc]> spawn:<player.location.sub[0,0,<[spawn_distance]>]>
                    - if <player.location.add[<[spawn_distance]>,0,<[spawn_distance]>].material.name> == AIR && <player.location.add[<[spawn_distance]>,0,<[spawn_distance]>].above.material.name> == AIR:
                        - adjust <[npc]> spawn:<player.location.add[<[spawn_distance]>,0,<[spawn_distance]>]>
                    - if <player.location.sub[<[spawn_distance]>,0,<[spawn_distance]>].material.name> == AIR && <player.location.sub[<[spawn_distance]>,0,<[spawn_distance]>].above.material.name> == AIR:
                        - adjust <[npc]> spawn:<player.location.sub[<[spawn_distance]>,0,<[spawn_distance]>]>
                - wait 1T
                - adjust <[NPC]> skin_blob:eyJ0aW1lc3RhbXAiOjE1ODU2MDUyODM5NjAsInByb2ZpbGVJZCI6IjkxZmUxOTY4N2M5MDQ2NTZhYTFmYzA1OTg2ZGQzZmU3IiwicHJvZmlsZU5hbWUiOiJoaGphYnJpcyIsInNpZ25hdHVyZVJlcXVpcmVkIjp0cnVlLCJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvOGM2NWQ4OTdlNWRkNzdiZjgxYTNjZjhkZTllMWQxMmRlYTI1NmU4MWE5ZjcxMTBhYmNhMzU2NjkyYTE3MDNhYSJ9fX0=;XJotIjWxKr+So/pSF3wOmWext7giPtdhh2IoJVOoy4lLE3w88MwM+JWUBnsDQud2EAjX2P9NFOtGb/7Mat22w0nqoMezQlR5CmN3857MWz/JeMV7N+JvZWya9HsyWv6Wermo+4wl+XK6R8cqoeHC+mIIceKLyz4pytb4biklFPoII6MLbPuQKCSWrxKQ/3oByZokHqRv7ArxOysUVlJurpOsYT7vfJUATgHn9c23f/A3Gh2O5QJ9fYZ5/6ybqJAEocOEZbnZ+vTGNqMVztwYN+7fx1cAbfLl0SYXoG2oX12aJWWw4mXt5U1nsTw7+M5ZqTjo5zBMhpztIS5ds76alD1oWu0ni6kbKmVsm7Pv1U8Fg1Bptp1fVZq2T9d/+Dx+uZy7Gp/oX4HFtn3g9NraPdPkyKPgVsn23BL9scUek2iLrRZC5OamTVtszUHfkSDfCwr9r0bipNkfBE+FidooaT6qbiOXGrztp6CIUP457qVg/3BWxVYdn9tOX3C9lt2mvpADVKuCDrvoVDfOSx811V0MECpYejaXzCDy0xy/iSASpgz0V6CAmfSIXtvTWo8xwX6VGLDSHfT3pdjUOju3sKvg0VuQtk/gEadn9quMgw4FS/hiJ4wHkzNR2cdOwWFYVzcxHsWsOO9GIHTZCkCDNsGvkCX0mrxZ3Rokw54WzO4=;http://textures.minecraft.net/texture/8c65d897e5dd77bf81a3cf8de9e1d12dea256e81a9f7110abca356692a1703aa
                - wait 1T
            - attack <[npc]> target:<player>
        - repeat <[time_remaining]>:
            - define current_time <[value].sub[1]>
            - define time_remaining_text "<green> TIME REMAINING: <white><[time_remaining].sub[<[current_time]>]>"
            - sidebar set "title:<white>== <yellow>STAGE 4: <white>Soldier Exam" values:<[time_remaining_text]> players:<player>
            - if !<server.has_flag[soldier_stage_4_players]>:
                - repeat stop
            - wait 1s
        - sidebar remove players:<player>
        - despawn <server.flag[soldier_stage_4_npcs]>
        - if !<server.has_flag[soldier_stage_4_players]>:
            - teleport <player> <location[soldier_college_spawn]>
            - cooldown 1m script:Command_College
            - narrate "<red> FAILED: <white>Try again the exam. Keep trying"
            - run Failed_College_Task def:Soldier
            - stop
        - flag server soldier_stage_4_players:!
        - if <player.has_flag[college_current_stage]>:
            - flag <player> college_current_stage:!
        - teleport <player> <location[soldier_college_spawn]>
        - run Soldier_College_Reward_Task

####################
## STAGE 4 - SCRIPTS
## ARENA
####################

Soldier_College_Reward_Task:
    type: task
    debug: false
    script:
        - execute as_server "lp user <player.name> parent add <player.flag[college_current_exam]>"
        - teleport <player> <location[<player.flag[college_current_exam]>_college_spawn]>
        - narrate "<green> ! -> CONGRATULATIONS to <yellow><player.name> <green>for graduating as <yellow><player.flag[college_current_exam].to_titlecase>" targets:<server.online_players>
        - narrate "<green> ! -> <white>It's time to <red>work <white>and get some <green>money"
        - flag <player> college_current_exam:!