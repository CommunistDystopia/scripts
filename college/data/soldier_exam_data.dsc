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
            timer: 10
            # How many points the players should archieve to pass?
            points: 1
        3: none
            ## Parkour
            # You need to set the parkour area with
            # /admincollege soldier set custom zones
        4:
            ## NPC Arena
            # How many NPCS will spawn?
            npc_amount: 3
            # The distance that the NPCs will spawn from the player
            spawn_distance: 4
            # How much time the player need to survive to pass?
            timer: 30
            # Which weapon the NPC will have?
            # run /ex flag server soldier_stage_3_npcs:!
            # and /ex reload
            # to change the weapon
            npc_weapon: stone_sword
            # Which weapon the Player will have?
            player_weapon: iron_sword
    question_list:
        1:
            question: 1+1?
            options:
                3: false
                1: false
                2: true
                5: false
        2:
            question: apple or pear?
            options:
                apple: true
                pear: false