(define (domain industrial_manufacturing_service_durative_actions)

  (:requirements :strips :typing :durative-actions :equality :fluents :negative-preconditions) 
  
  (:types
    location box content robot workstation carrier
  )

  (:predicates
    (at_loc ?obj - (either robot workstation box content) ?loc - location)
    (is_empty ?box - box)
    (filled ?box - box ?cont - content)
    (at_ws ?obj - (either robot box content) ?ws - workstation)
    (carrying ?carrier - carrier ?box - box) 
    (connected ?loc1 ?loc2 - location)
    (is_warehouse ?loc - location)  
    (attached ?robot - robot ?carrier - carrier)
  )

  (:functions
    (capacity ?carrier - carrier)
    (load ?carrier - carrier)
  )
  
  (:durative-action move_to_location
    :parameters (?r - robot ?from ?to - location ?car - carrier)
    :duration (= ?duration 3)
    :condition (and 
                (at start(at_loc ?r ?from))
                (over all(connected ?from ?to)) 
                (over all(not (is_warehouse ?to))) 
                (over all(attached ?r ?car))
    )
    :effect (and 
            (at start(not (at_loc ?r ?from)))
            (at end(at_loc ?r ?to))
    )
  )
  
  (:durative-action move_to_warehouse
    :parameters (?r - robot ?from ?to - location ?car - carrier)
    :duration (= ?duration 3)
    :condition (and 
                (at start(at_loc ?r ?from)) 
                (over all(connected ?from ?to)) 
                (over all(is_warehouse ?to)) 
                (over all(attached ?r ?car)) 
              )
    :effect (and 
            (at start(not (at_loc ?r ?from))) 
            (at end(at_loc ?r ?to))
    )
  )
  

  (:durative-action enter_workstation
    :parameters (?r - robot ?loc - location ?ws - workstation ?car - carrier)
    :duration (= ?duration 0)
    :condition (and 
                (over all(at_loc ?ws ?loc)) 
                (at start(at_loc ?r ?loc)) 
                (over all(attached ?r ?car))
    )
    :effect (and 
            (at start(not (at_loc ?r ?loc))) 
            (at end(at_ws ?r ?ws))
    )
  )
  
  (:durative-action exit_workstation
    :parameters (?r - robot ?loc - location ?ws - workstation ?car - carrier)
    :duration (= ?duration 0)
    :condition (and 
                (over all(at_loc ?ws ?loc)) 
                (at start(at_ws ?r ?ws)) 
                (over all(attached ?r ?car))
    ) 
    :effect (and 
            (at end(at_loc ?r ?loc)) 
            (at start(not (at_ws ?r ?ws)))
    )
  )
  
  (:durative-action put_down_box_in_workstation
    :parameters (?r - robot ?box - box ?ws - workstation ?car - carrier)
    :duration (= ?duration 1.5)
    :condition (and 
                (over all (at_ws ?r ?ws)) 
                (at start (carrying ?car ?box)) 
                (over all (attached ?r ?car))
    )
    :effect (and 
            (at start (not (carrying ?car ?box))) 
            (at end (at_ws ?box ?ws)) 
            (at end (decrease (load ?car) 1))
    )
  )
  
  (:durative-action put_down_box_in_location
    :parameters (?r - robot ?box - box ?loc - location ?car - carrier)
    :duration (= ?duration 1.5)
    :condition (and 
                (over all (at_loc ?r ?loc)) 
                (at start (carrying ?car ?box)) 
                (over all (attached ?r ?car))
    )
    :effect (and 
            (at start (not (carrying ?car ?box))) 
            (at end (at_loc ?box ?loc)) 
            (at end (decrease (load ?car) 1))
    )
  )
  
  (:durative-action load_box_from_workstation
    :parameters (?r - robot ?box - box ?ws - workstation ?car - carrier)
    :duration (= ?duration 1.5)
    :condition (and 
                (at start (at_ws ?box ?ws)) 
                (over all (at_ws ?r ?ws)) 
                (over all (attached ?r ?car)) 
                (over all (< (load ?car) (capacity ?car)))
    )
    :effect (and 
            (at end (carrying ?car ?box)) 
            (at end (increase (load ?car) 1)) 
            (at start (not (at_ws ?box ?ws)))
    )
  )
  
  (:durative-action load_box_from_location
    :parameters (?r - robot ?box - box ?loc - location ?car - carrier)
    :duration (= ?duration 1.5)
    :condition (and 
                (at start (at_loc ?box ?loc)) 
                (over all (at_loc ?r ?loc)) 
                (over all (attached ?r ?car)) 
                (over all (< (load ?car) (capacity ?car)))
    )
    :effect (and 
            (at end (carrying ?car ?box)) 
            (at end (increase (load ?car) 1)) 
            (at start (not (at_loc ?box ?loc)))
    )
  )
  
  (:durative-action empty_box_in_workstation
    :parameters (?r - robot ?box - box ?ws - workstation ?con - content ?car - carrier)
    :duration (= ?duration 3.5)
    :condition (and 
                (over all (at_ws ?r ?ws)) 
                (at start (at_ws ?box ?ws)) 
                (at start (filled ?box ?con)) 
                (over all (attached ?r ?car))
    )
    :effect (and 
            (at start (not (filled ?box ?con))) 
            (at end (is_empty ?box)) 
            (at end (at_ws ?con ?ws))
            (at end (at_ws ?box ?ws))
    )
  )

  (:durative-action fill_box_in_workstation
    :parameters (?r - robot ?box - box ?ws - workstation ?con - content ?car - carrier)
    :duration (= ?duration 3.5)
    :condition (and 
                (over all (at_ws ?r ?ws)) 
                (over all (at_ws ?box ?ws)) 
                (at start (at_ws ?con ?ws)) 
                (at start (is_empty ?box)) 
                (over all (attached ?r ?car))
    )
    :effect (and 
            (at start (not (at_ws ?con ?ws))) 
            (at end (filled ?box ?con)) 
            (at start (not (is_empty ?box)))
    )
  )
  
  (:durative-action empty_box_in_location
    :parameters (?r - robot ?box - box ?con - content ?loc - location ?car - carrier)
    :duration (= ?duration 3.5)
    :condition (and 
                (over all (at_loc ?r ?loc)) 
                (at start (at_loc ?box ?loc)) 
                (at start (filled ?box ?con)) 
                (over all (attached ?r ?car))
    )
    :effect (and 
            (at start (not (filled ?box ?con))) 
            (at end (is_empty ?box)) 
            (at end (at_loc ?con ?loc))
    )
  )

  (:durative-action fill_box_in_location
    :parameters (?r - robot ?box - box ?con - content ?loc - location ?car - carrier)
    :duration (= ?duration 3.5)
    :condition (and 
                (over all (not (is_warehouse ?loc))) 
                (over all (at_loc ?r ?loc)) 
                (at start (at_loc ?box ?loc)) 
                (at start (at_loc ?con ?loc)) 
                (at start (is_empty ?box)) 
                (over all (attached ?r ?car))
    )
    :effect (and 
            (at start (not (at_loc ?con ?loc))) 
            (at end (filled ?box ?con)) 
            (at start (not (is_empty ?box)))
    )
  )
  
  (:durative-action fill_box_in_warehouse
    :parameters (?r - robot ?box - box ?con - content ?loc - location ?car - carrier)
    :duration (= ?duration 3.5)
    :condition (and 
                (over all (is_warehouse ?loc)) 
                (over all (at_loc ?r ?loc)) 
                (over all (at_loc ?box ?loc)) 
                (at start (at_loc ?con ?loc)) 
                (at start (is_empty ?box)) 
                (over all (attached ?r ?car))
    )
    :effect (and 
            (at end (filled ?box ?con)) 
            (at start (not (is_empty ?box)))
    )
  )
)