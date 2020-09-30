# +----------------------
# |
# | PRISONERS AUCTION
# |
# | Sell prisoners in jail to others.
# |
# +----------------------
#
# @author devnodachi
# @date 2020/08/02
# @denizen-build REL-1714
# @dependency devnodachi/jails devnodachi/prisoners
#
# Commands
# /prisonershop sell <prisonername> - Starts an prisoner auction. [SupremeWarden]
# /prisonershop bid <prisonername> <amount> - Place a bid on an active auction. [Godvip]
# Additional notes
# - If a Godvip tries to cheat, the auction will be canceled
# Server flags created here
# - auction_highest_bidder
# - auction_highest_bid

Command_Slave_Auction:
    type: command
    debug: false
    name: prisonerauction
    aliases:
        - prisonerauc
    description: Minecraft prisoner auction system.
    usage: /prisonerauction
    tab complete:
        - if !<player.is_op||<context.server>> && !<player.in_group[supremewarden]> && !<player.in_group[godvip]>:
            - stop
        - choose <context.args.size>:
            - case 0:
                - determine <list[sell|bid]>
            - case 1:
                - if "!<context.raw_args.ends_with[ ]>":
                    - determine <list[sell|bid].filter[starts_with[<context.args.first>]]>
                - else:
                    - determine <server.online_players.filter[in_group[prisoner]].parse[name]>
            - case 2:
                - if "!<context.raw_args.ends_with[ ]>":
                    - determine <server.online_players.filter[in_group[prisoner]].parse[name]>
    script:
        - if !<player.is_op||<context.server>> && !<player.in_group[supremewarden]> && !<player.in_group[godvip]>:
            - narrate "<red>You do not have permission for that command"
            - stop
        - if <context.args.size> < 2:
            - narrate "<yellow>#<red><red> ERROR: Not enough arguments. Follow the command syntax:"
            - narrate "<yellow>-<red><red> [SupremeWarden] To start an auction use: /prisonershop sell <yellow>username"
            - narrate "<yellow>-<red><gold> [Godvip] <red>To place a bid use: /prisonershop bid <yellow>username <yellow>amount"
        - define action <context.args.get[1]>
        - define prisoner <server.match_player[<context.args.get[2]>]||null>
        - if <[prisoner]> == null:
            - narrate "<red> ERROR: Invalid player username OR the player is offline."
            - stop
        - if !<[prisoner].in_group[prisoner]> || !<[prisoner].has_flag[owner]>:
            - narrate "<red> ERROR: This user isn't a prisoner"
            - stop
        - if !<[prisoner].has_flag[prisoner_timer]> && <[prisoner].has_flag[owner]> && <[prisoner].in_group[prisoner]>:
            - narrate "<red> ERROR: <yellow><[prisoner].name> <red>is already gotten by <gold>Godvip <red>or a <blue>SupremeWarden"
            - stop
        - if <[action]> == sell:
            - if !<player.is_op> && !<player.in_group[supremewarden]>:
                - narrate "<red>You do not have permission for that command"
                - stop
            - if <server.has_flag[auction_highest_bid]>:
                - narrate "<red> ERROR: There is a <gold>Godvip <red>auction active"
                - stop
            - define online_godvips <server.online_players.filter[in_group[godvip]]>
            - if <[online_godvips].is_empty>:
                - narrate "<red> No <gold>Godvips <red>are online right now. Try when there is a <gold>Godvip <red>online"
                - stop
            - narrate "<green> Starting an auction... Sending a message to the <gold>Godvips<green>..."
            - narrate "<gold> A <red>Prisoner <gold>auction has started! Starting money: 1" targets:<[online_godvips]>
            - narrate "<green>Use /prisonershop bid <yellow><[prisoner].name> amount <green>to place your offer" targets:<[online_godvips]>
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
                - narrate "<red> The player <[highest_bidder].name> tried to buy the prisoner but he spent the money before the auction finished" targets:<[online_godvips_end]>|<[player]>
                - flag server auction_highest_bidder:!
                - flag server auction_highest_bid:!
                - stop
            - take from:<[highest_bidder].inventory> money quantity:<server.flag[auction_highest_bid]>
            - flag server <[prisoner].flag[owner]>_prisoners:<-:<[prisoner]>
            - flag <[prisoner]> owner:<[highest_bidder].uuid>
            - flag <[prisoner]> prisoner_timer:!
            - if <[highest_bidder].is_online>:
                - teleport <[prisoner]> <[highest_bidder].location>
            - narrate "<gold> <[highest_bidder].name>!!! Congratulations. <red><[prisoner].name> <gold>is now your prisoner" targets:<[online_godvips_end]>
            - narrate "<green> The auction is finished. The <red>prisoner <green>was <gold>sold"
            - flag server auction_highest_bidder:!
            - flag server auction_highest_bid:!
            - stop
        - if <[action]> == bid && <context.args.size> == 3:
            - define amount <context.args.get[3]>
            - if !<server.has_flag[auction_highest_bid]>:
                - narrate "<red> ERROR: There is no <gold>Godvip <red>auction active"
                - stop
            - if <player.money> < <[amount]>:
                - narrate "<red> ERROR: You don't have enough money to bid <yellow><[amount]>!"
                - stop
            - if <[amount]> < <server.flag[auction_highest_bid]>:
                - narrate "<red> ERROR: You bid is lower than the highest. Please try a higher amount"
                - stop
            - flag server auction_highest_bidder:<player>
            - flag server auction_highest_bid:<[amount]>
            - narrate "<green> You sucessfully placed a bid by the amount of <yellow><[amount]>!"
            - stop
        - narrate "<yellow>#<red><red> ERROR: Syntax error. Follow the command syntax:"
        - narrate "<yellow>-<red><red> [SupremeWarden] To start an auction use: /prisonershop sell <yellow>username"
        - narrate "<yellow>-<red><gold> [Godvip] <red>To place a bid use: /prisonershop bid <yellow>username <yellow>amount"
        