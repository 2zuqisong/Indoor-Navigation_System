/**
 * 导航业务数据模型
 * 定义前后端交互的请求/响应结构
 */

/** 路径规划请求体（发送给后端） */
export interface PathRequest {
  startId: number
  endId: number
}

/** 路径节点（后端返回的节点信息） */
export interface PathNode {
  id: number
  name: string
  x: number
  y: number
}

/** 路径规划响应体（后端返回） */
export interface PathResponse {
  success: boolean
  path: PathNode[]
  totalDistance: number
  message: string
}
