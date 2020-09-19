# +----------------------
# |
# | TOWN BOOK
# |
# +----------------------
#
# @author devnodachi
# @date 2020/09/19
# @denizen-build REL-1714
# @dependency TownyAdvanced/Towny
#

town_book:
  type: book
  debug: false
  title: <server.flag[current_town_book_player].as_player.town.name||null>
  author: Somalia
  signed: true
  text:
  - Town name: <server.flag[current_town_book_player].as_player.town.name||null><n>Population: <server.flag[current_town_book_player].as_player.town.player_count><n>Average Balance: <server.flag[current_town_book_player].as_player.town.residents.parse[money].average.round_to[2]>$<n>Average Criminal Record: <server.flag[current_town_book_player].as_player.town.residents.filter[has_flag[criminal_record]].size.div[<server.flag[current_town_book_player].as_player.town.player_count>].mul[100].round_to[2]>%<n>Average Playtime: <duration[<server.flag[current_town_book_player].as_player.town.residents.parse[statistic[PLAY_ONE_MINUTE]].average>T].formatted><n>Average deaths by starvation: <server.flag[current_town_book_player].as_player.town.residents.filter[has_flag[deaths_by_starvation]].parse[flag[deaths_by_starvation]].average.round_to[2]><n><n><red><element[[UPDATE]].on_click[/townbook]>

Town_Book_Script:
    type: world
    debug: false
    events:
        after player signs book:
            - if <player.town||null> != null && <context.title.to_uppercase> == <player.town.name.to_uppercase>:
                    - if <player.is_op> || <player.has_permission[townbook.get]>:
                        - flag server current_town_book_player:<player>
                        - take <player.item_in_hand>
                        - give town_book
        on player dies cause:STARVATION:
            - flag <player> deaths_by_starvation:++

Town_Book_Command:
    type: command
    debug: false
    name: townbook
    description: A TownBook
    usage: /townbook
    permission: townbook.update
    script:
        - if <context.server>:
            - narrate "<red> ERROR: The server can't get a book!"
            - stop
        - if <player.town||null> == null:
            - stop
        - flag server current_town_book_player:<player>
        - if <player.item_in_hand.is_book>:
            - take <player.item_in_hand>
        - give town_book