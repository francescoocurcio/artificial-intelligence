(define (problem simple_instance)
  (:domain industrial_manufacturing_service)

  (:objects
    location1 location2 warehouse - location
    box1 box2 - box
    bolts valves - content
    robot - robot
    workstation1 workstation2 - workstation
  )

  (:init
  
    ;il robot viene collocato nella warehouse
    (at_loc robot warehouse)
    
    ;si istanziano due box collocate entrambe alla warehouse
    (at_loc box1 warehouse)
    (at_loc box2 warehouse)
    
    ;i materiali di interesse (di tipo content) sono nella warehouse
    (at_loc bolts warehouse)
    (at_loc valves warehouse)
    
    ;inzialmente le box sono vuote
    (is_empty box1)
    (is_empty box2)
    
    ;il robot è libero: non sta trasportando alcuna box
    (free robot)
    
    ;si stabiliscono i collegamenti tra le location
    ;il predicato non è simmetrico per cui è necessario specificare anche i collegamenti inversi
    (connected location1 location2)
    (connected location2 location1)
    (connected location2 warehouse)
    (connected warehouse location2)
    (connected warehouse location1)
    (connected location1 warehouse)
    
    ;si stabilisce la posizione di ogni workstation: ogni workstation viene assegnata ad una location
    (at_loc workstation1 location1)
    (at_loc workstation2 location2)
    
    ;si individua la location che funge da warehouse
    (is_warehouse warehouse)
  )

  (:goal

    (and
      ;il goal prevede che le due box siano lasciate alle due workstation presenti, ciasucna con un materiale specifico
      (at_ws box1 workstation1)
      (at_ws box2 workstation2)
      (filled box1 bolts)
      (filled box2 valves)
    )
  )
)
