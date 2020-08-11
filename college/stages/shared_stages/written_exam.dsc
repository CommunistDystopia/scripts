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
# /writtenexam [exam] - Starts an exam for a player.
# /exams <A|B|C|D|...> - Answers a question of an active exam.

Written_Exam_Task:
    type: task
    debug: false
    definitions: target
    script:
        - define data <script[<[target]>_Exam_Data]||null>
        - if <[data]> == null:
            - narrate "<red> ERROR: This exam doesn't exist. Be sure to type the correct name from the data file."
            - stop
        - if <player> == null:
            - narrate "<red> ERROR: Invalid player username OR the player is offline."
            - stop
        - if <player.has_flag[college_current_exam]> && !<player.flag[college_current_exam].contains_all_text[<[target]>]>:
            - narrate "<red> ERROR: You have a <yellow><player.flag[college_current_exam]> exam <red>active"
            - narrate "<white> Go back to your <yellow><player.flag[college_current_exam]> exam <white>room!"
            - stop
        - define question_list <[data].data_key[question_list]>
        - if !<player.has_flag[hasActiveWrittenExam]>:
            - flag <player> hasActiveWrittenExam:true
            - if !<player.has_flag[random_questions]>:
                - flag <player> random_questions:|:<[question_list].keys.random[9999]>
            - if !<player.has_flag[current_question_number]>:
                - flag <player> current_question_number:1
        - else:
            - narrate "<red> ERROR: Keep working on your exam. You already has an exam active."
            - stop
        - narrate "<yellow> # <[target].to_titlecase> Exam #"
        - narrate "<red> ============================================"
        - narrate "<green> Welcome future <yellow><[target]>"
        - narrate "<green> Each question in the exam have multiple options but one answer."
        - narrate "<green> To answer the questions in the exam use /exams [option]"
        - narrate "<red> ============================================"
        - define alphabet:|:A|B|C|D|E|F|G|H|I|J|K|L|M|N|O|P|Q|R|S|T|U|V|W|X|Y|Z
        - foreach <player.flag[random_questions].get[<player.flag[current_question_number]>].to[last]> as:question_number:
            - narrate "<yellow> <[loop_index]>. <white><[question_list].get[<[question_number]>].get[question]>"
            - flag <player> options_size:<[question_list].get[<[question_number]>].get[options].size>
            - flag <player> current_question_number:<[loop_index]>
            - flag <player> random_options:|:<[question_list].get[<[question_number]>].get[options].keys.random[9999]>
            - foreach <player.flag[random_options]> as:option:
                - narrate "<red> <[alphabet].get[<[loop_index]>]> -> <green><[option]>"
            - waituntil rate:1s !<player.is_online> || <player.has_flag[current_answer]>
            - if !<player.is_online>:
                - stop
            - define selected_option <[question_list].get[<[question_number]>].get[options].get[<player.flag[current_answer]>]||null>
            - if <[selected_option]> != null && !<[selected_option]>:
                - flag <player> current_answer:!
                - flag <player> hasActiveWrittenExam:!
                - flag <player> random_questions:!
                - flag <player> random_options:!
                - flag <player> current_question_number:!
                - teleport <player> <location[<player.flag[college_current_exam]>_college_spawn]>
                - flag <player> college_current_exam:!
                - cooldown 1m script:Command_College
                - narrate "<red> WRONG: <white>Try again the exam. Keep trying"
                - run Failed_College_Task def:<[target]>
                - stop
            - flag <player> random_options:!
            - flag <player> current_answer:!
            - narrate "<green> CORRECT: <white>Good job. Keep going!"
        - flag <player> hasActiveWrittenExam:!
        - flag <player> random_questions:!
        - flag <player> current_question_number:!
        - narrate "<red> Comrade<white>. Good job for passing the written exam"
        - if <[data].data_key[stages_config].size> > 1 && <script[<[target]>_Stages_Task]||null> != null::
            - flag <player> college_current_stage:++
            - execute as_player "college <[target]>"
        - else:
            - execute as_server "lp user <player.name> parent add <player.flag[college_current_exam]>"
            - teleport <player> <location[<player.flag[college_current_exam]>_college_spawn]>
            - narrate "<green> ! -> CONGRATULATIONS to <yellow><player.name> <green>for graduating as <yellow><player.flag[college_current_exam].to_titlecase>" targets:<server.online_players>
            - narrate "<green> ! -> <white>It's time to <red>work <white>and get some <green>money"
            - flag <player> college_current_exam:!

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
        - define selected_letter <[used_alphabet_letters].find[<[answer]>]>
        - if <[selected_letter]> == -1:
            - narrate "<red> ERROR: That option doesn't exist. Check the question options."
            - stop
        - flag <player> current_answer:<player.flag[random_options].get[<[selected_letter]>]>

Written_Exam_Script:
    type: world
    debug: false
    events:
        on player quits:
            - if <player.has_flag[hasActiveWrittenExam]>:
                - flag <player> hasActiveWrittenExam:!
                - wait 5m
                - if !<player.is_online>:
                    - flag <player> current_answer:!
                    - flag <player> random_questions:!
                    - flag <player> random_options:!
                    - flag <player> current_question_number:!
                    - flag <player> college_current_exam:!
