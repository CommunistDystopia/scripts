Command_Jail:
    type: command
    name: jail
    description: Minecraft Towny Raid.
    usage: /jail <&lt>create/delete<&gt> <&lt>name<&gt> <&lt>x1<&gt> <&lt>y1<&gt> <&lt>z1<&gt> <&lt>x2<&gt> <&lt>y2<&gt> <&lt>z2<&gt>
    script:
        - if !<player.is_op||<context.server>> || <player.groups.find[supremewarden]||null> == null:
            - narrate "<red>You do not have permission for that command."
            - stop
        - define name <context.args.get[2]>
        - define jail_name "jail_<[name]>"
        - if <context.args.get[1]> == new:
            - define x1 <context.args.get[3]>
            - define y1 <context.args.get[4]>
            - define z1 <context.args.get[5]>
            - define x2 <context.args.get[6]>
            - define y2 <context.args.get[7]>
            - define z2 <context.args.get[8]>
            - if <location[<[x1]>,<[y1]>,<[z1]>,world]||null> != null && <location[<[x2]>,<[y2]>,<[z2]>,world]||null> != null:
                - if <cuboid[<[jail_name]>]||null> != null:
                    - narrate "<red> The name is used by other jail"
                    - stop
                - note <cuboid[<location[<[x1]>,<[y1]>,<[z1]>,world]>|<location[<[x2]>,<[y2]>,<[z2]>,world]>]> as:<[jail_name]>
                - narrate "<green> Jail <[name]> created!"
                - stop
            - narrate "<red> The location of the jail is invalid."
            - stop
        - if <context.args.get[1]> == delete:
            - if <cuboid[<[jail_name]>]||null> == null:
                - narrate "<red> That jail doesn't exist."
                - stop
            - note remove as:<[jail_name]>
            - narrate "<green> Jail <[name]> deleted!"
            - stop
        - narrate "<red> Error. Follow the command syntax:"
        - narrate  "<yellow> To create a jail: /jails create name x1 y1 z1 x2 y2 z2"
        - narrate  "<yellow> To delete a jail: /jails delete name"