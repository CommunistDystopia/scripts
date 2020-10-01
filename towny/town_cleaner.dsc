# +----------------------
# |
# | TOWN CLEANER
# |
# +----------------------
#
# @author devnodachi
# @date 2020/10/01
# @denizen-build REL-1714
# @dependency TownyAdvanced/Towny
#

TownCleaner_Script:
    type: world
    debug: false
    events:
        on ta command:
            - if <context.args.size> == 3 && <context.args.get[3]> == delete:
                - execute as_server "border <context.args.get[2]> remove"
                - execute as_server "townjail <context.args.get[2]> remove"
                - narrate "<red> The town <yellow><context.args.get[2]> <red>data has been removed..."