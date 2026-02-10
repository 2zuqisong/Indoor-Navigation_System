package com.navindoor.algorithm;

import com.navindoor.model.Node;
import com.navindoor.model.Edge;

import java.util.*;

/**
 * Dijkstra 最短路径算法
 * <p>
 * 基于优先队列（最小堆）的经典实现，适用于非负权重有向图。
 * 时间复杂度 O((V + E) log V)，其中 V 为节点数，E 为边数。
 */
public class Dijkstra {

    /**
     * 计算从起点到终点的最短路径
     *
     * @param nodes   节点集合 (id → Node)
     * @param edges   边集合（需为双向边或已包含反向边）
     * @param startId 起点节点 ID
     * @param endId   终点节点 ID
     * @return 包含路径和总距离的计算结果
     */
    public static DijkstraResult findShortestPath(
            Map<Long, Node> nodes, List<Edge> edges, long startId, long endId) {

        // 1. 构建邻接表
        Map<Long, List<Edge>> adjacency = buildAdjacencyList(edges);

        // 2. 初始化
        Map<Long, Double> distance = new HashMap<>();      // 起点到各节点的最短距离
        Map<Long, Long> predecessor = new HashMap<>();      // 最短路径前驱节点
        Set<Long> visited = new HashSet<>();                // 已确定最短路径的节点

        for (Long nodeId : nodes.keySet()) {
            distance.put(nodeId, Double.MAX_VALUE);
        }
        distance.put(startId, 0.0);

        // 优先队列：按距离升序排列
        PriorityQueue<NodeDistance> queue = new PriorityQueue<>(
                Comparator.comparingDouble(nd -> nd.distance)
        );
        queue.add(new NodeDistance(startId, 0.0));

        // 3. Dijkstra 主循环
        while (!queue.isEmpty()) {
            NodeDistance current = queue.poll();
            long currentId = current.nodeId;

            // 跳过已处理的节点（惰性删除策略）
            if (visited.contains(currentId)) {
                continue;
            }
            visited.add(currentId);

            // 到达终点，提前退出
            if (currentId == endId) {
                break;
            }

            // 松弛相邻边
            List<Edge> neighbors = adjacency.getOrDefault(currentId, Collections.emptyList());
            for (Edge edge : neighbors) {
                long neighborId = edge.getTo().getId();
                if (visited.contains(neighborId)) {
                    continue;
                }

                double newDist = distance.get(currentId) + edge.getCost();
                if (newDist < distance.get(neighborId)) {
                    distance.put(neighborId, newDist);
                    predecessor.put(neighborId, currentId);
                    queue.add(new NodeDistance(neighborId, newDist));
                }
            }
        }

        // 4. 回溯重建路径
        List<Node> path = reconstructPath(nodes, predecessor, startId, endId);
        double totalDistance = distance.getOrDefault(endId, Double.MAX_VALUE);

        // 路径不可达时 totalDistance 保持 MAX_VALUE，path 为空
        if (path.isEmpty()) {
            totalDistance = 0;
        }

        return new DijkstraResult(path, totalDistance);
    }

    /** 从边列表构建邻接表 */
    private static Map<Long, List<Edge>> buildAdjacencyList(List<Edge> edges) {
        Map<Long, List<Edge>> adjacency = new HashMap<>();
        for (Edge edge : edges) {
            long fromId = edge.getFrom().getId();
            adjacency.computeIfAbsent(fromId, k -> new ArrayList<>()).add(edge);
        }
        return adjacency;
    }

    /** 根据前驱表从终点回溯到起点，重建完整路径 */
    private static List<Node> reconstructPath(
            Map<Long, Node> nodes, Map<Long, Long> predecessor,
            long startId, long endId) {

        // 终点不可达
        if (!predecessor.containsKey(endId) && startId != endId) {
            return Collections.emptyList();
        }

        List<Node> path = new ArrayList<>();
        Long currentId = endId;

        while (currentId != null && nodes.containsKey(currentId)) {
            path.add(nodes.get(currentId));
            if (currentId == startId) {
                break;
            }
            currentId = predecessor.get(currentId);
        }

        Collections.reverse(path);

        // 校验路径有效性：起点必须匹配
        if (path.isEmpty() || path.get(0).getId() != startId) {
            return Collections.emptyList();
        }

        return path;
    }

    // ===================================================================
    //  内部辅助类
    // ===================================================================

    /** 优先队列中的节点-距离对 */
    private static class NodeDistance {
        final long nodeId;
        final double distance;

        NodeDistance(long nodeId, double distance) {
            this.nodeId = nodeId;
            this.distance = distance;
        }
    }

    /**
     * Dijkstra 算法计算结果
     */
    public static class DijkstraResult {
        private final List<Node> path;
        private final double totalDistance;

        public DijkstraResult(List<Node> path, double totalDistance) {
            this.path = path;
            this.totalDistance = totalDistance;
        }

        /** 最短路径节点序列（从起点到终点） */
        public List<Node> getPath() {
            return path;
        }

        /** 最短路径总距离 */
        public double getTotalDistance() {
            return totalDistance;
        }

        /** 是否找到可达路径 */
        public boolean isFound() {
            return !path.isEmpty();
        }
    }
}
