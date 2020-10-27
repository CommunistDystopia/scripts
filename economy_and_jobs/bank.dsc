# +----------------------
# |
# | BANK
# |
# +----------------------
#
# @author devnodachi
# @date 2020/08/21
# @denizen-build REL-1714
#

####################
## BANK
## WITHDRAW
####################

Withdraw_Command:
    type: command
    debug: false
    name: withdraw
    description: Minecraft Withdraw Money from Bank.
    usage: /withdraw
    script:
        - if <context.args.size> < 1:
            - narrate "<red> USAGE: <white>/withdraw <yellow>[amount]"
            - stop
        - define withdraw_amount <context.args.get[1]>
        - if !<[withdraw_amount].is_integer>:
            - narrate "<red> ERROR: <white>Please, withdraw a exact number."
            - stop
        - if <player.money> < <[withdraw_amount]>:
            - narrate "<red> ERROR: <white> You don't have enogh money in the bank!"
            - stop
        - flag <player> withdraw_amount:<[withdraw_amount]>
        - while <player.flag[withdraw_amount]> > 0:
            - if <player.flag[withdraw_amount]> >= 100:
                - give 100_Bill to:<player.inventory>
                - money take quantity:100
                - flag <player> withdraw_amount:-:100
            - if <player.flag[withdraw_amount]> >= 20:
                - give 20_Bill to:<player.inventory>
                - money take quantity:20
                - flag <player> withdraw_amount:-:20
            - if <player.flag[withdraw_amount]> >= 10:
                - give 10_Bill to:<player.inventory>
                - money take quantity:10
                - flag <player> withdraw_amount:-:10
            - if <player.flag[withdraw_amount]> >= 1:
                - give 1_Bill to:<player.inventory>
                - money take quantity:1
                - flag <player> withdraw_amount:-:1
        - narrate "<green> You withdrew <yellow>$<[withdraw_amount]> <green>from your account in the <gold>Bank of Somalia"

####################
## BANK
## DEPOSIT
####################

Deposit_Command:
    type: command
    debug: false
    name: deposit
    description: Minecraft Deposit Money to Bank.
    usage: /deposit
    script:
        - if <context.args.size> < 1:
            - narrate "<red> USAGE: <white>/deposit <yellow>[amount]"
            - stop
        - define deposit_amount <context.args.get[1]>
        - if !<[deposit_amount].is_integer>:
            - narrate "<red> ERROR: <white>Please, deposit a exact number."
            - stop
        - flag <player> inventory_item_money:0
        - flag <player> bank_deposit_amount:<[deposit_amount]>
        - run Bank_Deposit_Check_Task def:1_Bill
        - run Bank_Deposit_Check_Task def:10_Bill
        - run Bank_Deposit_Check_Task def:20_Bill
        - run Bank_Deposit_Check_Task def:100_Bill
        - if <player.flag[inventory_item_money]> < <player.flag[bank_deposit_amount]>:
            - narrate "<red> ERROR: <white>You don't have enough money in your inventory to deposit $<[deposit_amount]>."
            - flag <player> inventory_item_money:!
            - flag <player> bank_deposit_amount:!
            - stop
        - flag <player> inventory_item_money:!
        - run Bank_Deposit_Task def:1_Bill
        - run Bank_Deposit_Task def:10_Bill
        - run Bank_Deposit_Task def:20_Bill
        - run Bank_Deposit_Task def:100_Bill
        - flag <player> bank_change:<player.flag[bank_deposit_amount]>
        - flag <player> bank_deposit_amount:!
        - run Bank_Deposit_Change_Task def:100_Bill
        - run Bank_Deposit_Change_Task def:20_Bill
        - run Bank_Deposit_Change_Task def:10_Bill
        - flag <player> bank_change:!
        - narrate "<green> You deposited <yellow>$<[deposit_amount]> <green>into your account in the <gold>Bank of Somalia"

Bank_Deposit_Check_Task:
    type: task
    debug: false
    definitions: bill_name
    script:
        - if <player.flag[inventory_item_money]> < <player.flag[bank_deposit_amount]>:
            - define bill_value <[bill_name].before[_Bill]>
            - define bill_total_value <player.inventory.quantity.scriptname[<[bill_name]>].mul[<[bill_value]>]>
            - flag player inventory_item_money:+:<[bill_total_value]>

Bank_Deposit_Task:
    type: task
    debug: false
    definitions: bill_name
    script:
        - if <player.flag[bank_deposit_amount]> > 0:
            - define bill_quantity <player.inventory.quantity.scriptname[<[bill_name]>]>
            - define bill_value <[bill_name].before[_Bill]>
            - define bill_total_value <[bill_quantity].mul[<[bill_value]>]>
            - if <player.flag[bank_deposit_amount]> >= <[bill_total_value]>:
                - take <[bill_name]> quantity:<[bill_quantity]> from:<player.inventory>
                - flag <player> bank_deposit_amount:-:<[bill_total_value]>
                - money give quantity:<[bill_total_value]>
            - else:
                - repeat <[bill_quantity]>:
                    - if <player.flag[bank_deposit_amount]> < <[bill_value]>:
                        - repeat stop
                    - take <[bill_name]> quantity:1 from:<player.inventory>
                    - flag player bank_deposit_amount:-:<[bill_value]>

Bank_Deposit_Change_Task:
    type: task
    debug: false
    definitions: bill_name
    script:
        - if <player.flag[bank_change]> > 0:
            - define bill_value <[bill_name].before[_Bill]>
            - if <player.flag[bank_change]> < <[bill_value]>:
                - if <player.inventory.find_imperfect[<item[<[bill_name]>]>]> != -1:
                    - flag player bank_change:<[bill_value].sub[<player.flag[bank_change]>]>
                    - take <[bill_name]> from:<player.inventory>
                    - money give quantity:<[bill_value]>
                    - while <player.flag[bank_change]> > 0:
                        - if <player.flag[bank_change]> >= 20:
                            - give 20_Bill to:<player.inventory>
                            - money take quantity:20
                            - flag <player> bank_change:-:20
                        - if <player.flag[bank_change]> >= 10:
                            - give 10_Bill to:<player.inventory>
                            - money take quantity:10
                            - flag <player> bank_change:-:10
                        - if <player.flag[bank_change]> >= 1:
                            - give 1_Bill to:<player.inventory>
                            - money take quantity:1
                            - flag <player> bank_change:-:1

####################
## BANK
## ITEMS $$$
####################

1_Bill:
    type: item
    debug: false
    material: paper
    mechanisms:
        custom_model_data: 1
    display name: <green>$1
    lore:
        - <gray>Bank of Somalia

10_Bill:
    type: item
    debug: false
    material: paper
    mechanisms:
        custom_model_data: 2
    display name: <green>$10
    lore:
        - <gray>Bank of Somalia

20_Bill:
    type: item
    debug: false
    material: paper
    mechanisms:
        custom_model_data: 3
    display name: <green>$20
    lore:
        - <gray>Bank of Somalia

100_Bill:
    type: item
    debug: false
    material: paper
    mechanisms:
        custom_model_data: 4
    display name: <green>$100
    lore:
        - <gray>Bank of Somalia
