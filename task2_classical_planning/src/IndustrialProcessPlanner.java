import fr.uga.pddl4j.heuristics.state.StateHeuristic;
import fr.uga.pddl4j.parser.DefaultParsedProblem;
import fr.uga.pddl4j.parser.RequireKey;
import fr.uga.pddl4j.plan.Plan;
import fr.uga.pddl4j.plan.SequentialPlan;
import fr.uga.pddl4j.planners.AbstractPlanner;
import fr.uga.pddl4j.planners.Planner;
import fr.uga.pddl4j.planners.PlannerConfiguration;
import fr.uga.pddl4j.planners.ProblemNotSupportedException;
import fr.uga.pddl4j.planners.SearchStrategy;
import fr.uga.pddl4j.planners.statespace.search.StateSpaceSearch;
import fr.uga.pddl4j.problem.DefaultProblem;
import fr.uga.pddl4j.problem.Problem;
import fr.uga.pddl4j.problem.State;
import fr.uga.pddl4j.problem.operator.Action;
import fr.uga.pddl4j.problem.operator.ConditionalEffect;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import picocli.CommandLine;

//Import di librerie utili al calcolo della memoria e del tempo utilizzati
import java.lang.management.ManagementFactory;
import java.lang.management.MemoryMXBean;
import java.lang.management.MemoryUsage;
import java.util.*;

import java.util.Comparator;
import java.util.HashSet;
import java.util.List;
import java.util.PriorityQueue;
import java.util.Set;

/**
 * The class is an example. It shows how to create a simple A* search planner able to
 * solve an ADL problem by choosing the heuristic to used and its weight.
 *
 * @author D. Pellier
 * @version 4.0 - 30.11.2021
 */
@CommandLine.Command(name = "IndustrialProcessPlanner",
    version = "IndustrialProcessPlanner 1.0",
    description = "Solves a specified planning problem using A* search strategy.",
    sortOptions = false,
    mixinStandardHelpOptions = true,
    headerHeading = "Usage:%n",
    synopsisHeading = "%n",
    descriptionHeading = "%nDescription:%n%n",
    parameterListHeading = "%nParameters:%n",
    optionListHeading = "%nOptions:%n")
    
    
public class IndustrialProcessPlanner extends AbstractPlanner {

    /**
     * The class logger.
     */
    private static final Logger LOGGER = LogManager.getLogger(IndustrialProcessPlanner.class.getName());
    private double heuristicWeight;
    private StateHeuristic.Name heuristic;

    /*
     * Campi aggiuntivi per:
     *  useNewHeuristic = per poter usare l'ueristica definita ad Hoc
     * choosePlanner = per poter selezionare tra A* e GreedyBestFirstSearch
     */
    private int useNewHeuristic;

    /**
     * Instantiates the planning problem from a parsed problem.
     *
     * @param problem the problem to instantiate.
     * @return the instantiated planning problem or null if the problem cannot be instantiated.
     */
    @Override
    public Problem instantiate(DefaultParsedProblem problem) {
        final Problem pb = new DefaultProblem(problem);
        pb.instantiate();
        return pb;
    }

    /**
     * Search a solution plan to a specified domain and problem using A*.
     *
     * @param problem the problem to solve.
     * @return the plan found or null if no plan was found.
     */
    @Override
    public Plan solve(final Problem problem) throws ProblemNotSupportedException {
        //Andiamo a vedere per prima cosa se il problema è risolvibile dal plan costruito
        if (!this.isSupported(problem)) { throw new ProblemNotSupportedException("Cannot solve the problem");}

        //ASTAR
        //mediante la seguente variabile di classe andiamo a scegliere l'euristica di riferimento
        if (this.getHeuristicNew() == 1){

            LOGGER.info("* Starting A* Search with IndustrialProcessHeuristic \n");

                //Per poter tenere traccia della memoria usata dall'algoritmo
                MemoryMXBean memoryBean = ManagementFactory.getMemoryMXBean();
                MemoryUsage beforeHeapMemoryUsage = memoryBean.getHeapMemoryUsage();
                long beforeUsedMemory = beforeHeapMemoryUsage.getUsed();

                //Per tenere traccia del tempo usato dall'algoritmo
                final long begin = System.currentTimeMillis();
                //Lanciamo l'algoritmo
                final Plan plan = this.astar(problem);
                final long end = System.currentTimeMillis();

                MemoryUsage afterHeapMemoryUsage = memoryBean.getHeapMemoryUsage();
                long afterUsedMemory = afterHeapMemoryUsage.getUsed();

                long memoryUsedByCustomAstar = afterUsedMemory - beforeUsedMemory;

                if (plan != null) {
                    LOGGER.info("* A* search succeeded\n");
                    this.getStatistics().setTimeToSearch(end - begin);
                    this.getStatistics().setMemoryUsedToSearch(memoryUsedByCustomAstar);
                } else {
                    LOGGER.info("* A* search failed\n");
                }
                return plan;
            }
            else{
                //In questo caso usiamo l'algoritmo A* con una delle euristiche fornite dal framework
                LOGGER.info("* Starting A* search with heuristic: "+ this.getHeuristic()+"\n");
                StateSpaceSearch search = StateSpaceSearch.getInstance(SearchStrategy.Name.ASTAR,
                        this.getHeuristic(), this.getHeuristicWeight(), this.getTimeout());
                LOGGER.info("* Starting A* search \n");
                // Cerchiamo una soluzione
                Plan plan = search.searchPlan(problem);

                if (plan != null) {
                    LOGGER.info("* A* search succeeded\n");
                    this.getStatistics().setTimeToSearch(search.getSearchingTime());
                    this.getStatistics().setMemoryUsedToSearch(search.getMemoryUsed());
                } else {
                    LOGGER.info("* A* search failed\n");
                }

                return plan;
            }
    }//solve
   

    /*
     * Metodo di verifica che il problema rispetti i requisiti
     * che ne consentono la risoluzione
     */
    @Override
    public boolean isSupported(Problem problem) {
        return !problem.getRequirements().contains(RequireKey.ACTION_COSTS)
                && !problem.getRequirements().contains(RequireKey.CONSTRAINTS)
                && !problem.getRequirements().contains(RequireKey.CONTINOUS_EFFECTS)
                && !problem.getRequirements().contains(RequireKey.DERIVED_PREDICATES)
                && !problem.getRequirements().contains(RequireKey.DURATIVE_ACTIONS)
                && !problem.getRequirements().contains(RequireKey.DURATION_INEQUALITIES)
                && !problem.getRequirements().contains(RequireKey.FLUENTS)
                && !problem.getRequirements().contains(RequireKey.GOAL_UTILITIES)
                && !problem.getRequirements().contains(RequireKey.METHOD_CONSTRAINTS)
                && !problem.getRequirements().contains(RequireKey.NUMERIC_FLUENTS)
                && !problem.getRequirements().contains(RequireKey.OBJECT_FLUENTS)
                && !problem.getRequirements().contains(RequireKey.PREFERENCES)
                && !problem.getRequirements().contains(RequireKey.TIMED_INITIAL_LITERALS)
                && !problem.getRequirements().contains(RequireKey.HIERARCHY);
    }//TODO:Si potrebbe utilizzare tranquillamente il metodo presente nella guida (nel caso cambiare)

    /**
     * Sets the weight of the heuristic.
     *
     * @param weight the weight of the heuristic. The weight must be greater than 0.
     * @throws IllegalArgumentException if the weight is strictly less than 0.
     */
    @CommandLine.Option(names = {"-w", "--weight"}, defaultValue = "1.0",
        paramLabel = "<weight>", description = "Set the weight of the heuristic (preset 1.0).")
    public void setHeuristicWeight(final double weight) {
        if (weight <= 0) {
            throw new IllegalArgumentException("Weight <= 0");
        }
        this.heuristicWeight = weight;
    }

    /**
     * Set the name of heuristic used by the planner to the solve a planning problem.
     *
     * @param heuristic the name of the heuristic.
     */
    @CommandLine.Option(names = {"-e", "--heuristic"}, defaultValue = "FAST_FORWARD",
        description = "Set the heuristic : AJUSTED_SUM, AJUSTED_SUM2, AJUSTED_SUM2M, COMBO, "
            + "MAX, FAST_FORWARD SET_LEVEL, SUM, SUM_MUTEX (preset: FAST_FORWARD)")
    public void setHeuristic(StateHeuristic.Name heuristic) {
        this.heuristic = heuristic;
    }

    //Metodo per settare la nuova euristica
    // 0 -> Utilizzo dell'euristica di base
    // 1 -> Utilizzo dell'euristica specifica
    @CommandLine.Option(names = {"-en", "--heuristicNew"}, defaultValue = "0",
            description = "Set the heuristic : 1")
    public void setHeuristicNew(int heuristicsNew) {
        this.useNewHeuristic = heuristicsNew;
    }

    public final int getHeuristicNew() {
        return this.useNewHeuristic;
    }

    /**
     * Returns the name of the heuristic used by the planner to solve a planning problem.
     *
     * @return the name of the heuristic used by the planner to solve a planning problem.
     */
    public final StateHeuristic.Name getHeuristic() {
        return this.heuristic;
    }

    /**
     * Returns the weight of the heuristic.
     *
     * @return the weight of the heuristic.
     */
    public final double getHeuristicWeight() {
        return this.heuristicWeight;
    }

    /**
     * Search a solution plan for a planning problem using an A* search strategy.
     *
     * @param problem the problem to solve.
     * @return a plan solution for the problem or null if there is no solution
     * @throws ProblemNotSupportedException if the problem to solve is not supported by the planner.
     */
    //Algoritmo A* modificato ad hoc
    public Plan astar(Problem problem){

        //Costruiamo la nostra euristica
        IndustrialProcessHeuristic heuristic = new IndustrialProcessHeuristic(problem);

        // Ci prendiamo lo stato iniziale
        final State init = new State(problem.getInitialState());

        // Inizializziamo l'insieme dei nodi visitati
        final Set<Node> close = new HashSet<>();

        final double weight = this.getHeuristicWeight();
        final PriorityQueue<Node> open = new PriorityQueue<>(100, new Comparator<Node>() {
            public int compare(Node n1, Node n2) {
                double f1 = weight * n1.getHeuristic() + n1.getCost();
                double f2 = weight * n2.getHeuristic() + n2.getCost();
                return Double.compare(f1, f2);
            }
        });

        // Definiamo la radice dell'albero di ricerca
        final Node root = new Node(init, null, -1, 0, heuristic.estimate(init, problem.getGoal()));

        open.add(root);
        Plan plan = null;

        // Settiamo il timeout per la ricerca
        final int timeout = this.getTimeout() * 1000;
        long time = 0;

        // Inizio ricerca
        while (!open.isEmpty() && plan == null && time < timeout) {

            // Aggiungiamo il nodo a quelli visitati
            final Node current = open.poll();
            close.add(current);

            //Se il goal è soddisfatto allora restituiamo il plan
            if (current.satisfy(problem.getGoal())) {
                return this.extractPlan(current, problem);
            } else {
                //Altrimenti proviamo ad applicare le azioni al nodo
                for (int i = 0; i < problem.getActions().size(); i++) {
                    // Ci prendiamo le azioni
                    Action a = problem.getActions().get(i);
                    // Verifichiamo se l'azione è applicabile al problema
                    if (a.isApplicable(current)) {
                        Node next = new Node(current);
                        // Applichiamo l'effetto dell'azione
                        final List<ConditionalEffect> effects = a.getConditionalEffects();
                        for (ConditionalEffect ce : effects) {
                            if (current.satisfy(ce.getCondition())) {
                                next.apply(ce.getEffect());
                            }
                        }
                        //Andiamo ad inserire le informazioni al nuovo nodo
                        final double g = current.getCost() + 1;
                        if (!close.contains(next)) {
                            next.setCost(g);
                            next.setParent(current);
                            next.setAction(i);
                            next.setHeuristic(heuristic.customEstimate(next, problem.getGoal(), a, current.getHeuristic()));
                            open.add(next);
                        }
                    }
                }
            }
        }
        //Restituiamo il plan -> Null se vuoto
        return plan;
    }//customA*

    /**
     * Extracts a search from a specified node.
     *
     * @param node    the node.
     * @param problem the problem.
     * @return the search extracted from the specified node.
     */
    private Plan extractPlan(final Node node, final Problem problem) {
        Node n = node;
        final Plan plan = new SequentialPlan();
        while (n.getAction() != -1) {
            final Action a = problem.getActions().get(n.getAction());
            plan.add(0, a);
            n = n.getParent();
        }
        return plan;
    }

    
    /**
     * The main method of the <code>IndustrialProcessPlanner</code> planner.
     *
     * @param args the arguments of the command line.
     */
    public static void main(String[] args) {
        try {
            final IndustrialProcessPlanner planner = new IndustrialProcessPlanner();
            CommandLine cmd = new CommandLine(planner);
            cmd.execute(args);
        } catch (IllegalArgumentException e) {
            LOGGER.fatal(e.getMessage());
        }
    }

}
