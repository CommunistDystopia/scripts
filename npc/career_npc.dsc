Interact_Career_NPC:
    type: interact
    steps:
        1:
            chat trigger:
                democracy:
                    trigger: /1/
                    script:
                    - chat "So you want to be free? Let's go!"
                    - teleport <player> <location[-150,47,-25,world]>
                commmunist:
                    trigger: /2/
                    script:
                    - chat "So you want to be part of the regime? Let's go!"
                    - teleport <player> <location[-136,47,-25,world]>
                regular:
                    trigger: /3/
                    script:
                    - chat "So you want to be a civilian? Let's go!"
                    - teleport <player> <location[-148,47,-9,world]>
                border:
                    trigger: /4/
                    script:
                    - chat "So you want to protect Somalia's? Let's go!"
                    - teleport <player> <location[-120,47,-31,world]>

Career_NPC:
    type: assignment
    actions:
        on assignment:
            - trigger name:chat state:true cooldown:10s radius:3
        on click:
            - engage
            - chat "What career are you most interested in?"
            - wait 1s
            - chat "1. I want to fight the communist regime and support democracy and freedom"
            - wait 1s
            - chat "2. I want to support the communist regime in the army."
            - wait 1s
            - chat "3. I want to just live a regular life and do regular civilian jobs."
            - wait 1s
            - chat "4. I want to be on the frontlines protecting Somalia's borders as a border inspector."
            - disengage
    interact scripts:
        - Interact_Career_NPC