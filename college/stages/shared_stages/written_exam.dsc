# +----------------------
# |
# | WRITTEN EXAM
# |
# | Challenge your knowledge
# |
# +----------------------
#
# @author devnodachi
# @date 2020/08/10
# @denizen-build REL-1714
# @dependency devnodachi/college
#
# Commands
# /writtenexam [exam] [username] - Starts an exam for a player.
# /exams <A|B|C|D|...> - Answers a question of an active exam.

Command_Written_Exam:
    type: command
    debug: false
    name: writtenexam
    description: Minecraft Written Exam system.
    usage: /writtenexam
    script:
        - if !<player.is_op||<context.server>>:
            - narrate "<red>You do not have permission for that command."
            - stop
        - if <context.args.size> < 2:
            - narrate "<yellow>#<red> ERROR: Not enough arguments. Follow the command syntax."
            - stop
        - define target <context.args.get[1]>
        - define data <script[<[target]>_Exam_Data]||null>
        - if <[data]> == null:
            - narrate "<red> ERROR: This exam doesn't exist. Be sure to type the correct name from the data file."
            - stop
        - define username <server.match_player[<context.args.get[2]>]||null>
        - if <[username]> == null:
            - narrate "<red> ERROR: Invalid player username OR the player is offline."
            - stop
        - if !<script.cooled_down[<[username]>]>:
            - narrate "<red> ERROR: You failed the exam recently. Wait <yellow><script.cooldown.in_seconds.truncate> seconds <red>before trying again." targets:<[username]>
            - stop
        - if <[username].has_flag[college_current_exam]> && !<[username].flag[college_current_exam].contains_all_text[<[target]>]>:
            - narrate "<red> ERROR: You have a <yellow><[username].flag[college_current_exam]> exam <red>active" targets:<[username]>
            - narrate "<white> Go back to your <yellow><[username].flag[college_current_exam]> exam <white>room!" targets:<[username]>
            - stop
        - if !<[username].has_flag[hasActiveWrittenExam]>:
            - flag <[username]> hasActiveWrittenExam:true
            - if !<[username].has_flag[current_question_number]>:
                - flag <[username]> current_question_number:1
        - else:
            - narrate "<red> ERROR: Keep working on your exam. You already has an exam active." targets:<[username]>
            - stop
        - narrate "<yellow> # <[target].to_titlecase> Exam #" targets:<[username]>
        - narrate "<red> ============================================" targets:<[username]>
        - narrate "<green> Welcome future <yellow><[target]>" targets:<[username]>
        - narrate "<green> Each question in the exam have multiple options but one answer." targets:<[username]>
        - narrate "<green> To answer the questions in the exam use /exams [option]" targets:<[username]>
        - narrate "<red> ============================================" targets:<[username]>
        - define question_list <[data].data_key[question_list]>
        - foreach <[question_list].keys.get[<[username].flag[current_question_number]>].to[last]> as:question_number:
            - narrate "<yellow> <[question_number]>. <white><[question_list].get[<[question_number]>].get[question]>" targets:<[username]>
            - flag <[username]> options_size:<[question_list].get[<[question_number]>].get[options].size>
            - flag <[username]> current_question_number:<[loop_index]>
            - foreach <[question_list].get[<[question_number]>].get[options]> as:option:
                - narrate "<red> <[key]> -> <green><[option]>" targets:<[username]>
            - waituntil rate:1s !<[username].is_online> || <[username].has_flag[current_answer]>
            - if !<[username].is_online>:
                - stop
            - if !<[question_list].get[<[question_number]>].get[answer].contains_all_case_sensitive_text[<[username].flag[current_answer]>]>:
                - flag <[username]> current_answer:!
                - flag <[username]> hasActiveWrittenExam:!
                - flag <[username]> current_question_number:!
                - if <server.has_flag[college_stage_1_players]>:
                    - flag server college_stage_1_players:<-:<[username]>
                - teleport <[username]> <location[<[username].flag[current_exam]>_college_spawn]>
                - narrate "<red> WRONG: <white>Try again the exam. Keep trying" targets:<[username]>
                - stop
            - flag <[username]> current_answer:!
            - narrate "<green> CORRECT: <white>Good job. Keep going!" targets:<[username]>
        - if <[username].has_flag[college_current_stage]>:
            - flag <[username]> college_current_stage:++
        - if <server.has_flag[college_stage_1_players]>:
            - flag server college_stage_1_players:<-:<[username]>
        - flag <[username]> hasActiveWrittenExam:!
        - flag <[username]> current_question_number:!
        - narrate "<red> Comrade<green>. Congratulations for passing the written exam" targets:<[username]>
        - narrate "<white> Go to the <red>SIGN<white>, <red>RIGHT CLICK IT <white>to start the <red>NEXT STAGE" targets:<[username]>

Command_Exams:
    type: command
    debug: false
    name: exams
    description: Minecraft (Answer) Written Exam system.
    usage: /exams
    script:
        - if <context.args.size> < 1:
            - narrate "<yellow>#<red> ERROR: Not enough arguments. Follow the command syntax:"
            - narrate "<yellow>-<red> To answer an exam question: <white>/exams <yellow>[option]"
            - stop
        - if !<player.has_flag[hasActiveWrittenExam]> && !<player.flag[options_size]>:
            - narrate "<red> ERROR: You are not doing a exam."
            - stop
        - define answer <context.args.get[1]>
        - define alphabet:|:A|B|C|D|E|F|G|H|I|J|K|L|M|N|O|P|Q|R|S|T|U|V|W|X|Y|Z
        - define used_alphabet_letters <[alphabet].get[1].to[<player.flag[options_size]>]>
        - if <[used_alphabet_letters].find[<[answer]>]> == -1:
            - narrate "<red> ERROR: That option doesn't exist. Check the question options."
            - stop
        - flag <player> current_answer:<[answer].to_uppercase>

Written_Exam_Script:
    type: world
    debug: false
    events:
        on player quits:
            - if <player.has_flag[hasActiveWrittenExam]>:
                - flag <player> hasActiveWrittenExam:!