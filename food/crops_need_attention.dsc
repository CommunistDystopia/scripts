Croops_Need_Attention_Script:
    type: world
    debug: false
    events:
        on block grows:
            - if !<context.location.chunk.is_loaded>:
                - stop
            - define players_in_chunk <context.location.chunk.players>
            - if <[players_in_chunk].is_empty>:
                - determine cancelled
                - stop
            - if <context.location.biome.name> == DESERT || <context.location.biome.name> == DESERT_HILLS || <context.location.biome.name> == DESERT_LAKES:
                - determine cancelled
            - if <context.location.biome.name> == SNOWY_BEACH || <context.location.biome.name> == SNOWY_MOUNTAINS || <context.location.biome.name> == SNOWY_TAIGA || <context.location.biome.name> == SNOWY_TAIGA_HILLS || <context.location.biome.name> == SNOWY_TUNDRA || <context.location.biome.name> == SNOWY_TAIGA_MOUNTAINS:
                - determine cancelled
            - if <context.location.light.sky> < 9.0:
                - determine cancelled
        on player right clicks block with:bone_meal:
            - determine cancelled
        on player right clicks SWEET_BERRY_BUSH:
            - if <context.location.material.age> == 2.0 || <context.location.material.age> == 3.0:
                - drop SWEET_BERRIES <context.location> quantity:1
                - modifyblock <context.location> <material[SWEET_BERRY_BUSH].with[age=1]>
                - determine cancelled
        on player breaks SWEET_BERRY_BUSH:
            - if <context.material.age> == 2.0 || <context.material.age> == 3.0:
                - determine <item[SWEET_BERRIES]>
        on player consumes DRIED_KELP:
            - hurt
