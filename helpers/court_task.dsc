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
            - define witness <player[<server.flag[court_witness]>]>
            - if <[witness].is_online> && <[witness].has_flag[court_npc]>:
                - adjust <[witness]> spectate:<[witness]>
                - remove <npc[<[witness].flag[court_npc]>]>
                - flag <[witness]> court_npc:!
        - flag server court_witness:!
        - flag server court_lead:!
        - flag server court_lawyer:!
        - flag server court_active:!