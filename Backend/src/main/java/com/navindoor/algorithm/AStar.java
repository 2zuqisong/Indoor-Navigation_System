package com.navindoor.algorithm;

import com.navindoor.model.Node;
import com.navindoor.model.Edge;

import java.util.*;

public class AStar {

    public static List<Node> search(Map<Long, Node> nodes, List<Edge> edges, long startId, long endId) {

        Node start = nodes.get(startId);
        Node end = nodes.get(endId);

        Map<Node, Double> gScore = new HashMap<>();
        Map<Node, Node> cameFrom = new HashMap<>();
        PriorityQueue<Node> openSet = new PriorityQueue<>(Comparator.comparingDouble(n -> fScore(n, end, gScore)));

        for (Node n : nodes.values()) gScore.put(n, Double.MAX_VALUE);
        gScore.put(start, 0.0);

        openSet.add(start);

        while (!openSet.isEmpty()) {
            Node current = openSet.poll();
            if (current.equals(end)) {
                return reconstructPath(cameFrom, current);
            }

            for (Edge e : edges) {
                if (!e.getFrom().equals(current)) continue;

                Node neighbor = e.getTo();
                double tentativeG = gScore.get(current) + e.getCost();

                if (tentativeG < gScore.get(neighbor)) {
                    cameFrom.put(neighbor, current);
                    gScore.put(neighbor, tentativeG);
                    if (!openSet.contains(neighbor)) openSet.add(neighbor);
                }
            }
        }
        return Collections.emptyList(); // 找不到路径
    }

    private static double fScore(Node n, Node end, Map<Node, Double> gScore) {
        return gScore.get(n) + heuristic(n, end);
    }

    private static double heuristic(Node a, Node b) {
        return Math.hypot(a.getX() - b.getX(), a.getY() - b.getY());
    }

    private static List<Node> reconstructPath(Map<Node, Node> cameFrom, Node current) {
        List<Node> path = new ArrayList<>();
        while (current != null) {
            path.add(current);
            current = cameFrom.get(current);
        }
        Collections.reverse(path);
        return path;
    }
}
