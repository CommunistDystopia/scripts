# +----------------------
# |
# | C O U R T
# |
# | Give prisoners a chance to be free.
# | Open jobs for the Judge and Lawyer groups.
# |
# +----------------------
#
# @author devnodachi
# @date 2020/08/02
# @denizen-build REL-1714
# @dependency devnodachi/jails devnodachi/prisoners
#
# Commands
# - Prisoner Commands
# /court request trial - The prisoner request a trial
# /court request lawyer - The prisoner request a lawyer
# - Judge/SupremeWarden Commands
# /court start <username> - The Judge/SW starts a court with the Prisoner.
# /court request witness <username> - The Judge/SW request the players to be witness.
# /court declare guilty - The Judge/SW declares a prisoner guilty
# /court declare innocent - The Judge/SW declares a prisoner innocent.
# /court remove witness <username> - The Judge/SW removes a witness from the stand.
# /court remove lawyer <username> - The Judge/SW removes a laywer from the court.
# - VIP Commands
# /court spectate - The VIP teleports to their area to spectate.
# - Lawyer Commands
# /court laywer <username> - The Player join as the Lawyer of the Court.
# - Player Commands
# /court witness - The Player join as a witness.

Command_Court:
    type: command
    debug: false
    name: court
    description: Minecraft Court system.
    usage: /court
    tab complete:
        - choose <context.args.size>:
            - case 0:
                - determine <list[request|start|declare|remove|spectate|lawyer|witness]>
            - case 1:
                - if "!<context.raw_args.ends_with[ ]>":
                    - determine <list[request|start|declare|remove|spectate|lawyer|witness].filter[starts_with[<context.args.first>]]>
                - else:
                    - if <context.args.get[1]> == request:
                        - determine <list[trial|lawyer|witness]>
                    - if <context.args.get[1]> == start:
                        - determine <server.online_players.filter[in_group[prisoner]].parse[name]>
                    - if <context.args.get[1]> == declare:
                        - determine <list[guilty|innocent]>
                    - if <context.args.get[1]> == remove:
                        - determine <list[lawyer|witness]>
            - case 2:
                - if <server.has_flag[prison_jails]>:
                    - if "!<context.raw_args.ends_with[ ]>":
                        - if <context.args.get[1]> == request:
                            - determine <list[trial|lawyer|witness]>
                        - if <context.args.get[1]> == start:
                            - determine <server.online_players.filter[in_group[prisoner]].parse[name]>
                        - if <context.args.get[1]> == declare:
                            - determine <list[guilty|innocent]>
                        - if <context.args.get[1]> == remove:
                            - determine <list[lawyer|witness]>
    script:
        - if <context.args.size> < 1:
            - goto syntax_error
        - define action <context.args.get[1]>
        - if <[action]> == spectate:
            - if !<server.has_flag[court_active]>:
                - narrate "<red> ERROR: There is not a court active"
                - stop
            - if <player.in_group[prisoner]>:
                - narrate "<red> ERROR: Slaves can't witness a Court. Even <yellow>VIP <red>prisoners"
                - stop
            - if !<player.in_group[vip]> && !<player.in_group[ultravip]> && !<player.in_group[supremevip]> && !<player.in_group[godvip]>:
                - narrate "<red> ERROR: Only VIPs can spectate a Court"
                - stop
            - teleport <player> <location[court_vip_spot]>
            - narrate "<yellow> COURT:<white> Welcome to the Court <blue><player.name>"
            - stop
        - if <[action]> == witness:
            - if !<server.has_flag[court_active]>:
                - narrate "<red> ERROR: There is not a court active"
                - stop
            - if <player.in_group[prisoner]>:
                - narrate "<red> ERROR: Slaves can't witness a Court"
                - stop
            - if <server.has_flag[court_witness]> && <server.flag[court_witness].contains_all_case_sensitive_text[<player.uuid>]>:
                - narrate "<yellow> COURT:<white> Welcome to the Court as a Witness. Wait 5 seconds and you will join the Court."
                - narrate "<yellow> COURT:<white> You can't talk until the Judge give you the permission to."
                - narrate "<yellow> COURT:<white> If you want to leave, relog or ask the Judge to remove you."
                - teleport <player> <location[court_witness_player_spot]>
                - create player <player.name> <location[court_witness_spot]> save:playernpc
                - wait 5s
                - adjust <player> spectate:<entry[playernpc].created_npc>
                - flag player court_npc:<entry[playernpc].created_npc.id>
                - stop
            - narrate "<red> ERROR: You are not the court Witness"
            - stop
        - if <context.args.size> < 2:
            - goto syntax_error
        - define target <context.args.get[2]>
        - if <[action]> == request:
            - if <[target]> == trial:
                - if !<player.in_group[prisoner]> && !<player.has_flag[prisoner_timer]>:
                    - narrate "<red>You do not have permission for that command."
                    - stop
                - define Online_SupremeWardens <server.online_players.filter[in_group[supremwarden]]>
                - define Online_Judges <server.online_players.filter[in_group[judge]]>
                - if <[Online_SupremeWardens].is_empty> && <[Online_Judges].is_empty>:
                    - narrate "<red> ERROR: All the SupremeWardens and Judge are offline."
                    - narrate "<white> Please consider contacting them on <blue>Discord"
                    - stop
                - if !<[Online_SupremeWardens].is_empty>:
                    - narrate "<yellow> COURT: <white>The Prisoner <red><player.name> <white> is requesting a <red>trial" targets:<[Online_SupremeWardens]>
                    - narrate "<yellow> COURT: <white>Do <red>/court start <player.name> <white>to start the court with the player" targets:<[Online_SupremeWardens]>
                - if !<[Online_Judges].is_empty>:
                    - narrate "<yellow> COURT: <white>The Prisoner <red><player.name> <white> is requesting a <red>trial" targets:<[Online_Judges]>
                    - narrate "<yellow> COURT: <white>Do <red>/court start <player.name> <white>to start the court with the player" targets:<[Online_Judges]>
                - narrate "<green> Request sent. <white>Please wait for any of the online SupremeWardens or Judges to accept your request"
                - stop
            - if <[target]> == lawyer:
                - if !<player.in_group[prisoner]>:
                    - narrate "<red>You do not have permission for that command."
                    - stop
                - if !<server.has_flag[court_active]>:
                    - narrate "<red> ERROR: There isn't a court active"
                    - narrate "<white> Maybe do you want to do <red>/court request trial <white>first"
                    - stop
                - if !<server.flag[court_prisoner].contains_all_case_sensitive_text[<player.uuid>]>:
                    - narrate "<red> ERROR: There is a court active but you aren't the prisoner of the court"
                    - stop
                - define Online_Lawyers <server.online_players.filter[in_group[lawyer]]>
                - if <[Online_Lawyers].is_empty>:
                    - narrate "<red> ERROR: All the Lawyers are offline"
                    - narrate "<white> Please consider contacting them on <blue>Discord"
                    - stop
                - narrate "<yellow> COURT: <white>The prisoner <red><player.name> <white>is requesting a Lawyer" targets:<[Online_Lawyers]>
                - narrate "<yellow> COURT: <white>Do <red>/court lawyer <player.name>" targets:<[Online_Lawyers]>
                - narrate "<green> Request sent. <white>Please wait for any of the online Laywers to accept your request"
                - stop
            - if <[target]> == witness:
                - if !<player.is_op> && !<player.in_group[supremewarden]> && !<player.in_group[judge]>:
                    - narrate "<red>You do not have permission for that command."
                    - stop
                - if !<server.has_flag[court_active]>:
                    - narrate "<red> ERROR: There is not a court active"
                    - stop
                - if !<server.flag[court_lead].contains_all_case_sensitive_text[<player.uuid>]>:
                    - narrate "<red> ERROR: You are not the lead of the current court"
                    - stop
                - if <context.args.size> < 3:
                    - goto syntax_error
                - define username <server.match_player[<context.args.get[3]>]||null>
                - if <[username]> == null:
                    - narrate "<red> ERROR: Invalid player username OR the player is offline."
                    - stop
                - if <[username].in_group[prisoner]>:
                    - narrate "<red> ERROR: Slaves can't be witness in a Court."
                    - stop
                - if <server.has_flag[court_witness]>:
                    - narrate "<red> ERROR: You already invited as witness, please wait until he accepts the invitation or remove them."
                    - narrate "<white> DO: <red>/court remove witness <[username]>"
                    - stop
                - narrate "<yellow> COURT: <white>Sending request to <[username].name>..."
                - flag server court_witness:<[username].uuid>
                - narrate "<yellow> COURT: <white>The lead of the current court is requesting your assistance" targets:<[username]>
                - narrate "<yellow> COURT: <white>To join use the command <red>/court witness" targets:<[username]>
                - stop
        - if <[action]> == start:
            - if !<player.is_op> && !<player.in_group[supremewarden]> && !<player.in_group[judge]>:
                - narrate "<red>You do not have permission for that command."
                - stop
            - if <server.has_flag[court_active]>:
                - narrate "<red> ERROR: There is a court active"
                - stop
            - define username <server.match_player[<context.args.get[2]>]||null>
            - if <[username]> == null:
                - narrate "<red> ERROR: Invalid player username OR the player is offline."
                - stop
            - if !<[username].in_group[prisoner]> && !<[username].has_flag[prisoner_timer]>:
                - narrate "<red> ERROR: This user is not a valid Prisoner."
                - stop
            - flag server court_prisoner:<[username].uuid>
            - flag server court_lead:<player.uuid>
            - flag server court_active:true
            - narrate "<yellow> COURT: <green>The Court has started <red>prisoner. In 5 seconds you will join the Court." targets:<[username]>
            - teleport <[username]> <location[court_prisoner_player_spot]>
            - teleport <player> <location[court_lead_spot]>
            - narrate "<yellow> COURT: <white>Welcome to the Court. Just another day on the job"
            - create player <[username].name> <location[court_prisoner_spot]> save:playernpc
            - wait 5s
            - adjust <[username]> spectate:<entry[playernpc].created_npc>
            - flag <[username]> court_npc:<entry[playernpc].created_npc.id>
            - stop
        - if <[action]> == declare:
            - if !<player.is_op> && !<player.in_group[supremewarden]> && !<player.in_group[judge]>:
                - narrate "<red>You do not have permission for that command."
                - stop
            - if !<server.has_flag[court_active]>:
                - narrate "<red> ERROR: There is not a court active"
                - stop
            - if !<server.flag[court_lead].contains_all_case_sensitive_text[<player.uuid>]>:
                - narrate "<red> ERROR: You are not the lead of the current court"
                - stop
            - define prisoner <player[<server.flag[court_prisoner]>]>
            - if <[target]> == guilty || <[target]> == innocent:
                - if <[target]> == guilty:
                    - teleport <[prisoner]> <location[<[prisoner].flag[owner]>_spawn]>
                    - flag <[prisoner]> prisoner_timer:+:<script[Slaves_Config].data_key[court_fail_timer_add]>
                    - narrate "<white> The Prisoner <red><[prisoner].name> <white>is declared <red>Guilty" targets:<server.online_players>
                    - narrate "<white> Welcome back to the Jail! With <red>2 hours <white>more." targets:<[prisoner]>
                - if <[target]> == innocent:
                    - execute as_server "prisoners remove <[prisoner].flag[owner].after[jail_]> <[prisoner].name>" silent
                    - narrate "<white> The Prisoner <red><[prisoner].name> <white>is declared <green>Innocent" targets:<server.online_players>
                    - narrate "<green> You're free! <white>/t spawn out!" targets:<[prisoner]>
                - run Court_Task_Script def:<[prisoner]>
                - stop
        - if <[action]> == remove:
            - if !<player.is_op> && !<player.in_group[supremewarden]> && !<player.in_group[judge]>:
                - narrate "<red>You do not have permission for that command."
                - stop
            - if !<server.has_flag[court_active]>:
                - narrate "<red> ERROR: There is not a court active"
                - stop
            - if !<server.flag[court_lead].contains_all_case_sensitive_text[<player.uuid>]>:
                - narrate "<red> ERROR: You are not the lead of the current court"
                - stop
            - if <[target]> == witness || <[target]> == lawyer:
                - if <context.args.size> < 3:
                    - goto syntax_error
                - define username <server.match_player[<context.args.get[3]>]||null>
                - if <[username]> == null:
                    - narrate "<red> ERROR: Invalid player username OR the player is offline."
                    - stop
                - if <[target]> == witness && <server.flag[court_witness].contains_all_case_sensitive_text[<[username].uuid>]>:
                    - if <[username].has_flag[court_npc]>:
                        - adjust <[username]> spectate:<[username]>
                        - remove <npc[<[username].flag[court_npc]>]>
                        - flag <[username]> court_npc:!
                    - flag server court_witness:!
                    - narrate "<yellow> COURT: <blue><player.name> <white>kicked you out" targets:<[username]>
                    - narrate "<yellow> COURT: <white>Witness <red><[username].name> <white>kicked"
                    - stop
                - if <[target]> == laywer && <server.flag[court_lawyer].contains_all_case_sensitive_text[<[username].uuid>]>:
                    - flag server court_lawyer:!
                    - narrate "<yellow> COURT: <blue><player.name> <white>kicked you out" targets:<[username]>
                    - narrate "<yellow> COURT: <white>Laywer <red><[username].name> <white>kicked"
                    - stop
                - narrate "<red> ERROR: <white>This player is not part of the Court. Maybe is from another group?"
                - stop
        - if <[action]> == lawyer && <player.in_group[lawyer]>:
            - if !<player.in_group[lawyer]>:
                - narrate "<red>You do not have permission for that command."
                - stop
            - if !<server.has_flag[court_active]>:
                - narrate "<red> ERROR: There is not a court active"
                - stop
            - define username <server.match_player[<[target]>]||null>
            - if <[username]> == null:
                - narrate "<red> ERROR: Invalid player username OR the player is offline."
                - stop
            - if !<server.flag[court_prisoner].contains_all_case_sensitive_text[<[username].uuid>]>:
                - narrate "<red> ERROR: The player is not the <white>Prisoner <red>of the court"
                - stop
            - if <server.has_flag[court_lawyer]>:
                - narrate "<red> ERROR: The active court already has a lawyer"
                - stop
            - flag server court_lawyer:<player.uuid>
            - narrate "<yellow> COURT: <white>Welcome Lawyer. You are gonna be teleported to your job"
            - teleport <player> <location[court_lawyer_spot]>
            - stop
        - mark syntax_error
        - narrate "<yellow>#<red> ERROR: Syntax error. Follow the command syntax:"
        - if <player.is_op> || <player.in_group[prisoner]>:
            - narrate "<yellow>-<red> To request a trail in a court: <white>/court request trail"
            - narrate "<yellow>-<red> To request a lawyer in a court: <white>/court request lawyer"
            - stop
        - if <player.is_op> || <player.in_group[supremewarden]> || <player.in_group[judge]>:
            - narrate "<yellow>-<red> To start a Court with a prisoner: <white>/court start <yellow>username"
            - narrate "<yellow>-<red> To request witness: <white>/court request witness"
            - narrate "<yellow>-<red> To declare the prisoner guilty: <white>/court declare guilty"
            - narrate "<yellow>-<red> To declare the prisoner innocent: <white>/court declare innocent"
            - narrate "<yellow>-<red> To remove a witness: <white>/court remove witness <yellow>username"
            - narrate "<yellow>-<red> To remove a lawyer: <white>/court remove lawyer <yellow>username"
        - if <player.is_op> || <player.in_group[vip]> || <player.in_group[ultravip]> || <player.in_group[supremevip]> || <player.in_group[godvip]>:
            - narrate "<yellow>-<red> To spectate a court: <white>/court spectate"
        - if <player.is_op> || <player.in_group[lawyer]>:
            - narrate "<yellow>-<red> To be the lawyer of a court: <white>/court lawyer"
        - narrate "<yellow>-<red> To be a witness of a court: <white>/court witness"

Court_Script:
    type: world
    debug: false
    events:
        on player quits:
            - if <server.has_flag[court_active]>:
                - if <server.has_flag[court_witness]> && <server.flag[court_witness].contains_all_case_sensitive_text[<player.uuid>]>:
                    - if <player.has_flag[court_npc]>:
                        - remove <npc[<player.flag[court_npc]>]>
                        - flag player court_npc:!
                    - flag server court_witness:!
                - if <server.flag[court_prisoner].contains_all_case_sensitive_text[<player.uuid>]> || <server.flag[court_lead].contains_all_case_sensitive_text[<player.uuid>]>:
                    - narrate "<yellow> COURT: <white>The player <player.name> left the server while in a court" targets:<server.online_players>
                    - if <player.in_group[prisoner]>:
                        - narrate "<yellow> COURT: <white>The player is the <red>Prisoner <white>of the court" targets:<server.online_players>
                    - if <player.is_op> || <player.in_group[supremewarden]> || <player.in_group[judge]>:
                        - narrate "<yellow> COURT: <white>The player is the <yellow>Lead <white>of the court" targets:<server.online_players>
                    - narrate "<yellow> COURT: <white>Wait 1 minute for him or the Court will end with no result" targets:<server.online_players>
                    - wait 1m
                    - if !<player.is_online>:
                        - run Court_Task_Script def:<player[<server.flag[court_prisoner]>]>
                        - narrate "<yellow> COURT: <white>The Court ended without a result" targets:<server.online_players>
        after player join:
            - wait 5s
            - if <player.is_online>:
                - if <server.has_flag[court_active]>:
                    - if <server.flag[court_prisoner].contains_all_case_sensitive_text[<player.uuid>]>:
                        - adjust <player> spectate:<npc[<player.flag[court_npc]>]>

Court_Task_Script:
    type: task
    debug: false
    definitions: prisoner
    script:
        - if <[prisoner].is_online>:
            - adjust <[prisoner]> spectate:<[prisoner]>
        - remove <npc[<[prisoner].flag[court_npc]>]>
        - flag <[prisoner]> court_npc:!
        - flag server court_prisoner:!
        - if <server.has_flag[court_witness]>:
            - define witness <player[<server.flag[court_witness]>]>
            - if <[witness].is_online> && <[witness].has_flag[court_npc]>:
                - adjust <[witness]> spectate:<[witness]>
                - remove <npc[<[witness].flag[court_npc]>]>
                - flag <[witness]> court_npc:!
        - flag server court_witness:!
        - flag server court_lead:!
        - flag server court_lawyer:!
        - flag server court_active:!