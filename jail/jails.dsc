# /jail Usage
# /jail create <jailname> x1 y1 z1 x2 y2 z2 - Adds a jail (works like WorldEdit coordinates)
# /jail delete <jailname> - Removes a jail
# /jail list <#> - List all the jails in the prison
# Notables created here
# - jail_<name> [Used in Soldiers, Slaves]
# Server flag created here
# - jails_jail [List of jails names]

Command_Jail:
    type: command
    debug: false
    name: jail
    description: Minecraft Jail system.
    usage: /jail
    tab complete:
        - if !<player.is_op||<context.server>> && !<player.in_group[supremewarden]>:
            - stop
        - choose <context.args.size>:
            - case 0:
                - determine <list[create|delete|list]>
            - case 1:
                - if "!<context.raw_args.ends_with[ ]>":
                    - determine <list[create|delete|list].filter[starts_with[<context.args.first>]]>
                - else:
                    - if <server.has_flag[prison_jails]>:
                        - if <context.args.get[1].contains[list]>:
                            - determine <server.flag[prison_jails].size.div[10].truncate>
                        - if !<context.args.get[1].contains_any_case_sensitive_text[create|list]>:
                            - determine <server.flag[prison_jails].parse[after[jail_]]>
            - case 2:
                - if "!<context.raw_args.ends_with[ ]>":
                    - if <server.has_flag[prison_jails]>:
                        - if <context.args.get[1].contains[list]>:
                            - determine <server.flag[prison_jails].size.div[10].truncate>
                        - if !<context.args.get[1].contains_any_case_sensitive_text[create|list]>:
                            - determine <server.flag[prison_jails].parse[after[jail_]]>
    script:
        - if !<player.is_op||<context.server>> && !<player.in_group[supremewarden]>:
                - narrate "<red>You do not have permission for that command."
                - stop
        - if <context.args.size> < 2:
            - narrate "<yellow>#<red> ERROR: Not enough arguments. Follow the command syntax:"
            - narrate  "<yellow>-<red><red> To create a jail: /jail create <yellow>jailname x1 y1 z1 x2 y2 z2"
            - narrate  "<yellow>-<red><red> To delete a jail: /jail delete <yellow>jailname"
            - narrate  "<yellow>-<red><red> To list the jails in the server: /jail list <yellow>number"
            - stop
        - define action <context.args.get[1]>
        - define name <context.args.get[2]>
        - define jail_name jail_<[name]>
        - if <[jail_name].ends_with[_spawn]> || <[jail_name].ends_with[prison]> || <[jail_name].contains[_jails]>:
            - narrate "<red> ERROR: Invalid jail name. Please don't use _spawn or prison or _jails in your jail name."
            - stop
        - if <[action]> == create:
            - if <context.args.size> < 8:
                - narrate "<red> ERROR: Not enough arguments."
                - narrate  "<red> To create a jail: /jail create <yellow>jailname x1 y1 z1 x2 y2 z2"
                - stop
            - define x1 <context.args.get[3]>
            - define y1 <context.args.get[4]>
            - define z1 <context.args.get[5]>
            - define x2 <context.args.get[6]>
            - define y2 <context.args.get[7]>
            - define z2 <context.args.get[8]>
            - if <location[<[x1]>,<[y1]>,<[z1]>,world]||null> == null && <location[<[x2]>,<[y2]>,<[z2]>,world]||null> == null:
                - narrate "<red> ERROR: The location of the jail is invalid."
                - stop
            - if <cuboid[<[jail_name]>]||null> != null:
                - narrate "<red> ERROR: The name is used by other jail."
                - stop
            - define jail <cuboid[<location[<[x1]>,<[y1]>,<[z1]>,world]>|<location[<[x2]>,<[y2]>,<[z2]>,world]>]>
            - define jails <server.list_notables[cuboids].parse[notable_name].filter[starts_with[jail]]>
            - foreach <[jails]> as:other_jail:
                - if <[jail].intersects[<cuboid[<[other_jail]>]>]>:
                    - narrate "<red> ERROR: Your jail conflicts with other jail. Try to change the location of your jail."
                    - stop
            - note <[jail]> as:<[jail_name]>
            - flag server prison_jails:|:<[jail_name]>
            - narrate "<green> Jail <blue><[name]> <green>created!"
            - narrate "<green> Remember to set the <red>spawn of the Jail"
            - narrate "<green> With <red>/slaves spawn <yellow>jailname"
            - stop
        - if <[action]> == list:
            - define list_page <context.args.get[2]>
            - run List_Task_Script def:Prison|Jail|<[list_page]>
            - stop
        - if <[action]> == delete:
            - if <cuboid[<[jail_name]>]||null> == null:
                - narrate "<red> ERROR: Jail <[name]> doesn't exist."
                - stop
            - note remove as:<[jail_name]>
            - note remove as:<[jail_name]>_spawn
            - flag server prison_jails:<-:<[jail_name]>
            - define jail_slaves <[jail_name]>_slaves
            - define jail_soldiers <[jail_name]>_soldiers
            - define jail_wanted <[jail_name]>_wanteds
            - if <server.has_flag[<[jail_slaves]>]>:
                - foreach <server.flag[<[jail_slaves]>]> as:slave:
                    - if <[slave].has_flag[jail_owner]>:
                        - execute as_server "slaves remove <[slave].flag[jail_owner].after[jail_]> <[slave].name>" silent
                    - else:
                        - execute as_server "slaves remove <[slave].flag[owner].after[jail_]> <[slave].name>" silent
                - flag server <[jail_slaves]>:!
            - if <server.has_flag[<[jail_soldiers]>]>:
                - foreach <server.flag[<[jail_soldiers]>]> as:soldier:
                    - flag <[soldier]> soldier_jail:!
                - flag server <[jail_soldiers]>:!
            - if <server.has_flag[<[jail_wanted]>]>:
                - flag server <[jail_wanted]>:!
            - narrate "<green> Jail <blue><[name]> <red>deleted!"
            - stop
        - narrate "<yellow>#<red><red> ERROR: Syntax error. Follow the command syntax:"
        - narrate  "<yellow>-<red><red> To create a jail: /jail create <yellow>jailname x1 y1 z1 x2 y2 z2"
        - narrate  "<yellow>-<red><red> To delete a jail: /jail delete <yellow>jailname"
        - narrate  "<yellow>-<red><red> To list the jails: /jail list <yellow>number"