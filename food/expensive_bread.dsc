# +----------------------
# |
# | EXPENSIVE BREAD
# |
# +----------------------
#
# @author devnodachi
# @date 2020/08/02
# @denizen-build REL-1714
#

expensive_bread:
    type: item
    debug: false
    material: bread
    display name: Bread
    recipes:
        1:
            type: shaped
            input:
                - hay_block|hay_block|hay_block

Expensive_Bread_Script:
    type: world
    debug: false
    events:
        on item recipe formed:
            - if <context.item.material.name> == BREAD:
                - foreach <context.recipe> as:recipe_item:
                    - if <[recipe_item].material.name> == WHEAT:
                        - determine cancelled
                        - foreach stop