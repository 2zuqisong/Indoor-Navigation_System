package com.navindoor.service;

import com.navindoor.algorithm.Dijkstra;
import com.navindoor.model.Edge;
import com.navindoor.model.Node;
import com.navindoor.model.PathResponse;
import org.springframework.stereotype.Service;

import java.util.*;

/**
 * 路径规划服务
 * <p>
 * 管理室内导航图（节点 + 边），并通过 Dijkstra 算法计算最短路径。
 * 当前数据为内存硬编码，后续可替换为数据库/配置文件。
 */
@Service
public class PathService {

    private final Map<Long, Node> nodes = new HashMap<>();
    private final List<Edge> edges = new ArrayList<>();

    public PathService() {
        initializeGraph();
    }

    // ===================================================================
    //  图数据初始化（与前端 MapData 坐标一致）
    // ===================================================================

    private void initializeGraph() {
        // ---- 上排房间 ----
        nodes.put(1L, new Node(1, "办公室A", 70, 90));
        nodes.put(2L, new Node(2, "会议室",  180, 90));
        nodes.put(3L, new Node(3, "办公室B", 290, 90));
        // ---- 走廊节点 ----
        nodes.put(4L, new Node(4, "走廊西", 70,  185));
        nodes.put(5L, new Node(5, "走廊中", 180, 185));
        nodes.put(6L, new Node(6, "走廊东", 290, 185));
        // ---- 下排房间 ----
        nodes.put(7L, new Node(7, "大厅",   70,  285));
        nodes.put(8L, new Node(8, "实验室",  180, 285));
        nodes.put(9L, new Node(9, "卫生间",  290, 285));

        // ---- 双向边 ----
        // 上排房间 ↔ 走廊
        addBidirectionalEdge(1L, 4L, 95);
        addBidirectionalEdge(2L, 5L, 95);
        addBidirectionalEdge(3L, 6L, 95);
        // 走廊水平连接
        addBidirectionalEdge(4L, 5L, 110);
        addBidirectionalEdge(5L, 6L, 110);
        // 走廊 ↔ 下排房间
        addBidirectionalEdge(4L, 7L, 100);
        addBidirectionalEdge(5L, 8L, 100);
        addBidirectionalEdge(6L, 9L, 100);
    }

    private void addBidirectionalEdge(long fromId, long toId, double cost) {
        edges.add(new Edge(nodes.get(fromId), nodes.get(toId), cost));
        edges.add(new Edge(nodes.get(toId), nodes.get(fromId), cost));
    }

    // ===================================================================
    //  业务方法
    // ===================================================================

    /**
     * 规划最短路径（主业务方法）
     *
     * @param startId 起点节点 ID
     * @param endId   终点节点 ID
     * @return 封装好的 PathResponse，含成功/失败信息、路径和距离
     */
    public PathResponse planRoute(long startId, long endId) {
        // ---- 参数校验 ----
        if (!nodes.containsKey(startId)) {
            return PathResponse.error("起点节点不存在，ID: " + startId);
        }
        if (!nodes.containsKey(endId)) {
            return PathResponse.error("终点节点不存在，ID: " + endId);
        }
        if (startId == endId) {
            return PathResponse.error("起点和终点不能相同");
        }

        // ---- 调用 Dijkstra 算法 ----
        Dijkstra.DijkstraResult result =
                Dijkstra.findShortestPath(nodes, edges, startId, endId);

        if (!result.isFound()) {
            return PathResponse.error("未找到从 "
                    + nodes.get(startId).getName() + " 到 "
                    + nodes.get(endId).getName() + " 的路径");
        }

        return PathResponse.success(result.getPath(), result.getTotalDistance());
    }

    /**
     * 获取所有导航节点
     */
    public List<Node> getAllNodes() {
        return new ArrayList<>(nodes.values());
    }
}
