# +----------------------
# |
# | ENTITY FOOD
# |
# +----------------------
#
# @author devnodachi
# @date 2020/10/16
# @denizen-build REL-1714
#

Entity_Food_Script:
    type: world
    debug: false
    events:
        on entity despawns:
            - define isValidPlayer <context.entity.is_player||null>
            - define isValidNPC <context.entity.is_npc||null>
            - if <[isValidPlayer]> != null && <[isValidPlayer]>:
                - stop
            - if <[isValidNPC]> != null && <[isValidNPC]>:
                - stop
            - if <context.entity.has_flag[last_food]>:
                - flag <context.entity> last_food:!
            - flag <context.entity> scared:!
        on entity death:
            - define isValidPlayer <context.entity.is_player||null>
            - define isValidNPC <context.entity.is_npc||null>
            - if <[isValidPlayer]> != null && <[isValidPlayer]>:
                - stop
            - if <[isValidNPC]> != null && <[isValidNPC]>:
                - stop
            - if <context.entity.has_flag[last_food]>:
                - flag <context.entity> last_food:!
            - flag <context.entity> scared:!
        after player right clicks entity with:NAME_TAG:
            - if <context.entity.has_flag[last_food]> && <context.item.has_display>:
                - ~run Animal_Name_Task def:<context.entity>
                - determine cancelled
        on system time minutely:
            - foreach <world[Coolia].entities[<script[Entity_Food_Data].data_key[entities].keys>]||<world[world].entities[<script[Entity_Food_Data].data_key[entities].keys>]>> as:living_being:
                - if !<[living_being].has_flag[last_food]>:
                    - flag <[living_being]> last_food:!
                    - hurt 999 <[living_being]>
                - if <[living_being].flag[last_food].is_expired>:
                    - flag <[living_being]> last_food:!
                    - hurt 999 <[living_being]>
                - else:
                    - run Animal_Name_Task def:<[living_being]>
        on player right clicks MUSHROOM_COW with:bowl:
            - determine cancelled
        on player right clicks entity:
            - inject Entity_Food_Task instantly

Entity_Food_Task:
    type: task
    debug: false
    script:
        - if !<context.entity.is_spawned>:
            - stop
        - if <context.entity.tameable> && !<context.entity.is_tamed>:
            - stop
        - ratelimit <player> 2s
        - determine cancelled passively
        - define data <script[Entity_Food_Data].data_key[entities]>
        - if <[data].keys.find[<context.entity.entity_type>]> == -1:
            - stop
        - if <[data].get[<context.entity.entity_type>].get[food].find[<context.item.material.name>]> == -1:
            - stop
        - define quantity <[data].get[<context.entity.entity_type>].get[quantity]>
        - if <context.item.quantity> < <[quantity]>:
            - stop
        - take material:<context.item.material.name> quantity:<[quantity]> from:<player.inventory>
        - flag <context.entity> last_food duration:<script[Entity_Food_Data].data_key[default_time]>
        - run Animal_Name_Task def:<context.entity>
        - repeat 5:
            - if !<context.entity.is_spawned>:
                - repeat stop
            - playeffect heart at:<context.entity.location> quantity:10
            - wait 1s

Animal_Name_Task:
    type: task
    debug: false
    definitions: animal
    script:
        - define animal_name <red>[<[animal].flag[last_food].expiration.in_hours.round_to[0]>h<white><&chr[EFF1]><red>]
        - if <[animal].custom_name||null> == null:
            - adjust <[animal]> custom_name:<[animal_name]>
        - else:
            - adjust <[animal]> custom_name:<[animal_name]><[animal].custom_name.after[]]>