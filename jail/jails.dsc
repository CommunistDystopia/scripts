# +----------------------
# |
# | J A I L S
# |
# | Create Jails that work with other plugins.
# |
# +----------------------
#
# @author devnodachi
# @date 2020/08/02
# @denizen-build REL-1714
#
# Commands
# /jail create <jailname> - Adds a jail
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
        - if <[name].ends_with[_spawn]> || <[name].ends_with[prison]> || <[name].contains_all_text[jail]> || <[name].contains_all_text[region]>:
            - narrate "<red> ERROR: Invalid jail name. To avoid conflicts with other plugins avoid using that name."
            - stop
        - define jail_name jail_<[name]>
        - if <[action]> == create:
            - if !<player.has_flag[ctool_selection]>:
                - narrate "<red>You don't have any region selected."
                - stop
            - if <cuboid[<[jail_name]>]||null> != null:
                - narrate "<red> ERROR: The name is used by other jail."
                - stop
            - define jail <player.flag[ctool_selection].as_cuboid>
            - define jails <server.notables[cuboids].parse[note_name].filter[starts_with[jail_]]>
            - foreach <[jails]> as:other_jail:
                - if <[jail].intersects[<cuboid[<[other_jail]>]>]>:
                    - narrate "<red> ERROR: Your jail conflicts with other jail. Try to change the location of your jail."
                    - stop
            - note <[jail]> as:<[jail_name]>
            - flag <player> ctool_selection:!
            - flag server prison_jails:|:<[jail_name]>
            - narrate "<green> Jail <blue><[name]> <green>created!"
            - narrate "<green> Remember to set the <red>spawn of the Jail"
            - narrate "<green> With <red>/slaves spawn <yellow>jailname"
            - stop
        - if <[action]> == list:
            - define list_page <context.args.get[2]>
            - run List_Task_Script def:prison_jails|Jail|<[list_page]>|false
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
        - narrate  "<yellow>-<red><red> To create a jail: /jail create <yellow>name"
        - narrate  "<yellow>-<red><red> To delete a jail: /jail delete <yellow>name"
        - narrate  "<yellow>-<red><red> To list the jails: /jail list <yellow>number"