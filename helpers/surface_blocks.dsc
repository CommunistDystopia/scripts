Surface_Blocks_Task:
    type: task
    debug: false
    script:
        - if <[location].chunk.is_loaded>:
            - define x <[block_limit].mul[-1]>
            - while <[x]> <= <[block_limit]>:
                - define y <[block_limit].mul[-1]>
                - while <[y]> <= <[block_limit]>:
                    - define z <[block_limit].mul[-1]>
                    - while <[z]> <= <[block_limit]>:
                        - define block <[location].add[<[x]>,<[y]>,<[z]>]>
                        - if <[block].chunk.is_loaded>:
                            - if <[block].material.name> != AIR && <[block].above[1].material.name> == AIR && <[block].above[2].material.name> == AIR:
                                - if <[materials].as_list.contains_any[<[block].material.name>]>:
                                    - define blocks:|:<[block]>
                        - else:
                            - foreach next
                        - define z <[z].add[1]>
                    - define y <[y].add[1]>
                - define x <[x].add[1]>
            - define blocks <[blocks].sort_by_number[distance[<[location]>]]>
