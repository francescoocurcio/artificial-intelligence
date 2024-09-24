(define (domain industrial_manufacturing_service)

	(:requirements :strips :typing :equality :adl)
	(:types  
		location box content robot workstation carrier slot
	)

	;si introducono due nuovi oggetti: carrier e slot
	;un carrier può essere trasportato da un robot ed ha una capacità massima 
	;gli slot sono necessari per modellare il fatto che un carrier abbia una capacità massima fissa
	;un carrier può avere più slot (nello specifico avrà tanti slot quanti prescritti dalla sua capacità massima) 
	;più slot possono afferire allo stesso carrier 
	;ciascuno slot può ospitare una box
	;secondo questa modellazione è possibile istanziare un numero arbitrario di slot per ciascun carrier in modo che la capacità possa variare
	;la modellazione seguente non prevede utilizzo di fluents o variabili di stato globali 
	
	(:predicates
		(at_loc ?obj - (either robot workstation box content) ?loc - location)
		(is_empty ?box - box)
		(filled ?box - box ?cont - content)
		(at_ws ?obj - (either robot box content) ?ws - workstation)
		(connected ?loc1 ?loc2 - location)
		(is_warehouse ?loc - location)
		;nuovi predicati per la seconda istanza 
		(carrying ?carrier - carrier ?box - box)
		(free ?slot - slot)
		(attached ?rob - robot ?carrier - carrier)
		(holds ?carrier - carrier ?slot - slot)
	)
	
	;il robot si muove da una location ad una adiacente 
	;è necessario assicurarsi, per eseguire questa azione, che la location di destinaizone non sia la warehouse
	;un vincolo del problema, infatti, è quello che il robot possa spostarsi nella warehouse solo se il carrier è vuoto (tutti gli slot free)
	(:action move_to_location
		:parameters (?rob - robot ?from ?to - location ?carrier - carrier)
		:precondition (and 
									(at_loc ?rob ?from) 
									(connected ?from ?to) 
									(attached ?rob ?carrier) 
									(not (is_warehouse ?to))
									)
		:effect (and 
						(not (at_loc ?rob ?from)) 
						(at_loc ?rob ?to)
						)
	)

	;il robot si sposta nella warehouse
	;affinchè il robot possa spostarsi nella warehouse è necessario che il carrier sia vuoto per cui tutti gli slot devono essere liberi
	(:action move_to_warehouse
    :parameters (?rob - robot ?from ?to - location ?carrier - carrier)
    :precondition (and 
					        (at_loc ?rob ?from) 
					        (connected ?from ?to) 
					        (attached ?rob ?carrier) 
					        (is_warehouse ?to)
					        (forall (?slot - slot)
					            (and 
					                (holds ?carrier ?slot)
					                (free ?slot)
					            )
					        ))
    :effect (and 
    				(not (at_loc ?rob ?from)) 
    				(at_loc ?rob ?to)
    				)
	)
	
	;il robot entra in una workstation 
  (:action enter_workstation
    :parameters (?rob - robot ?loc - location ?ws - workstation ?carrier - carrier)
    :precondition (and 
							    (at_loc ?ws ?loc) 
								  (at_loc ?rob ?loc) 
								  (not (at_ws ?rob ?ws))
								  (attached ?rob ?carrier) 
								  )
    :effect (and 
    				(not (at_loc ?rob ?loc)) 
    				(at_ws ?rob ?ws)
    				)
  )
  
  ;il robot esce dalla workstation ma rimane nella location in cui si trova la workstation
  (:action exit_workstation
	  :parameters (?rob - robot ?loc - location ?ws - workstation ?carrier - carrier)
	  :precondition (and 
								  (at_loc ?ws ?loc)
								  (not (at_loc ?rob ?loc))
								  (at_ws ?rob ?ws)
								  (attached ?rob ?carrier)
								  )
	  :effect (and
					  (not (at_ws ?rob ?ws))
					  (at_loc ?rob ?loc)
						)
	)
		
	;il robot posa la scatola che sta traportando nella workstation in cui si trova liberando uno slot del carrier che sta trasportando
	;l'operazione di scaricamento prevede che si possa liberare uno slot per volta
  (:action put_down_box_in_workstation
    :parameters (?rob - robot ?box - box ?ws - workstation ?carrier - carrier ?slot - slot)
    :precondition (and 
							    (at_ws ?rob ?ws) 
							    (carrying ?carrier ?box)
							    (attached ?rob ?carrier)
							    (holds ?carrier ?slot)
							    (not (free ?slot))							    
							    )
    :effect (and 
				    (not (carrying ?carrier ?box)) 
				    (free ?slot) 
				    (at_ws ?box ?ws)
				    )
  )
  
  ;il robot posa una scatola che sta traportando nella location in cui si trova liberando uno slot del carrier che sta trasportando
  ;l'operazione di scaricamento prevede che si possa liberare uno slot per volta
  (:action put_down_box_in_location
    :parameters (?rob - robot ?box - box ?loc - location ?carrier - carrier ?slot - slot)
    :precondition (and 
							    (at_loc ?rob ?loc) 
							    (carrying ?carrier ?box)
							    (attached ?rob ?carrier)
							    (holds ?carrier ?slot)
							    (not (free ?slot))							    
							    )
    :effect (and 
				    (not (carrying ?carrier ?box)) 
				    (free ?slot) 
				    (at_loc ?box ?loc)
				    )
  )
  
  
  ;il robot carica sul carrier (occupando uno slot) una scatola che si trova nella sua stessa worstation
  ;se nessuno slot è libero questa azione non è consentita
  ;l'operazione di caricamento prevede che si possa riempire uno slot per volta
  (:action load_box_from_workstation
    :parameters (?rob - robot ?box - box ?ws - workstation ?carrier - carrier ?slot - slot)
    :precondition (and 
							    (at_ws ?box ?ws) 
							    (at_ws ?rob ?ws) 
							    (attached ?rob ?carrier)
							    (holds ?carrier ?slot)
							    (free ?slot)
							    )
    :effect (and 
				    (carrying ?carrier ?box) 
				    (not (free ?slot)) 
				    (not (at_ws ?box ?ws)))
  )
  
  ;il robot carica sul carrier (occupando uno slot) una scatola che si trova nella sua stessa location
  ;se nessuno slot è libero questa azione non è consentita
  ;l'operazione di scaricamento prevede che si possa riempire uno slot per volta
  (:action load_box_from_location
    :parameters (?rob - robot ?box - box ?loc - location ?carrier - carrier ?slot - slot)
    :precondition (and 
							    (at_loc ?box ?loc) 
							    (at_loc ?rob ?loc) 
							    (attached ?rob ?carrier)
							    (holds ?carrier ?slot)
							    (free ?slot)
							    )
    :effect (and 
				    (carrying ?carrier ?box) 
				    (not (free ?slot)) 
				    (not (at_loc ?box ?loc)))
  )
  
  
  ;se il robot si trova in una workstation con un box pieno lo svuota, posizionando il contenuto nella workstation
  (:action empty_box_in_workstation
    :parameters (?rob - robot ?box - box ?ws - workstation ?con - content ?carrier - carrier)
    :precondition (and 
							    (at_ws ?rob ?ws) 
							    (at_ws ?box ?ws) 
							    (filled ?box ?con)
							    (attached ?rob ?carrier) ;per garantire che il robot resti collegato al carrier (consistenza)
							    )
    :effect (and 
					  (not (filled ?box ?con)) 
					  (is_empty ?box) 
					  (at_ws ?con ?ws))
  )
  
  
  ;se il robot si trova in una workstation con un box vuoto, lo riempie prendendo il contenuto dalla workstation
  (:action fill_box_in_workstation
    :parameters (?rob - robot ?box - box ?ws - workstation ?con - content ?carrier - carrier)
    :precondition (and 
							    (at_ws ?rob ?ws) 
							    (at_ws ?box ?ws) 
							    (at_ws ?con ?ws) 
							    (attached ?rob ?carrier)
							    (is_empty ?box)
							    )
    :effect (and 
				    (not (at_ws ?con ?ws)) 
				    (filled ?box ?con) 
				    (not (is_empty ?box)))
  )
  
  
  ;se il robot si trova in una location con un box pieno lo svuota, posizionando il contenuto nella location
  (:action empty_box_in_location
    :parameters (?rob - robot ?box - box ?con - content ?loc - location ?carrier - carrier)
    :precondition (and 
							    (at_loc ?rob ?loc) 
							    (at_loc ?box ?loc) 
							    (attached ?rob ?carrier)
							    (filled ?box ?con)
							    )
    :effect (and 
				    (not (filled ?box ?con)) 
				    (is_empty ?box) 
				    (at_loc ?con ?loc))
  )


  ;se il robot si trova in una location con un box vuoto, lo riempie prendendo il contenuto dalla location
  (:action fill_box_in_location
    :parameters (?rob - robot ?box - box ?con - content ?loc - location ?carrier - carrier)
    :precondition (and 
							    (not (is_warehouse ?loc))
							    (at_loc ?rob ?loc) 
							    (at_loc ?box ?loc) 
							    (at_loc ?con ?loc) 
							    (is_empty ?box)
							    (attached ?rob ?carrier)
							    )
    :effect (and 
					   (not (at_loc ?con ?loc)) 
					   (filled ?box ?con) 
					   (not (is_empty ?box)))
  )


	;se il robot si trova nella warehouse con un box vuoto lo può riempire con oggetti che si trovano nella warehouse
  (:action fill_box_in_warehouse
    :parameters (?rob - robot ?box - box ?con - content ?loc - location ?carrier - carrier)
    :precondition (and 
							    (is_warehouse ?loc) 
							    (at_loc ?rob ?loc) 
							    (at_loc ?box ?loc) 
							    (at_loc ?con ?loc) 
							    (is_empty ?box)
							    (attached ?rob ?carrier)
							    )
    :effect (and 
				    (filled ?box ?con) 
				    (not (is_empty ?box)))
  )
)