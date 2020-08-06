List_Task_Script:
    type: task
    debug: false
    definitions: target|flag_name|member|list_page|containPlayers
    script:
        - if <[list_page].is_integer>:
            - define flag_values 0
            - if <[target]> == server:
                - if !<server.has_flag[<[flag_name]>]>:
                    - narrate "<red> ERROR: The server doesn't have any <[member]>s."
                    - stop
                - define flag_values <server.flag[<[flag_name]>]>
            - else:
                - if !<[target].has_flag[<[flag_name]>]>:
                    - narrate "<red> ERROR: <blue><[target].name> <red>doesn't have any <[member]>s."
                    - stop
                - define flag_values <[target].flag[<[flag_name]>]>
            - if <[flag_values].size> <= 10:
                - narrate "<green> Listing all <yellow><[member]>s <green>since the list only has less than 10."
                - foreach <[flag_values]>:
                    - if <[containPlayers]>:
                        - narrate "<green> - <[member]> <[loop_index]>: <blue><[value].name>"
                    - else:
                        - if <[value].after[<[member]>_].length> == 0:
                            - narrate "<green> - <[member]> <[loop_index]>: <blue><[value]>"
                        - else:
                            - narrate "<green> - <[member]> <[loop_index]>: <blue><[value].after[<[member]>_]>"
                - stop
            - else:
                - define lower_limit <[list_page].mul[10]>
                - if <[list_page]> == 0:
                    - define lower_limit 1
                - define upper_limit <[list_page].mul[10].add[10]>
                - if <[lower_limit]> > <[flag_values].size>:
                    - narrate "<red> ERROR: Each list page only contains 10 entries."
                    - narrate "The list currently has <[flag_values].size> <[member]>s."
                    - narrate "Use <[flag_values].size.div[10].truncate> or a lower number for the list."
                    - stop
                - if <[upper_limit]> > <[flag_values].size>:
                    - define upper_limit <[flag_values].size>
                - narrate "<yellow> <[member]>s [Page: <[list_page]>/<[flag_values].size.div[10].truncate>]"
                - foreach <[flag_values].get[<[lower_limit]>].to[<[upper_limit]>]>:
                    - if <[containPlayers]>:
                        - narrate "<green> - <[member]> <[loop_index].sub[1].add[<[lower_limit]>]>: <blue><[value].name>"
                    - else:
                        - if <[value].after[<[member]>_].length> == 0:
                            - narrate "<green> - <[member]> <[loop_index].sub[1].add[<[lower_limit]>]>: <blue><[value]>"
                        - else:
                            - narrate "<green> - <[member]> <[loop_index].sub[1].add[<[lower_limit]>]>: <blue><[value].after[<[member]>_]>"
                - stop