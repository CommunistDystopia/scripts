# /slaves Usage
# /slaves jail <jailname> spawn - Sets the spawn point of the slave in the player position.
# /slaves jail <jailname> list <#> - List the slaves in this jail.
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
        - if <context.args.size> < 3:
            - narrate "<red> ERROR: Not enough arguments. Follow the command syntax:"
            - narrate "<red> /slaves jail <yellow>jailname <red>spawn"
            - narrate "<red> /slaves jail <yellow>jailname <red>list <yellow>number"
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
            - if <[action]> == list && <context.args.size> == 4:
                - define list_page <context.args.get[4]>
                - if <[list_page].is_integer>:
                    - define jail_slaves <server.flag[<[jail_name]>_slaves]||null>
                    - if <[jail_slaves]> == null || <[jail_slaves].is_empty>:
                        - narrate "<green> Jail <blue><[name]> <green>have <blue>0 <green>slaves."
                        - stop
                    - narrate "<green> Jail <blue><[name]> <green>have <blue><[jail_slaves].size> <green>slaves."
                    - if <[jail_slaves].size> > 10:
                        - if <[list_page]> > <[jail_slaves].size.div[10]>:
                            - narrate "<red> ERROR! Page number invalid."
                            - stop
                        - narrate "<green> Page [<[list_page]>/<[jail_slaves].size.div[10].truncate>]"
                        - flag player slave_num_min:<[list_page].mul[10]>
                        - flag player slave_num_max:<[list_page].add[1].mul[10]>
                        - if <[list_page]> != 0 && <player.flag[slave_num_max].div[<[jail_slaves].size>]> != 1:
                            - flag player slave_num_max:<[jail_slaves].size>
                        - if <[list_page]> > 0:
                            - flag player slave_num_min:++
                        - foreach <[jail_slaves].get[<player.flag[slave_num_min]>].to[<player.flag[slave_num_max]>]> as:slave:
                            - if <[loop_index]> == 10:
                                - narrate "<green> Slave <[loop_index]>: <red> <[slave].name>"
                                - foreach stop
                            - narrate "<green> Slave <[list_page]><[loop_index]>: <red> <[slave].name>"
                        - flag player slave_num_max:!
                    - if <[jail_slaves].size> <= 10:
                        - foreach <[jail_slaves]> as:slave:
                            - narrate "<green> Slave <[loop_index]>: <red> <[slave].name>"
                    - stop
        - if <[target]> == user:
            - define "<yellow> Do something..."
            - stop
        - narrate "<red> ERROR: Syntax error. Follow the command syntax:"
            - narrate "<red> /slaves jail <yellow>jailname <red>spawn"
            - narrate "<red> /slaves jail <yellow>jailname <red>list <yellow>number"

Slave_Script:
    type: world
    events:
        on player exits notable cuboid:
            - if !<context.cuboids.parse[notable_name].filter[starts_with[jail]].is_empty>:
                - define jail <context.cuboids.parse[notable_name].filter[starts_with[jail]].first>
                - if <player.groups.find[slave]||null> != null:
                    - define jail_spawn "<[jail]>_spawn"
                    - teleport <player> <location[<[jail_spawn]>]>
                    - hurt <player> 5
                    - narrate "<red> You tried to escape... But you got caught and punched by the guards."
        after player respawns:
            - if <player.groups.find[slave]||null> != null && <player.has_flag[owner]>:
                - define owner_name <player.flag[owner]>
                - teleport <player> <location[<[owner_name]>]>
                - narrate "<red> You died but you're a slave. Now you're with your owner."

slave_pickaxe:
    type: item
    material: iron_pickaxe
    mechanisms:
        repair_cost: 99
        hides: attributes|enchants|unbreakable
        enchantments: unbreaking,1
        unbreakable: true
    display name: <red>Slave Pickaxe
    lore:
        - <gray>Mine with this
        - <gray>pickaxe... <red>SLAVE!
        - <gray>Your resources are
        - <gray>the jail resources.