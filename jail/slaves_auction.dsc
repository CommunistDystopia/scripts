# /slaveshop usage
# /slaveshop <slavename> sell - Starts an slave auction. [SupremeWarden]
# /slaveshop <slavename> bid <amount> - Place a bid on an active auction. [Godvip]
# Additional notes
# - If a Godvip tries to cheat, the auction will be canceled
# Server flags created here
# - auction_highest_bidder
# - auction_highest_bid
# Player flags created here
# - owner_block_limit [Used in SlaveLead]

Command_Slave_Shop:
    type: command
    debug: false
    name: slaveshop
    description: Minecraft slave auction system.
    usage: /slaveshop
    script:
        - if !<player.is_op||<context.server>> && !<player.in_group[supremewarden]> && !<player.in_group[godvip]>:
            - narrate "<red>You do not have permission for that command"
            - stop
        - define slave <server.match_player[<context.args.get[1]>]||null>
        - if <[slave]> == null:
            - narrate "<red> ERROR: Wrong username. Try again"
            - stop
        - if !<[slave].in_group[slave]> || !<[slave].has_flag[owner]>:
            - narrate "<red> ERROR: This user isn't a slave"
            - stop
        - if !<[slave].has_flag[slave_timer]> && <[slave].has_flag[owner]> && <[slave].in_group[slave]>:
            - narrate "<red> ERROR: <yellow><[slave].name> <red>is already gotten by <gold>Godvip <red>or a <blue>SupremeWarden"
            - stop
        - define action <context.args.get[2]>
        - if <[action]> == sell && <player.in_group[supremewarden]>:
            - if <server.has_flag[auction_highest_bid]>:
                - narrate "<red> ERROR: There is a <gold>Godvip <red>auction active"
                - stop
            - define online_godvips <server.online_players.filter[in_group[godvip]]>
            - if <[online_godvips].is_empty>:
                - narrate "<red> No <gold>Godvips <red>are online right now. Try when there is a <gold>Godvip <red>online"
                - stop
            - narrate "<green> Starting an auction... Sending a message to the <gold>Godvips<green>..."
            - narrate "<gold> A <red>Slave <gold>auction has started! Starting money: 1" targets:<[online_godvips]>
            - narrate "<green>Use /slaveshop <[slave].name> bid <yellow>amount <green>to place your offer" targets:<[online_godvips]>
            - flag server auction_highest_bid:1
            - wait 15s
            - narrate "<gold> The winner is..."
            - wait 2s
            - define online_godvips_end <server.online_players.filter[in_group[godvip]]>
            - if <[online_godvips_end].is_empty>:
                - narrate "<red> ERROR: All <gold>Godvips <red>are offline. The auction result will be stopped"
                - flag server auction_highest_bidder:!
                - flag server auction_highest_bid:!
                - stop
            - if !<server.has_flag[auction_highest_bidder]>:
                - narrate "<yellow> No one won the auction." targets:<[online_godvips_end]>|<player>
                - flag server auction_highest_bidder:!
                - flag server auction_highest_bid:!
                - stop
            - define highest_bidder <player[<server.flag[auction_highest_bidder]>]>
            - if <[highest_bidder].money> < <server.flag[auction_highest_bid]>:
                - narrate "<red> Do you think that you can trick this plugin? Try again" targets:<[highest_bidder]>
                - narrate "<red> The player <[highest_bidder].name> tried to buy the slave but he spent the money before the auction finished" targets:<[online_godvips_end]>|<[player]>
                - flag server auction_highest_bidder:!
                - flag server auction_highest_bid:!
                - stop
            - take <[highest_bidder]> money quantity:<server.flag[auction_highest_bid]>
            - flag server auction_slave_jail:<[slave].flag[owner]>
            - if <[slave].has_flag[jail_owner]>:
                - flag server auction_slave_jail:<[slave].flag[owner]>
            - define auction_slave_jail_slaves "<server.flag[auction_slave_jail]>_slaves"
            - flag server <[auction_slave_jail_slaves]>:<-:<[slave]>
            - flag server auction_slave_jail:!
            - flag <[slave]> owner:<[highest_bidder].name>
            - flag <[slave]> owner_block_limit:10
            - flag <[slave]> slave_timer:!
            - if <[highest_bidder].is_online>:
                - teleport <[slave]> <[highest_bidder].location>
            - narrate "<gold> <[slave].flag[owner]>!!! Congratulations. <red><[slave].name> <gold>is now your slave" targets:<[online_godvips_end]>
            - narrate "<green> The auction is finished. The <red>slave <green>was <gold>sold"
            - flag server auction_highest_bidder:!
            - flag server auction_highest_bid:!
            - stop
        - if <[action]> == bid && <context.args.size> == 3 && <player.in_group[godvip]>:
            - define amount <context.args.get[3]>
            - if !<server.has_flag[auction_highest_bid]>:
                - narrate "<red> ERROR: There is no <gold>Godvip <red>auction active"
                - stop
            - if <player.money> < amount:
                - narrate "<red> ERROR: You don't have enough money to bid <yellow><[amount]>!"
                - stop
            - if <[amount]> < <server.flag[auction_highest_bid]>
                - narrate "<red> ERROR: You bid is lower than the highest. Please try a higher amount"
                - stop
            - flag server auction_highest_bidder:<player>
            - flag server auction_highest_bid:<[amount]>
            - narrate "<green> You sucessfully placed a bid by the amount of <yellow><[amount]>!"
            - stop
        - narrate "<red> ERROR: Syntax error. Follow the command syntax:"
        - narrate "<red> [SupremeWarden] To start an auction use: /slaveshop <yellow>username <red>sell"
        - narrate "<gold> [Godvip] <red>To place a bid use: /slaveshop <yellow>username <red>bid <yellow>amount"
        