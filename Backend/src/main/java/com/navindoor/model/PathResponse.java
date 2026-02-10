package com.navindoor.model;

import java.util.Collections;
import java.util.List;

/**
 * 路径规划响应 DTO
 * <p>
 * 封装后端路径计算结果，包含成功/失败标志、路径节点列表、总距离、提示信息。
 */
public class PathResponse {

    /** 是否成功 */
    private boolean success;

    /** 最短路径上的节点列表（从起点到终点） */
    private List<Node> path;

    /** 路径总距离 */
    private double totalDistance;

    /** 提示信息 */
    private String message;

    public PathResponse() {
    }

    // ===================================================================
    //  工厂方法
    // ===================================================================

    /** 构造成功响应 */
    public static PathResponse success(List<Node> path, double totalDistance) {
        PathResponse resp = new PathResponse();
        resp.success = true;
        resp.path = path;
        resp.totalDistance = Math.round(totalDistance * 100.0) / 100.0;
        resp.message = "路径规划成功";
        return resp;
    }

    /** 构造失败响应 */
    public static PathResponse error(String message) {
        PathResponse resp = new PathResponse();
        resp.success = false;
        resp.path = Collections.emptyList();
        resp.totalDistance = 0;
        resp.message = message;
        return resp;
    }

    // ===================================================================
    //  Getter（Jackson 序列化需要）
    // ===================================================================

    public boolean isSuccess() {
        return success;
    }

    public List<Node> getPath() {
        return path;
    }

    public double getTotalDistance() {
        return totalDistance;
    }

    public String getMessage() {
        return message;
    }
}
