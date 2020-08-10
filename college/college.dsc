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
        - if !<player.is_op||<context.server>>:
            - narrate "<red>You do not have permission for that command."
            - stop
        - if <context.args.size> < 2:
            - narrate "<yellow>#<red> ERROR: Not enough arguments. Follow the command syntax."
            - stop
        - define target <context.args.get[1]>
        - define username <server.match_player[<context.args.get[2]>]||null>
        - if <[username]> == null:
            - narrate "<red> ERROR: Invalid player username OR the player is offline."
            - stop
        - if <script[<[target]>_Stages_Task]||null> != null:
            - if <location[college_stage_1_spawn]||null> == null:
                - narrate " <red>ERROR: Spawn is not set for the <yellow>STAGE 1<red> [COLLEGE]" targets:<[username]>
                - narrate " <white>Please report this error to a higher rank or open a ticket in Discord." targets:<[username]>
                - stop
            - if <cuboid[college_stage_1_player_zone]||null> == null:
                - narrate " <red>ERROR: Anti-teleport Zone is not set for the <yellow>STAGE 1<red> [COLLEGE]" targets:<[username]>
                - narrate " <white>Please report this error to a higher rank or open a ticket in Discord." targets:<[username]>
                - stop
            - if <location[<[target]>_college_spawn]||null> == null:
                - narrate " <red>ERROR: Spawn is not set for the <yellow><[target]> <red>in the college." targets:<[username]>
                - narrate " <white>Please report this error to a higher rank or open a ticket in Discord." targets:<[username]>
                - stop
            - if !<[username].has_flag[college_current_exam]>:
                - flag <[username]> current_exam:<[target]>
            - run <[target]>_Stages_Task def:<[username]>

College_Script:
    type: world
    debug: false
    events:
        on player enters *_stage_*_player_zone:
            - define allowed_players <context.area.note_name.before[_zone]>s
            - if <server.has_flag[<[allowed_players]>]>:
                - if <server.flag[<[allowed_players]>].parse[uuid].find[<player.uuid>]> != -1:
                    - stop
            - if <context.cause> == TELEPORT:
                - determine cancelled