package com.navindoor.model;

public class Edge {
    private Node from;
    private Node to;
    private double cost;

    public Edge(Node from, Node to, double cost) {
        this.from = from;
        this.to = to;
        this.cost = cost;
    }

    // getter
    public Node getFrom() { return from; }
    public Node getTo() { return to; }
    public double getCost() { return cost; }
}
