Court_Task_Script:
    type: task
    debug: false
    definitions: slave
    script:
        - if <[slave].is_online>:
            - adjust <[slave]> spectate:<[slave]>
        - remove <npc[<[slave].flag[court_npc]>]>
        - flag <[slave]> court_npc:!
        - flag server court_slave:!
        - if <server.has_flag[court_witness]>:
            - foreach <server.flag[court_witness]> as:witness:
                - if <player[<[witness]>].is_online>:
                    - adjust <player[<[witness]>]> spectate:<player[<[witness]>]>
                - remove <npc[<player[<[witness]>].flag[court_npc]>]>
                - flag <player[<[witness]>]> court_npc:!
        - flag server court_witness:!
        - flag server court_lead:!
        - flag server court_lawyer:!
        - flag server court_active:!