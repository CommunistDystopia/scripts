Wolf_Hyenas_Script:
    type: world
    debug: false
    events:
        on system time secondly every:8:
            - foreach <world[world].entities[wolf]> as:wolf:
                - if !<[wolf].is_tamed>:
                    - attack <[wolf]> target:cancel
                    - adjust <[wolf]> angry:false
                    - foreach <[wolf].location.find.living_entities.within[40]> as:entity_near:
                        - if <[entity_near].entity_type> != PLAYER && <[entity_near].entity_type> != WOLF:
                            - if <[entity_near].entity_type> == SHEEP || <[entity_near].entity_type> == COW || <[entity_near].entity_type> == PIG || <[entity_near].entity_type> == CHICKEN || <[entity_near].entity_type> == RABBIT || <[entity_near].entity_type> == FOX:
                                - attack <[wolf]> target:<[entity_near]>
                                - teleport <[wolf]> <[entity_near].location>
                                - foreach stop