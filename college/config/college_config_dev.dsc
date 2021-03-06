####################################
## [COLLEGE]
## DENIZEN DEVELOPER CONFIG FILE
####################################

# [College] naming
## [X] is only for custom stages (X > 1)
## CUBOIDs
# - [Exam]_stage_[X]_player_zone: Used for player zones to avoid teleport inside the college stages.
## FLAGs
# - server: [Exam]_stage_[X]_players: Used to list the players allowed to get in the player zone.
## LOCATIONs
# - [Exam]_stage_[X]_spawn: Used to teleport the player to a given location at the start of a exam.
## [SOLDIER] Exam - [CUSTOM]
# - soldier_stage_2_shooting_zone [cuboid]: Used to set the shooting area
# - soldier_stage_3_parkour_zone [cuboid]: Used to set the area where the player will pass the stage.

College_Config_Dev:
    type: data
    custom_cuboids:
        soldier_shooting: soldier_stage_2_shooting_zone
        soldier_parkour: soldier_stage_3_parkour_zone
    custom_locations:
        placeholder_data: o