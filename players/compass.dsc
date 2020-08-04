# +----------------------
# |
# | COMPASS TRACKER
# |
# +----------------------
#
# @author devnodachi
# @date 2020/08/03
# @denizen-build REL-1714
#

Compass_Command:
    type: command
    debug: false
    name: compass
    description: Minecraft Tracker Compass system.
    permission: compass.tracker
    usage: /compass
    script:
        - if <context.args.size> == 1:
            - if <context.args.get[1]> == reset:
                - compass reset
                - narrate "<green> Resetting compass to the default... <blue>Bed <green>or <blue>World Spawn"
                - stop
            - define username <server.match_player[<context.args.get[1]>]||null>
            - if <[username]> == null:
                - narrate "<red> ERROR: Invalid player username OR the player is offline."
                - stop
            - compass <[username].location>
            - narrate "<green> Starting to track... <blue><[username].name>"
        - if <context.args.size> == 3:
            - define location <location[<context.args.get[1]>,<context.args.get[2]>,<context.args.get[3]>,world]||null>
            - if <[location]> == null:
                - narrate "<red> ERROR: Invalid location. Please use a valid one"
                - stop
            - compass <[location]>
            - narrate "<green> Starting to track... <blue><[location].xyz.replace[,].with[<gray>, <aqua>]><green>"