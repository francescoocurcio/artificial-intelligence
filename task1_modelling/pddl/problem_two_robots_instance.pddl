(define (problem two_robots_instance_extended)
  (:domain industrial_manufacturing_service)

  (:objects
    location1 location2 location3 warehouse - location
    box1 box2 box3 - box
    bolts valves screws - content
    robot1 robot2 - robot
    workstation1 workstation2 workstation3 - workstation
  )

  (:init
  
    (at_loc robot1 warehouse)
    (at_loc robot2 location3)
    
    (at_loc box1 warehouse)
    (at_loc box2 warehouse)
    (at_loc box3 location3)
    
    (at_loc bolts warehouse)
    (at_loc valves warehouse)
    (at_loc screws location3)
    
    (is_empty box1)
    (is_empty box2)
    (is_empty box3)
    
    (free robot1)
    (free robot2)
    
    (connected location1 location2)
    (connected location2 location3)
    (connected location3 warehouse)
    (connected warehouse location1)

    (connected location2 location1)
    (connected location3 location2)
    (connected warehouse location3)
    (connected location1 warehouse)
    
    (at_loc workstation1 location1)
    (at_loc workstation2 location2)
    (at_loc workstation3 location3)
    
    (is_warehouse warehouse)
  )

  (:goal
    (and
      (at_ws box1 workstation1)
      (at_ws box2 workstation2)
      (at_ws box3 workstation3)
      (filled box1 bolts)
      (filled box2 valves)
      (filled box3 screws)
    )
  )
)
