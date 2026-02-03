package com.navindoor.service;

import com.navindoor.model.Node;
import com.navindoor.model.Edge;
import com.navindoor.algorithm.AStar;
import org.springframework.stereotype.Service;
import java.util.*;

@Service
public class PathService {

    private Map<Long, Node> nodes = new HashMap<>();
    private List<Edge> edges = new ArrayList<>();

    public PathService() {
        // 初始化节点
        nodes.put(1L, new Node(1, "A", 50, 50));
        nodes.put(2L, new Node(2, "B", 150, 80));
        nodes.put(3L, new Node(3, "C", 300, 200));
        nodes.put(4L, new Node(4, "D", 500, 300));
        nodes.put(5L, new package com.navindoor.controller;

import com.navindoor.model.Node;
import com.navindoor.service.PathService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api")
public class PathController {

    @Autowired
    PathService pathService;

    @GetMapping("/path")
    public List<Node> getPath(
            @RequestParam long start,
            @RequestParam long end) {

        return pathService.calculatePath(start, end);
    }
}
Node(5, "E", 600, 400));

        // 初始化边
        edges.add(new Edge(nodes.get(1L), nodes.get(2L), 100));
        edges.add(new Edge(nodes.get(2L), nodes.get(3L), 200));
        edges.add(new Edge(nodes.get(3L), nodes.get(4L), 250));
        edges.add(new Edge(nodes.get(4L), nodes.get(5L), 150));
        edges.add(new Edge(nodes.get(2L), nodes.get(4L), 300));
    }

    public List<Node> calculatePath(long startId, long endId) {
        return AStar.search(nodes, edges, startId, endId);
    }
}
