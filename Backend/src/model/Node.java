package com.navindoor.model;

public class Node {
    private long id;
    private String name;
    private double x;
    private double y;

    public Node(long id, String name, double x, double y) {
        this.id = id;
        this.name = name;
        this.x = x;
        this.y = y;
    }

    // getter
    public long getId() { return id; }
    public String getName() { return name; }
    public double getX() { return x; }
    public double getY() { return y; }
}
