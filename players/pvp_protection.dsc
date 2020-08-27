# +----------------------
# |
# | PVP PROTECTION
# |
# +----------------------
#
# @author devnodachi
# @date 2020/08/23
# @denizen-build REL-1714
#

PVP_Protection_Script:
    type: world
    debug: false
    events:
        on player joins:
            - flag <player> hasPvpProtection:true duration:10s
        on player damaged:
            - if <context.entity.has_flag[hasPvpProtection]>:
                - determine cancelled