# +----------------------
# |
# | WOLF HYENAS
# |
# | Wolfs will attack all passive mobs.
# |
# +----------------------
#
# @author devnodachi
# @date 2020/08/02
# @denizen-build REL-1714
#

Wolf_Hyenas_Script:
    type: world
    debug: false
    events:
        on delta time secondly every:15:
            - foreach <world[Coolia].entities[wolf]||<world[world].entities[wolf]>> as:wolf:
                - if !<[wolf].is_tamed>:
                    - attack <[wolf]> target:cancel
                    - adjust <[wolf]> angry:false
                    - foreach <[wolf].location.find.living_entities.within[40]> as:entity_near:
                        - if <[entity_near].entity_type> != PLAYER && <[entity_near].entity_type> != WOLF:
                            - if <[entity_near].entity_type> == SHEEP || <[entity_near].entity_type> == COW || <[entity_near].entity_type> == PIG || <[entity_near].entity_type> == CHICKEN || <[entity_near].entity_type> == RABBIT || <[entity_near].entity_type> == FOX || <[entity_near].entity_type> == MUSHROOM_COW:
                                - define teleport_range 11
                                - repeat 8:
                                    - define space_between <[teleport_range].sub[<[value]>]>
                                    - if <[entity_near].location.center.backward[<[space_between]>].chunk.is_loaded>:
                                        - if !<[entity_near].location.center.backward[<[space_between]>].material.is_solid>:
                                            - attack <[wolf]> target:<[entity_near]>
                                            - teleport <[wolf]> <[entity_near].location.center.backward[<[space_between]>]>
                                            - cast speed duration:15s amplifier:2 <[wolf]> hide_particles
                                            - repeat stop
                                    - if <[entity_near].location.center.left[<[space_between]>].chunk.is_loaded>:
                                        - if !<[entity_near].location.center.left[<[space_between]>].material.is_solid>:
                                            - attack <[wolf]> target:<[entity_near]>
                                            - teleport <[wolf]> <[entity_near].location.center.left[<[space_between]>]>
                                            - cast speed duration:15s amplifier:2 <[wolf]> hide_particles
                                            - repeat stop
                                    - if <[entity_near].location.center.right[<[space_between]>].chunk.is_loaded>:
                                        - if !<[entity_near].location.center.right[<[space_between]>].material.is_solid>:
                                            - attack <[wolf]> target:<[entity_near]>
                                            - teleport <[wolf]> <[entity_near].location.center.right[<[space_between]>]>
                                            - cast speed duration:15s amplifier:2 <[wolf]> hide_particles
                                            - repeat stop
                                    - if <[entity_near].location.center.forward[<[space_between]>].chunk.is_loaded>:
                                        - if !<[entity_near].location.center.forward[<[space_between]>].material.is_solid>:
                                            - attack <[wolf]> target:<[entity_near]>
                                            - teleport <[wolf]> <[entity_near].location.center.forward[<[space_between]>]>
                                            - cast speed duration:15s amplifier:2 <[wolf]> hide_particles
                                            - repeat stop