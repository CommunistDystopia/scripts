List_Task_Script:
    type: task
    debug: false
    definitions: flag_name|member|list_page|isPlayers
    script:
        - if !<server.has_flag[<[flag_name]>]>:
            - narrate "<red> ERROR: The server doesn't have any <[member]>s."
            - stop
        - if <[list_page].is_integer>:
            - define flag_values <server.flag[<[flag_name]>]>
            - if <[flag_values].size> <= 10:
                - narrate "<green> Listing all <yellow><[member]>s <green>since the server only has less than 10."
                - foreach <[flag_values]>:
                    - if <[isPlayers]>:
                        - narrate "<green> - <[member]> <[loop_index]>: <blue><[value].name>"
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
                    - narrate "The server currently has <[flag_values].size> <[member]>s."
                    - narrate "Use <[flag_values].size.div[10].truncate> or a lower number for the list."
                    - stop
                - if <[upper_limit]> > <[flag_values].size>:
                    - narrate "<yellow> <[member]>s [Page: <[list_page]>/<[flag_values].size.div[10].truncate>]"
                    - foreach <[flag_values].get[<[lower_limit]>].to[<[flag_values].size>]>:
                        - if <[isPlayers]>:
                            - narrate "<green> - <[member]> <[loop_index].sub[1].add[<[lower_limit]>]>: <blue><[value].name>"
                        - else:
                            - narrate "<green> - <[member]> <[loop_index].sub[1].add[<[lower_limit]>]>: <blue><[value].after[<[member]>_]>"
                    - stop
                - else:
                    - narrate "<yellow> <[member]>s [Page: <[list_page]>/<[flag_values].size.div[10].truncate>]"
                    - foreach <[flag_values].get[<[lower_limit]>].to[<[upper_limit]>]>:
                        - if <[isPlayers]>:
                            - narrate "<green> - <[member]> <[loop_index].sub[1].add[<[lower_limit]>]>: <blue><[value].name>"
                        - else:
                            - narrate "<green> - <[member]> <[loop_index].sub[1].add[<[lower_limit]>]>: <blue><[value].after[<[member]>_]>"
                    - stop