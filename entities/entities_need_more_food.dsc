emerald_apple:
    type: item
    material: apple
    mechanisms:
        hides: enchants
    enchantments:
        - unbreaking:1
    display name: <green>Emerald Apple
    lore:
        - <green>Used to feed horses
    recipes:
        1:
            type: shaped
            input:
                - emerald|emerald|emerald
                - emerald|apple|emerald
                - emerald|emerald|emerald

Entities_Need_More_Food_Script:
    type: world
    debug: false
    events:
        on entity despawns:
            - if <context.entity.is_player>:
                - stop
            - if <context.entity.has_flag[last_food]>:
                - flag <context.entity> last_food:!
        on entity death:
            - if <context.entity.is_player>:
                - stop
            - if <context.entity.has_flag[last_food]>:
                - flag <context.entity> last_food:!
        on system time hourly every:1:
            - foreach <world[world].entities[SHEEP||COW||CHICKEN||PIG||MUSHROOM_COW||RABBIT||BEE||WOLF||HORSE||VILLAGER]> as:living_being:
                - if !<[living_being].has_flag[last_food]>:
                    - hurt 999 <[living_being]>
                    - foreach next
                - define last_food <[living_being].flag[last_food]>
                - define actual_time <util.time_now.to_utc>
                - if <[actual_time].is_after[<[last_food]>]>:
                    - flag <[living_being]> last_food:!
                    - hurt 999 <[living_being]>
        on player right clicks PIG with:carrot:
            - determine cancelled
        on player right clicks CHICKEN with:wheat_seeds:
            - determine cancelled
        on player right clicks MUSHROOM_COW with:bowl:
            - determine cancelled
        on player right clicks entity with:wheat:
            - if <context.entity.name> != COW && <context.entity.name> != CHICKEN && <context.entity.name> != PIG && <context.entity.name> != MUSHROOM_COW && <context.entity.name> != SHEEP:
                - stop
            - if <context.item.quantity> < 64:
                - determine cancelled
                - stop
            - inventory set slot:<player.held_item_slot> o:air
            - adjust <context.entity> breed:true
            - flag <context.entity> last_food:<util.time_now.add[1d].to_utc>
            - repeat 10:
                - playeffect heart at:<context.entity.location> quantity:10
                - wait 1s
        on player right clicks RABBIT with:carrot:
            - if <context.item.quantity> < 64:
                - determine cancelled
                - stop
            - inventory set slot:<player.held_item_slot> o:air
            - adjust <context.entity> breed:true
            - flag <context.entity> last_food:<util.time_now.add[1d].to_utc>
            - repeat 10:
                - playeffect heart at:<context.entity.location> quantity:10
                - wait 1s
        on player right clicks BEE with:dandelion||poppy||blue_orchid||allium||azure_bluet||red_tulip||orange_tulip||white_tulip||pink_tulip||oxeye_daisy||cornflower||lily_of_the_valley||wither_rose||sunflower||lilac||rose_bush||peony:
            - if <context.item.quantity> < 64:
                - determine cancelled
                - stop
            - inventory set slot:<player.held_item_slot> o:air
            - adjust <context.entity> breed:true
            - flag <context.entity> last_food:<util.time_now.add[1d].to_utc>
            - repeat 10:
                - playeffect heart at:<context.entity.location> quantity:10
                - wait 1s
        on player right clicks WOLF with:pufferfish||tropical_fish||chicken||cooked_chicken||porkchop||cooked_porkshop||beef||cooked_beef||rabbit||cooked_rabbit||mutton||cooked_mutton||rotten_flesh:
            - if !<context.entity.is_tamed>:
                - determine cancelled
                - stop
            - if <context.item.quantity> < 64:
                - determine cancelled
                - stop
            - inventory set slot:<player.held_item_slot> o:air
            - adjust <context.entity> breed:true
            - flag <context.entity> last_food:<util.time_now.add[1d].to_utc>
            - repeat 10:
                - playeffect heart at:<context.entity.location> quantity:10
                - wait 1s
        on player right clicks HORSE with:emerald_apple:
            - if !<context.entity.is_tamed>:
                - determine cancelled
                - stop
            - if <context.item.quantity> > 1:
                - narrate "<red> Please use only one <green>Emerald Apple <red>at a time."
                - determine cancelled
            - inventory set slot:<player.held_item_slot> o:air
            - flag <context.entity> last_food:<util.time_now.add[1d].to_utc>
            - repeat 10:
                - playeffect composter at:<context.entity.location> quantity:10
                - wait 1s
        on player right clicks VILLAGER with:COOKED_BEEF:
            - if <context.item.quantity> < 10:
                - determine cancelled
                - stop
            - inventory set slot:<player.held_item_slot> o:air
            - flag <context.entity> last_food:<util.time_now.add[1d].to_utc>
            - repeat 10:
                - playeffect heart at:<context.entity.location> quantity:10
                - wait 1s