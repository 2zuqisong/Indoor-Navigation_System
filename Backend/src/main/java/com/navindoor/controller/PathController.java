package com.navindoor.controller;

import com.navindoor.model.Node;
import com.navindoor.model.PathRequest;
import com.navindoor.model.PathResponse;
import com.navindoor.service.PathService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 室内导航 REST 接口
 */
@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/api/navigation")
public class PathController {

    @Autowired
    private PathService pathService;

    /**
     * 路径规划 —— POST 方式（前端 App 调用）
     *
     * POST /api/navigation/route
     * Body: { "startId": 1, "endId": 9 }
     */
    @PostMapping("/route")
    public PathResponse planRoute(@RequestBody PathRequest request) {
        return pathService.planRoute(request.getStartId(), request.getEndId());
    }

    /**
     * 路径规划 —— GET 方式（浏览器测试用）
     *
     * GET /api/navigation/route?startId=1&endId=9
     */
    @GetMapping("/route")
    public PathResponse planRouteGet(@RequestParam long startId, @RequestParam long endId) {
        return pathService.planRoute(startId, endId);
    }

    /**
     * 获取所有导航节点
     *
     * GET /api/navigation/nodes
     */
    @GetMapping("/nodes")
    public List<Node> getAllNodes() {
        return pathService.getAllNodes();
    }
}
