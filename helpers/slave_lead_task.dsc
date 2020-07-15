Slave_Lead_Task:
    type: task
    debug: false
    definitions: slave
    script:
        - if <player.in_group[supremewarden]> || <player.is_op>:
            - if !<[slave].has_flag[slave_timer]>:
                - narrate "<red> ERROR: This user isn't currently a slave from a prison. It's probably controlled by a Godvip"
                - stop
            - if !<player.has_flag[soldier_jail]>:
                - narrate "<red> ERROR: You don't have a jail assigned"
                - stop
            - flag <[slave]> jail_owner:<[slave].flag[owner]>
            - flag <[slave]> owner:<player.uuid>
            - flag <[slave]> owner_block_limit:10
            - flag <player> owned_slaves:|:<[slave]>
            - flag <[slave]> slave_timer:!
            - narrate "<green> You started getting the <red>slave <green>with you"
        - if !<[slave].flag[owner].contains_all_case_sensitive_text[<player.uuid>]>:
            - narrate "<red> ERROR: This slave isn't yours"
            - stop
        - flag <[slave]> slave_lead_queue:<queue>
        - narrate "<green> Starting to force the slave <red><[slave].name> to stay within <yellow>10 <green>blocks"
        - narrate "<yellow> Be aware. <green>It will work until you or the slave are offline."
        - narrate "<red> You are now forced to stay with your <gold>owner" targets:<[slave]>
        - while <player.is_online> && <[slave].is_online> && <[slave].in_group[slave]> && <[slave].has_flag[jail_owner]>:
            - if <player.location.points_between[<[slave].location>].size> > <[slave].flag[owner_block_limit]>:
                - teleport <[slave]> <player.location>
            - wait 1s
        - stop