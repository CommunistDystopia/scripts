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
            - if <context.entity.has_flag[time_left]>:
                - flag <context.entity> time_left:!
        on entity death:
            - if <context.entity.is_player||null> != null && <context.entity.is_player>:
                - stop
            - if <context.entity.is_npc||null> != null && <context.entity.is_npc>:
                - stop
            - if <context.entity.has_flag[time_left]>:
                - flag <context.entity> time_left:!
        after player right clicks SHEEP|COW|CHICKEN|PIG|MUSHROOM_COW|RABBIT|HORSE|DONKEY|LLAMA with:NAME_TAG:
            - if <context.entity.has_flag[time_left]> && <context.entity.custom_name||null> != null && <context.item.has_display>:
                - adjust <context.entity> custom_name:<red>[<time[<context.entity.flag[time_left]>].duration_since[<util.time_now.to_utc>].in_hours.mul[100].div[24].round_to[0]><white><&chr[EFF1]><red>]<white><&sp><context.item.display>
                - determine cancelled
        on SHEEP|COW|CHICKEN|PIG|MUSHROOM_COW|RABBIT|HORSE|DONKEY|LLAMA dies:
            - if !<context.drops.is_empty>:
                - determine <context.drops.parse_tag[<[parse_value].with[quantity=<[parse_value].quantity.mul[2]>]>]>
        on system time secondly every:5:
            - define data <script[Entity_Food_Data]>
            - define world_animals <world[Coolia].entities[<[data].data_key[entities]>]||<world[world].entities[<[data].data_key[entities]>]>>
            - if <[world_animals]> != null:
                - foreach <[world_animals]> as:animal:
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
                            - stop
                        - define block <[animal].location.find.surface_blocks[HAY_BLOCK].within[<[data].data_key[block_limit]>].first||null>
                        - if <[block]> == null:
                            - define block <[animal].location.find.surface_blocks[<[data].data_key[food_type].keys>].within[<[data].data_key[block_limit]>].first||null>
                        - if <[block]> != null:
                            - define material_name <[block].material.name>
                            - define tries 0
                            - ~walk <[animal]> <[block]>
                            - while <[block].material.name> == <[material_name]> && <[animal].location.find.blocks[<[block].material.name>].within[1].first||null> == null && <[tries]> <= <[data].data_key[food_check_tries]>:
                                - define tries <[loop_index]>
                                - wait 10T
                            - if <[block].material.name> != <[material_name]> || <[tries]> > <[data].data_key[food_check_tries]>:
                                - stop
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
