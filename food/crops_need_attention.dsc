Croops_Need_Attention_Script:
    type: world
    debug: false
    events:
        on block grows:
            - define players_in_chunk <context.location.chunk.players>
            - if <[players_in_chunk].is_empty>:
                - determine cancelled
            - if <context.location.biome.name> == DESERT || <context.location.biome.name> == DESERT_HILLS || <context.location.biome.name> == DESERT_LAKES:
                - if <context.location.light.sky> < 9.0:
                    - determine cancelled
            - if <context.location.biome.name> == SNOWY_BEACH || <context.location.biome.name> == SNOWY_MOUNTAINS || <context.location.biome.name> == SNOWY_TAIGA || <context.location.biome.name> == SNOWY_TAIGA_HILLS || <context.location.biome.name> == SNOWY_TUNDRA || <context.location.biome.name> == SNOWY_TAIGA_MOUNTAINS:
                - determine cancelled
                - if <context.location.light.sky> < 9.0:
                    - determine cancelled
        on player right clicks block with:bone_meal:
            - determine cancelled
