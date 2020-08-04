# +----------------------
# |
# | CRACKSHOT WEAPONS CRAFTABLE
# |
# +----------------------
#
# @author devnodachi
# @date 2020/08/04
# @denizen-build REL-1714
# @dependency Shampaggon/CrackShot DeeCaaD/CrackShotPlus
#

CrackShotCraftable_Script:
    type: world
    debug: false
    events:
        on player crafts placeholder_type95_csp:
            - determine <crackshot.weapon[Type95_CSP]>
        on player crafts placeholder_ak47_csp:
            - determine <crackshot.weapon[AK-47_CSP]>
        on player crafts placeholder_bazooka_csp:
            - determine <crackshot.weapon[Bazooka_CSP]>
        on player crafts placeholder_carbine_csp:
            - determine <crackshot.weapon[Carbine_CSP]>
        on player crafts placeholder_desert_eagle_csp:
            - determine <crackshot.weapon[Desert_Eagle_CSP]>
        on placeholder_type95_csp recipe formed:
            - determine <crackshot.weapon[Type95_CSP]>
        on placeholder_ak47_csp recipe formed:
            - determine <crackshot.weapon[AK-47_CSP]>
        on placeholder_bazooka_csp recipe formed:
            - determine <crackshot.weapon[Bazooka_CSP]>
        on placeholder_carbine_csp recipe formed:
            - determine <crackshot.weapon[Carbine_CSP]>
        on placeholder_desert_eagle_csp recipe formed:
            - determine <crackshot.weapon[Desert_Eagle_CSP]>

placeholder_type95_csp:
    type: item
    debug: false
    material: stick
    mechanisms:
        hides: enchants
    enchantments:
        - unbreaking:1
    display name: <red>Type95
    lore:
        - <gray>Placeholder item for Type95
    recipes:
        1:
            type: shaped
            input:
                - emerald_block|emerald_block|flint_and_steel
                - gunpowder|stick|emerald_block
                - stick|gunpowder|emerald_block

placeholder_ak47_csp:
    type: item
    debug: false
    material: stick
    mechanisms:
        hides: enchants
    enchantments:
        - unbreaking:1
    display name: <red>AK-47
    lore:
        - <gray>Placeholder item for AK-47
    recipes:
        1:
            type: shaped
            input:
                - emerald_block|emerald_block|flint_and_steel
                - emerald_block|stick|emerald_block
                - stick|emerald_block|emerald_block

placeholder_bazooka_csp:
    type: item
    debug: false
    material: stick
    mechanisms:
        hides: enchants
    enchantments:
        - unbreaking:1
    display name: <red>Bazooka
    lore:
        - <gray>Placeholder item for Bazooka
    recipes:
        1:
            type: shaped
            input:
                - emerald_block|emerald_block|fire_charge
                - emerald_block|stick|emerald_block
                - stick|emerald_block|emerald_block

placeholder_carbine_csp:
    type: item
    debug: false
    material: stick
    mechanisms:
        hides: enchants
    enchantments:
        - unbreaking:1
    display name: <red>Carbine
    lore:
        - <gray>Placeholder item for Carbine
    recipes:
        1:
            type: shaped
            input:
                - emerald_block|emerald_block|gunpowder
                - emerald_block|firework_rocket|emerald_block
                - stick|emerald_block|emerald_block

placeholder_desert_eagle_csp:
    type: item
    debug: false
    material: stick
    mechanisms:
        hides: enchants
    enchantments:
        - unbreaking:1
    display name: <red>Desert Eagle
    lore:
        - <gray>Placeholder item for Desert Eagle
    recipes:
        1:
            type: shaped
            input:
                - quartz_slab|quartz_slab|emerald_block
                - stick|air|air
                - stick|air|air