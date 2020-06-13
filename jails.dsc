# /jail Usage
# /jail create <name> x1 y1 z1 x2 y2 z2
# /jail delete <name>

Command_Jail:
    type: command
    name: jail
    description: Minecraft Jail system.
    usage: /jail
    script:
        - if !<player.is_op||<context.server>> || <player.groups.find[supremewarden]||null> == null:
            - narrate "<red>You do not have permission for that command."
            - stop
        - define action <context.args.get[1]>
        - define name <context.args.get[2]>
        - define jail_name "jail_<[name]>"
        - if <[jail_name].ends_with[_spawn]>:
            - narrate "<red> Error. Invalid jail name. Please don't use _spawn in your jail name."
            - stop
        - if <[action]> == create:
            - define x1 <context.args.get[3]>
            - define y1 <context.args.get[4]>
            - define z1 <context.args.get[5]>
            - define x2 <context.args.get[6]>
            - define y2 <context.args.get[7]>
            - define z2 <context.args.get[8]>
            - if <location[<[x1]>,<[y1]>,<[z1]>,world]||null> != null && <location[<[x2]>,<[y2]>,<[z2]>,world]||null> != null:
                - if <cuboid[<[jail_name]>]||null> != null:
                    - narrate "<red> The name is used by other jail."
                    - stop
                - note <cuboid[<location[<[x1]>,<[y1]>,<[z1]>,world]>|<location[<[x2]>,<[y2]>,<[z2]>,world]>]> as:<[jail_name]>
                - narrate "<green> Jail <[name]> created!"
                - stop
            - narrate "<red> The location of the jail is invalid."
            - stop
        - if <[action]> == delete:
            - if <cuboid[<[jail_name]>]||null> == null:
                - narrate "<red> Jail <[name]> doesn't exist."
                - stop
            - note remove as:<[jail_name]>
            - note remove as:<[jail_name]>_spawn
            - narrate "<green> Jail <[name]> deleted!"
            - stop
        - narrate "<red> ERROR: Follow the command syntax:"
        - narrate  "<yellow> To create a jail: /jail create name x1 y1 z1 x2 y2 z2"
        - narrate  "<yellow> To delete a jail: /jail delete name"