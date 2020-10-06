Entity_Food_Data:
    type: data
    # Which animals will be affected by this script?
    entities:
        - SHEEP
        - COW
        - CHICKEN
        - PIG
        - MUSHROOM_COW
        - RABBIT
        - HORSE
        - DONKEY
        - LLAMA
    # How much time each type of food will give?
    food_type:
        GRASS_BLOCK: 15m
        GRASS: 5m
        TALL_GRASS: 15m
        HAY_BLOCK: 2h
    # Time left before the animal dies
    time_left: 1d
    # When the animal will start to eat?
    # 24-10 = 14 hours
    eating_threshold: 7
    # Block limit to check for food
    block_limit: 10
    # How many times the animal will check for nearby food after reaching the destination?
    food_check_tries: 10