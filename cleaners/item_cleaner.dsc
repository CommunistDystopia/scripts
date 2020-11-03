Item_Cleaner_Script:
    type: world
    debug: false
    events:
        on delta time minutely every:15:
            - narrate "<white>[ItemCleaner] <red>The items in the ground will be cleared in 1 minute" targets:<server.online_players>
            - wait 1m
            - narrate "<white>[ItemCleaner] <red>Clearing the items in the ground..." targets:<server.online_players>
            - remove dropped_item world:Coolia