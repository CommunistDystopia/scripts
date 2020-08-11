Soldier_Exam_Data:
    type: data
    stages_config:
        1: none
        2:
            ## Shooting Area
            # You need to set the shooting area with
            # /admincollege soldier set custom zone
            # Which block the player will shoot?
            target_block: white_wool
            # What is the other block that the shooting area will have?
            # The shooting area needs to have two types of block to work
            background_block: yellow_terracotta
            # How much time (seconds) the stage will last?
            timer: 30
            # How many points the players should archieve to pass?
            points: 12
        3: none
            ## Parkour
            # You need to set the parkour area with
            # /admincollege soldier set custom zones
        4:
            ## NPC Arena
            # How many NPCS will spawn?
            npc_amount: 4
            # The distance that the NPCs will spawn from the player
            spawn_distance: 4
            # How much time the player need to survive to pass?
            timer: 60
            # Which weapon the NPC will have?
            # run /ex flag server soldier_stage_3_npcs:!
            # and /ex reload
            # to change the weapon
            npc_weapon: stone_sword
            # Which weapon the Player will have?
            player_weapon: iron_sword
    ## Questions
    # Use true for the correct answer (can be more than one)
    # Use false for the others
    question_list:
        1:
            question: How do you make someone wanted?
            options:
                /wanted username: false
                /soldiers wanted add username: true
                Put it in announcements: false
                Ask an HR to announce it in public resources: false
        2:
            question: How do you track someone down the fastest?
            options:
                /compass username: false
                /compass username then holding a compass follow the arrows to track them: true
                Follow them on the dynmap: false
                Follow their coordinates: false
        3:
            question: What do you do after you arrest someone?
            options:
                Continue your patrol: false
                Write a report on the incident in report channel in the barracks category within the discord: true
                You take them to jail: false
                Write a report on your thumb: false
        4:
            question: What are regional laws?
            options:
                Laws that apply to everyone: false
                Laws that apply to mayors: true
                Laws that apply to everyone in a province: false
                Laws that apply to people within a town: false
        5:
            question: What are local laws?
            options:
                Laws that apply to everyone: false
                Laws that apply only anyone in a town: true
                Laws that apply to everyone in a province: false
                Laws that apply to mayors: false
        6:
            question: What are federal laws?
            options:
                Laws that apply to the federal government: false
                Laws that apply to everyone: true
                Laws that apply to everyone in a province: false
                Laws that apply to mayors: false
        7:
            question: Do you arrest people who break local laws?
            options:
                Never: false
                Only if there is a arrest warrant for the suspect: true
                Yes: false
                Depends on the punishment listed for the local law: false
        8:
            question: What do you do if you witness another soldier abusing?
            options:
                Nothing: false
                Report it to an admin: true
                Report it to a high rank in the military: false
                Arrest the soldier abusing: false
        9:
            question: When would you write a report?
            options:
                When something illegal happens: false
                All answers are correct: true
                When someone reports a crime: false
                When someone is acting suspicious: false
                When someone says something that can be used in court against them: false
        10:
            question: What is the punishment for abusing as a soldier?
            options:
                Off to labor camp: false
                It can range from time in jail to ban depending on the situation: true
                A warning followed by a blacklist from the military: false
                A warning: false
        11:
            question: How do you get promoted as a soldier?
            options:
                Activity: false
                Activity, loyalty, discipline and being in the discord: true
                Being good at combat and being active: false
                Being good at combat and spending a long time in the military: false
