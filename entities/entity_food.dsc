# +----------------------
# |
# | ENTITY FOOD
# |
# +----------------------
#
# @author devnodachi
# @date 2020/10/04
# @denizen-build REL-1714
#

Entity_Food_Script:
    type: world
    debug: false
    events:
        on SHEEP|COW|CHICKEN|PIG|MUSHROOM_COW|RABBIT|HORSE|DONKEY|LLAMA prespawns:
            - if <util.random.int[1].to[100]> > 10:
                - determine cancelled
        on SHEEP|COW|CHICKEN|PIG|MUSHROOM_COW|RABBIT|HORSE|DONKEY|LLAMA spawns:
            - if <util.random.int[1].to[100]> > 10:
                - determine cancelled
        on player right clicks GRASS_BLOCK with:BONE_MEAL:
            - determine passively cancelled
            - if <context.location.above[1].material.name> == AIR:
                - modifyblock <context.location.above[1]> GRASS
                - take material:BONE_MEAL from:<player.inventory>
        on player right clicks GRASS with:BONE_MEAL:
            - determine passively cancelled
            - if <context.location.above[1].material.name> == AIR:
                - modifyblock <context.location> TALL_GRASS
                - take material:BONE_MEAL from:<player.inventory>
        on entity despawns:
            - if <context.entity.is_player||null> != null && <context.entity.is_player>:
                - stop
            - if <context.entity.is_npc||null> != null && <context.entity.is_npc>:
                - stop
            - flag <context.entity> time_left:!
            - flag <context.entity> scared:!
        on entity death:
            - if <context.entity.is_player||null> != null && <context.entity.is_player>:
                - stop
            - if <context.entity.is_npc||null> != null && <context.entity.is_npc>:
                - stop
            - flag <context.entity> time_left:!
            - flag <context.entity> scared:!
        after player right clicks SHEEP|COW|CHICKEN|PIG|MUSHROOM_COW|RABBIT|HORSE|DONKEY|LLAMA with:NAME_TAG:
            - if <context.entity.has_flag[time_left]> && <context.entity.custom_name||null> != null && <context.item.has_display>:
                - adjust <context.entity> custom_name:<red>[<time[<context.entity.flag[time_left]>].duration_since[<util.time_now.to_utc>].in_hours.mul[100].div[24].round_to[0]><white><&chr[EFF1]><red>]<white><&sp><context.item.display>
                - determine cancelled
        on SHEEP|COW|CHICKEN|PIG|MUSHROOM_COW|RABBIT|HORSE|DONKEY|LLAMA dies:
            - if !<context.drops.is_empty>:
                - determine <context.drops.parse_tag[<[parse_value].with[quantity=<[parse_value].quantity.mul[2]>]>]>
        on delta time secondly every:5:
            - define data <script[Entity_Food_Data]>
            - define world_animals <world[Coolia].entities[<[data].data_key[entities]>]||<world[world].entities[<[data].data_key[entities]>]>>
            - if <[world_animals]> != null:
                - foreach <[world_animals]> as:animal:
                    - if !<[animal].is_spawned> || !<[animal].location.chunk.is_loaded>:
                        - foreach next
                    - if !<[animal].has_flag[time_left]>:
                        - flag <[animal]> time_left:<util.time_now.to_utc.add[<script[Entity_Food_Data].data_key[time_left]>]>
                    - define animal_name <red>[<time[<[animal].flag[time_left]>].duration_since[<util.time_now.to_utc>].in_hours.mul[100].div[24].round_to[0]><white><&chr[EFF1]><red>]
                    - if <[animal].custom_name||null> == null:
                        - adjust <[animal]> custom_name:<[animal_name]>
                    - else:
                        - adjust <[animal]> custom_name:<[animal_name]><[animal].custom_name.after[]]>
                    - if <time[<[animal].flag[time_left]>].duration_since[<util.time_now.to_utc>].in_hours> < <[data].data_key[eating_threshold]>:
                        - if <util.time_now.is_after[<time[<[animal].flag[time_left]>]>]>:
                            - hurt 999 <[animal]>
                            - foreach next
                        - define location <[animal].location>
                        - define block_limit <[data].data_key[block_limit]>
                        - define materials <[data].data_key[food_type].keys>
                        - define blocks <list[]>
                        - inject Surface_Blocks_Task instantly
                        - if !<[blocks].is_empty>:
                            - define block <[blocks].first>
                            - chunkload <[block].chunk>|<[block].chunk.add[0,1]>|<[block].chunk.add[0,-1]>|<[block].chunk.add[1,0]>|<[block].chunk.add[-1,0]>|<[block].chunk.add[1,1]>|<[block].chunk.add[-1,-1]> duration:10s
                            - define material_name <[block].material.name>
                            - define tries 0
                            - ~walk <[animal]> <[block]>
                            - while <[animal].is_spawned> && <[block].material.name||null> != null && <[block].material.name> == <[material_name]> && <[tries]> <= <[data].data_key[food_check_tries]>:
                                - if !<[animal].location.find.blocks[<[block].material.name>].within[1].is_empty>:
                                    - while stop
                                - define tries <[loop_index]>
                                - wait 10T
                            - if !<[animal].is_spawned> || <[block].material.name||null> == null || <[block].material.name> != <[material_name]> || <[tries]> > <[data].data_key[food_check_tries]>:
                                - foreach next
                            - flag <[animal]> time_left:<time[<[animal].flag[time_left]>].add[<[data].data_key[food_type].get[<[block].material.name>]>]>
                            - adjust <[animal]> custom_name:<[animal_name]><[animal].custom_name.after[]]>
                            - if <[block].material.name> == GRASS_BLOCK:
                                - modifyblock <[block]> DIRT
                            - else:
                                - modifyblock <[block]> AIR
                            - if <[animal].entity_type> == SHEEP:
                                - animate <[animal]> animation:SHEEP_EAT
                            - else:
                                - repeat 3:
                                    - if !<[animal].is_spawned>:
                                        - repeat stop
                                    - playeffect heart at:<[animal].location> quantity:10
                                    - wait 1s
