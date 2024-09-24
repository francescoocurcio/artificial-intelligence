import fr.uga.pddl4j.heuristics.state.RelaxedGraphHeuristic;
import fr.uga.pddl4j.planners.statespace.search.Node;
import fr.uga.pddl4j.problem.Problem;
import fr.uga.pddl4j.problem.State;
import fr.uga.pddl4j.problem.operator.Action;
import fr.uga.pddl4j.problem.operator.Condition;

import java.lang.reflect.Method;

public final class IndustrialProcessHeuristic extends RelaxedGraphHeuristic {

    public IndustrialProcessHeuristic (Problem problem) {
        super(problem);
        super.setAdmissible(false);
    }

    @Override
    public int estimate(State state, Condition goal) {
        super.setGoal(goal);
        super.expandRelaxedPlanningGraph(state);
        return super.isGoalReachable() ? 1 : Integer.MAX_VALUE;
    }

    @Override
    public double estimate(Node node, Condition goal) {
        return this.estimate((State) node, goal);
    }

    public double customEstimate(State state, Condition goal, Action a, double currentHeuristic) {
        super.setGoal(goal);
        this.expandRelaxedPlanningGraph(state);

        double heuristicValue = currentHeuristic;
    
        if(a.getName().contains("move"))
            //si vogliono agevolare le mosse di spostamento
            heuristicValue -= 1;
        else if (a.getName().contains("fill") || a.getName().contains("workstation") || a.getName().contains("load") )
            //si favoriscono le operaizoni di caricamento e riempimento delle box così come quelle che coinvolgono le workstation
            heuristicValue -= 0.8;
        else if (a.getName().equals("empty_box_in_location"))
            //si vuole sfavorire l'operazione di svuotamento della box in una location in quanto le specifiche del problema prescrivono che sono le workstation ad avere bisogno dei materiali e non le location
            heuristicValue += 0.5;
        else if (a.getName().equals("empty_box_in_workstation"))
            //si vuole incentivare l'operazione di svuotamento della box nella workstation
            heuristicValue -= 1.5;
        else if (a.getName().equals("put_down_box_in_location"))
            //si vuole sfavorire l'operazione di rilascio di una box in una location
            heuristicValue += 0.5;
        return super.isGoalReachable() ? heuristicValue : Integer.MAX_VALUE;
    }
}
