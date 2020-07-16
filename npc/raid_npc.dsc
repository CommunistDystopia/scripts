Command_Raid_NPC:
    type: command
    debug: false
    name: raid
    description: Minecraft Towny Raid.
    usage: /raid <&lt>town<&gt> <&lt>start/stop<&gt> <&lt>number<&gt>
    tab complete:
        - if !<player.is_op||<context.server>>:
            - stop
        - choose <context.args.size>:
            - case 0:
                - determine <list[start|stop]>
            - case 1:
                - if "!<context.raw_args.ends_with[ ]>":
                    - determine <list[start|stop].filter[starts_with[<context.args.first>]]>
    script:
        # To set the town_boundaries check the town size on the config file of Towny
        # Half the amount and it will be the town boundaries.
        # e.g. If the town is 16x16, the boundaries are 16/2 = 8
        - if !<player.is_op||<context.server>>:
            - narrate "<red>You do not have permission for that command."
            - stop
        - define town_boundary 8
        - define town_name <context.args.get[1]>
        - define bandit_number 1
        - define bandit_name Bandit
        - if <town[<[town_name]>]||null> == null:
            - narrate "<red> Please try to use a valid town name"
            - stop
        - else:
            - if <context.args.get[2]||null> != null:
                - if <context.args.get[2]> == stop:
                    - narrate "<yellow> Stopping the raid... The bandits will leave soon..."
                    - remove <server.flag[bandits]>
                    - flag server bandits:!
                    - stop
                - if <context.args.get[2]> == start:
                    - if <context.args.get[3]> >= 1 && <context.args.get[3]> <= 5:
                        - define bandit_number <context.args.get[3]>
                        - narrate "<green> Starting a raid with <[bandit_number]> bandits"
                    - else:
                        - narrate "<red> Use a valid bandit number! (Between 1 and 5)"
                        - stop
        - repeat <[bandit_number]>:
            - if <[value]> == 1:
                - create player "<[bandit_name]> <[value]>" <town[<[town_name]>].spawn.left[<[town_boundary].add[<util.random.int[20].to[25]>].add[<[value]>]>]> save:bobnpc
            - if <[value]> == 2:
                - create player "<[bandit_name]> <[value]>" <town[<[town_name]>].spawn.right[<[town_boundary].add[<util.random.int[20].to[25]>].add[<[value]>]>]> save:bobnpc
            - if <[value]> == 3:
                - create player "<[bandit_name]> <[value]>" <town[<[town_name]>].spawn.backward[<[town_boundary].add[<util.random.int[20].to[25]>].add[<[value]>]>]> save:bobnpc
            - if <[value]> == 4:
                - create player "<[bandit_name]> <[value]>" <town[<[town_name]>].spawn.forward[<[town_boundary].add[<util.random.int[20].to[25]>].add[<[value]>]>]> save:bobnpc
            - if <[value]> == 5:
                - create player "<[bandit_name]> <[value]>" <town[<[town_name]>].spawn.left[<[town_boundary].add[<util.random.int[20].to[25]>].add[<[value]>]>]> save:bobnpc
            - wait 1T
            - adjust <entry[bobnpc].created_npc> teleport_on_stuck:true
            - if <[value]> < 5:
                - adjust <entry[bobnpc].created_npc> speed:<util.random.decimal[1.2].to[1.4]>
            - else:
                - adjust <entry[bobnpc].created_npc> speed:<util.random.decimal[1.5].to[1.6]>
            - adjust <entry[bobnpc].created_npc> skin_blob:eyJ0aW1lc3RhbXAiOjE1ODU2MDUyODM5NjAsInByb2ZpbGVJZCI6IjkxZmUxOTY4N2M5MDQ2NTZhYTFmYzA1OTg2ZGQzZmU3IiwicHJvZmlsZU5hbWUiOiJoaGphYnJpcyIsInNpZ25hdHVyZVJlcXVpcmVkIjp0cnVlLCJ0ZXh0dXJlcyI6eyJTS0lOIjp7InVybCI6Imh0dHA6Ly90ZXh0dXJlcy5taW5lY3JhZnQubmV0L3RleHR1cmUvOGM2NWQ4OTdlNWRkNzdiZjgxYTNjZjhkZTllMWQxMmRlYTI1NmU4MWE5ZjcxMTBhYmNhMzU2NjkyYTE3MDNhYSJ9fX0=;XJotIjWxKr+So/pSF3wOmWext7giPtdhh2IoJVOoy4lLE3w88MwM+JWUBnsDQud2EAjX2P9NFOtGb/7Mat22w0nqoMezQlR5CmN3857MWz/JeMV7N+JvZWya9HsyWv6Wermo+4wl+XK6R8cqoeHC+mIIceKLyz4pytb4biklFPoII6MLbPuQKCSWrxKQ/3oByZokHqRv7ArxOysUVlJurpOsYT7vfJUATgHn9c23f/A3Gh2O5QJ9fYZ5/6ybqJAEocOEZbnZ+vTGNqMVztwYN+7fx1cAbfLl0SYXoG2oX12aJWWw4mXt5U1nsTw7+M5ZqTjo5zBMhpztIS5ds76alD1oWu0ni6kbKmVsm7Pv1U8Fg1Bptp1fVZq2T9d/+Dx+uZy7Gp/oX4HFtn3g9NraPdPkyKPgVsn23BL9scUek2iLrRZC5OamTVtszUHfkSDfCwr9r0bipNkfBE+FidooaT6qbiOXGrztp6CIUP457qVg/3BWxVYdn9tOX3C9lt2mvpADVKuCDrvoVDfOSx811V0MECpYejaXzCDy0xy/iSASpgz0V6CAmfSIXtvTWo8xwX6VGLDSHfT3pdjUOju3sKvg0VuQtk/gEadn9quMgw4FS/hiJ4wHkzNR2cdOwWFYVzcxHsWsOO9GIHTZCkCDNsGvkCX0mrxZ3Rokw54WzO4=;http://textures.minecraft.net/texture/8c65d897e5dd77bf81a3cf8de9e1d12dea256e81a9f7110abca356692a1703aa
            - wait 1T
            # The bandit weapon need to be save manually with /ex flag server bandit_weapon:<player.inventory.slot[X]>
            - equip <entry[bobnpc].created_npc> hand:<server.flag[bandit_weapon]>
            - flag server bandits:|:<entry[bobnpc].created_npc>
        - ~walk <server.flag[bandits]> <town[<[town_name]>].spawn.right[<[town_boundary]>]> auto_range
        - foreach <server.flag[bandits]>:
            - trait npc:<[value]> state:true sentinel
            - execute as_server "sentinel addtarget player --id <[value].id>" silent
            - execute as_server "sentinel respawntime -1 --id <[value].id>" silent
            - execute as_server "sentinel safeshot true --id <[value].id>" silent
            - execute as_server "sentinel addignore npc --id <[value].id>" silent
        - adjust <server.flag[bandits]> add_waypoint:<town[<[town_name]>].spawn.right[<[town_boundary].add[12]>]>
        - adjust <server.flag[bandits]> add_waypoint:<town[<[town_name]>].spawn.right[<[town_boundary]>].left[12]>
        - wait 30m
        - foreach <server.flag[bandits]>:
            - if <[value]||null> != null:
                - remove <[value]>
        - flag server bandits:!