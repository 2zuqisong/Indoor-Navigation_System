package com.navindoor.model;

/**
 * 路径规划请求 DTO
 * <p>
 * 前端发送起点和终点节点 ID，后端据此计算最短路径。
 */
public class PathRequest {

    /** 起点节点 ID */
    private long startId;

    /** 终点节点 ID */
    private long endId;

    public PathRequest() {
    }

    public PathRequest(long startId, long endId) {
        this.startId = startId;
        this.endId = endId;
    }

    public long getStartId() {
        return startId;
    }

    public void setStartId(long startId) {
        this.startId = startId;
    }

    public long getEndId() {
        return endId;
    }

    public void setEndId(long endId) {
        this.endId = endId;
    }
}
