# /slaves Usage
# /slaves jail <jailname> spawn - Sets the spawn point of the slave in the player position.
# /slaves jail <jailname> list - List the slaves in this jail.
# /slaves jail <jailaname> add <username> - Add a player to this jail and forces them to spawn in the jail spawn (OP only)
# WIP:
# /slaves user <username> list - List the slaves of this user.

Command_Slaves:
    type: command
    name: slaves
    description: Minecraft slave system.
    usage: /slaves
    script:
        - if !<player.is_op||<context.server>> || <player.groups.find[supremewarden]||null> == null:
            - narrate "<red>You do not have permission for that command."
            - stop
        - define target <context.args.get[1]>
        - define name <context.args.get[2]>
        - define action <context.args.get[3]>
        - if <[target]> == jail:
            - define jail_name "jail_<[name]>"
            - if <cuboid[<[jail_name]>]||null> == null:
                - narrate "<red> Jail <[name]> doesn't exist."
                - stop
            - if <[action]> == spawn:
                - if !<cuboid[<[jail_name]>].contains_location[<player.location>]>:
                    - narrate "<red> ERROR: Stand on the jail boundary to set the slave spawn."
                    - stop
                - note <player.location> as:<[jail_name]>_spawn
                - narrate "<green> Slave spawn set for the jail <[name]>."
                - stop
        - if <[target]> == user:
            - define "<yellow> Do something..."
            - stop
        - narrate "<red> ERROR: Follow the command syntax:"
        - narrate "<red> /slaves jail jailname spawn/list"