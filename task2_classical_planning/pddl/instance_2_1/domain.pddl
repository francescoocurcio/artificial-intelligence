(define (domain industrial_manufacturing_service)

	(:requirements :strips :typing :equality :adl :universal-preconditions)

	(:types
		location box content robot workstation
	)

	(:predicates
		(at_loc ?obj - (either robot workstation box content) ?loc - location)
		(at_ws ?obj - (either robot box content) ?ws - workstation)
		(is_empty ?box - box)
		(filled ?box - box ?cont - content)
		(carrying ?robot - robot ?box - box)
		(free ?robot - robot) 
		(connected ?loc1 ?loc2 - location)
		(is_warehouse ?loc - location)  ;individuiamo una ed una sola location come warehouse che ipotizziamo abbia infinite risorse
	)
	
	;il robot si muove da una location ad una adiacente
	;non ci preoccupiamo della posizione di eventuali box trasportate dal robot in quanto queste risultano in transito sul robot
	;il predicato carrying permette di gestire ciò
	(:action move_to_location
	  :parameters (?r - robot ?from - location ?to - location)
	  :precondition (and (at_loc ?r ?from) (connected ?from ?to))
	  :effect (and (not (at_loc ?r ?from)) (at_loc ?r ?to))
	)
	
	;il robot entra in una workstation (facciamo risultare che il robot non è più dentro la location per evitare inconsistenze). 
	(:action enter_workstation
	  :parameters (?r - robot ?loc - location ?ws - workstation)
	  :precondition (and (at_loc ?ws ?loc) (at_loc ?r ?loc) (not (at_ws ?r ?ws)) )
	  :effect (and (not (at_loc ?r ?loc)) (at_ws ?r ?ws))
	)
	
	;il robot esce dalla workstation, ma comunque rimane nella location
	(:action exit_workstation
	  :parameters (?r - robot ?loc - location ?ws - workstation)
	  :precondition (and (at_loc ?ws ?loc) (not (at_loc ?r ?loc)) (at_ws ?r ?ws))
	  :effect (and (at_loc ?r ?loc) (not (at_ws ?r ?ws)))
	)
	
	;il robot posa la scatola che sta traportando nella workstation in cui si trova
	(:action put_down_box_in_workstation
	  :parameters (?r - robot ?box - box ?ws - workstation)
	  :precondition (and (at_ws ?r ?ws) (carrying ?r ?box))
	  :effect (and (not (carrying ?r ?box)) (free ?r) (at_ws ?box ?ws))
	)
	
	;il robot posa la scatola che sta traportando nella location in cui si trova
	(:action put_down_box_in_location
	  :parameters (?r - robot ?box - box ?loc - location)
	  :precondition (and (at_loc ?r ?loc) (carrying ?r ?box))
	  :effect (and (not (carrying ?r ?box)) (free ?r) (at_loc ?box ?loc))
	)
	
	;il robot solleva la scatola dalla workstation in cui si trova per trasportarla
	;la box e il robot si devono trovare nella stessa workstation e il robot deve essere libero
	;nel momento in cui il robot prende la scatola dalla workstation, questa risulterà in transito sul robot
	(:action put_up_box_from_workstation
	  :parameters (?r - robot ?box - box ?ws - workstation)
	  :precondition (and (at_ws ?box ?ws) (at_ws ?r ?ws) (free ?r))
	  :effect (and (carrying ?r ?box) (not (free ?r)) (not (at_ws ?box ?ws)))
	)
	
	;il robot solleva la scatola dalla location in cui si trova per trasportarla
	;la box e il robot si devono trovare nella stessa location e il robot deve essere libero
	;nel momento in cui il robot prende la scatola dalla location, questa risulterà in transito sul robot
	(:action put_up_box_from_location
	  :parameters (?r - robot ?box - box ?loc - location)
	  :precondition (and (at_loc ?box ?loc) (at_loc ?r ?loc) (free ?r))
	  :effect (and (carrying ?r ?box) (not (free ?r)) (not (at_loc ?box ?loc)))
	)
	
	;il robot svuota una scatola lasciando il contenuto nella workstation
	;se il robot non è occupato e si trova in una workstation con un box pieno può svuotarlo, posizionando il contenuto nella workstation
	(:action empty_box_in_workstation
	  :parameters (?r - robot ?box - box ?ws - workstation ?con - content)
	  :precondition (and (free ?r) (at_ws ?r ?ws) (at_ws ?box ?ws) (filled ?box ?con))
	  :effect (and (not (filled ?box ?con)) (is_empty ?box) (at_ws ?con ?ws))
	)
	
	;il robot riempie una scatola con il contenuto che si trova presso la workstation
	;se il robot non è occupato e si trova in una workstation con un box vuoto può riempirlo, prendendo il contenuto dalla workstation
	(:action fill_box_in_workstation
	  :parameters (?r - robot ?box - box ?ws - workstation ?con - content)
	  :precondition (and (free ?r) (at_ws ?r ?ws) (at_ws ?box ?ws) (at_ws ?con ?ws) (is_empty ?box))
	  :effect (and  (not (at_ws ?con ?ws)) (filled ?box ?con) (not (is_empty ?box)))
	)
	
	;il robot svuota una scatola lasciando il contenuto nella location
	;se il robot non è occupato e si trova in una location con un box pieno può svuotarlo, posizionando il contenuto nella workstation
	(:action empty_box_in_location
	  :parameters (?r - robot ?box - box ?con - content ?loc - location)
	  :precondition (and (free ?r) (at_loc ?r ?loc) (at_loc ?box ?loc) (filled ?box ?con))
	  :effect (and (not (filled ?box ?con)) (is_empty ?box) (at_loc ?con ?loc))
	)
	
	;il robot riempie una scatola con il contenuto che si trova presso la location
	;se il robot non è occupato e si trova in una location con un box vuoto può riempirlo, prendendo il contenuto dalla location
	(:action fill_box_in_location
	  :parameters (?r - robot ?box - box ?con - content ?loc - location)
	  :precondition (and (not (is_warehouse ?loc)) (free ?r) (at_loc ?r ?loc) (at_loc ?box ?loc) (at_loc ?con ?loc) (is_empty ?box))
	  :effect (and (not (at_loc ?con ?loc)) (filled ?box ?con) (not (is_empty ?box)))
	)
	
	;il robot riempie una scatola con il contenuto che si trova presso la warehouse
	;se il robot non è occupato e si trova nella warehouse con un box vuoto può riempirlo
	(:action fill_box_in_warehouse
	  :parameters (?r - robot ?box - box ?con - content ?loc - location)
	  :precondition (and (is_warehouse ?loc) (free ?r) (at_loc ?r ?loc) (at_loc ?box ?loc) (at_loc ?con ?loc) (is_empty ?box))
	  :effect (and (filled ?box ?con) (not (is_empty ?box)))
	)
)