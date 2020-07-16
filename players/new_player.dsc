New_Player_Script:
    type: world
    debug: false
    events:
        on system time minutely:
            - foreach <server.online_players.filter[has_flag[wilderness_lock_timer]]> as:server_player:
                - flag <[server_player]> wilderness_lock_timer:-:1
                - if <[server_player].flag[wilderness_lock_timer]> <= 0.0:
                    - flag <[server_player]> wilderness_lock_timer:!
        after player logs in for the first time:
            - flag <player> wilderness_lock_timer:<script[New_Player_Config].data_key[wilderness_lock_timer]>
        on player places block:
            - if !<player.is_op> && <player.has_flag[wilderness_lock_timer]>:
                - if <script[New_Player_Script].cooled_down[<player>]>:
                    - narrate "<red> DENIED: New Player Protection. <white>Wait <yellow><player.flag[wilderness_lock_timer]> minutes <white>before you can break blocks"
                    - cooldown 5s script:New_Player_Script
                - determine cancelled
        on player breaks block:
            - if !<player.is_op> && <player.has_flag[wilderness_lock_timer]>:
                - if <script[New_Player_Script].cooled_down[<player>]>:
                    - narrate "<red> DENIED: New Player Protection. <white>Wait <yellow><player.flag[wilderness_lock_timer]> minutes <white>before you can place blocks"
                    - cooldown 5s script:New_Player_Script
                - determine cancelled