Animals_Need_More_Food_Script:
    type: world
    debug: false
    events:
        on entity death:
            - if <context.entity.has_flag[last_food]>:
                - flag <context.entity> last_food:!
        on system time hourly every:1:
            - foreach <world[world].entities[COW||CHICKEN||PIG||MUSHROOM_COW||RABBIT||BEE]> as:animal:
                - if !<[animal].has_flag[last_food]>:
                    - remove <[animal]>
                    - foreach next
                - define last_food <[animal].flag[last_food]>
                - define time_now <util.time_now.to_utc>
                - if <[time_now].is_after[<[last_food]>]>:
                    - flag <[animal]> last_food:!
                    - remove <[animal]>
        on player right clicks PIG with:carrot:
            - determine cancelled
        on player right clicks CHICKEN with:wheat_seeds:
            - determine cancelled
        on player right clicks MUSHROOM_COW with:bowl:
            - determine cancelled
        on player right clicks entity with:wheat:
            - if <context.entity.name> != COW && <context.entity.name> != CHICKEN && <context.entity.name> != PIG && <context.entity.name> != MUSHROOM_COW:
                - stop
            - if <context.item.quantity> < 64:
                - determine cancelled
            - inventory set slot:<player.held_item_slot> o:air
            - adjust <context.entity> breed:true
            - flag <context.entity> last_food:<util.time_now.add[1d].to_utc.format>
            - repeat 10:
                - playeffect heart at:<context.entity.location> quantity:10
                - wait 1s
        on player right clicks RABBIT with:carrot:
            - if <context.item.quantity> < 64:
                - determine cancelled
            - inventory set slot:<player.held_item_slot> o:air
            - adjust <context.entity> breed:true
            - flag <context.entity> last_food:<util.time_now.add[1d].to_utc.format>
            - repeat 10:
                - playeffect heart at:<context.entity.location> quantity:10
                - wait 1s
        on player right clicks BEE with:dandelion||poppy||blue_orchid||allium||azure_bluet||red_tulip||orange_tulip||white_tulip||pink_tulip||oxeye_daisy||cornflower||lily_of_the_valley||wither_rose||sunflower||lilac||rose_bush||peony:
            - if <context.item.quantity> < 64:
                - determine cancelled
            - inventory set slot:<player.held_item_slot> o:air
            - adjust <context.entity> breed:true
            - flag <context.entity> last_food:<util.time_now.add[1d].to_utc.format>
            - repeat 10:
                - playeffect heart at:<context.entity.location> quantity:10
                - wait 1s