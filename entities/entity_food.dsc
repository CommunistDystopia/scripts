# +----------------------
# |
# | ENTITY FOOD
# |
# +----------------------
#
# @author devnodachi
# @date 2020/08/23
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
                - flag <context.entity> baby_time:!
        on entity death:
            - define isValidPlayer <context.entity.is_player||null>
            - define isValidNPC <context.entity.is_npc||null>
            - if <[isValidPlayer]> != null && <[isValidPlayer]>:
                - stop
            - if <[isValidNPC]> != null && <[isValidNPC]>:
                - stop
            - if <context.entity.has_flag[last_food]>:
                - flag <context.entity> last_food:!
                - flag <context.entity> baby_time:!
        on system time hourly:
            - foreach <world[Coolia].entities[<script[Entity_Food_Data].data_key[entities].keys>]||<world[world].entities[<script[Entity_Food_Data].data_key[entities].keys>]>> as:living_being:
                - if !<[living_being].has_flag[last_food]>:
                    - flag <[living_being]> last_food:!
                    - flag <[living_being]> baby_time:!
                    - hurt 999 <[living_being]>
                    - foreach next
                - define actual_time <util.time_now.to_utc>
                - if <[actual_time].is_after[<[living_being].flag[last_food]>]>:
                    - flag <[living_being]> last_food:!
                    - flag <[living_being]> baby_time:!
                    - hurt 999 <[living_being]>
                - if <[living_being].has_flag[baby_time]> && <[actual_time].is_after[<[living_being].flag[baby_time]>]>:
                    - flag <[living_being]> baby_time:!
                    - spawn <[living_being].entity_type> <[living_being].location> save:baby
                    - age <entry[baby].spawned_entity> baby
        on player right clicks MUSHROOM_COW with:bowl:
            - determine cancelled
        on player right clicks entity:
            - inject Entity_Food_Task instantly
        on entity breeds:
            - determine cancelled

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
        - if !<context.entity.has_flag[baby_time]>:
            - flag <context.entity> baby_time:<util.time_now.add[2d].to_utc>
        - flag <context.entity> last_food:<util.time_now.add[1d].to_utc>
        - repeat 5:
            - if !<context.entity.is_spawned>:
                - repeat stop
            - playeffect heart at:<context.entity.location> quantity:10
            - wait 1s