/**
 * 室内地图数据模型
 * 定义导航节点、房间、楼层地图等数据结构
 *
 * 楼层平面图布局 (坐标系: 360 x 380)
 * ┌──────────┬──────────┬──────────┐
 * │ 办公室A  │  会议室   │ 办公室B  │  y: 30 ~ 150
 * │  (蓝)    │  (绿)    │  (蓝)    │
 * ├──  ──────┼──  ──────┼──  ──────┤
 * │            走  廊              │  y: 150 ~ 220
 * ├──  ──────┼──  ──────┼──  ──────┤
 * │  大  厅  │  实验室   │  卫生间  │  y: 220 ~ 350
 * │  (黄)    │  (紫)    │  (粉)    │
 * └──  ──────┴──────────┴──────────┘
 *      ▲ 入口
 */

/** 导航节点（兴趣点 / POI） */
export interface NavNode {
  id: number
  name: string
  x: number
  y: number
}

/** 房间定义 */
export interface Room {
  label: string
  x: number
  y: number
  width: number
  height: number
  color: string
}

/** 楼层地图完整数据 */
export interface FloorMap {
  floorName: string
  mapWidth: number
  mapHeight: number
  buildingX: number
  buildingY: number
  buildingWidth: number
  buildingHeight: number
  corridorY: number
  corridorHeight: number
  corridorColor: string
  rooms: Room[]
  nodes: NavNode[]
}

/** 获取默认地图 —— 一层办公楼 */
export function getDefaultMap(): FloorMap {
  return {
    floorName: 'F1',
    mapWidth: 360,
    mapHeight: 380,
    buildingX: 15,
    buildingY: 30,
    buildingWidth: 330,
    buildingHeight: 320,
    corridorY: 150,
    corridorHeight: 70,
    corridorColor: '#FFF3E0',
    rooms: [
      // ---- 上排房间 (y: 30 ~ 150, height: 120) ----
      { label: '办公室A', x: 15,  y: 30, width: 110, height: 120, color: '#E3F2FD' },
      { label: '会议室',  x: 125, y: 30, width: 110, height: 120, color: '#E8F5E9' },
      { label: '办公室B', x: 235, y: 30, width: 110, height: 120, color: '#E3F2FD' },
      // ---- 下排房间 (y: 220 ~ 350, height: 130) ----
      { label: '大厅',   x: 15,  y: 220, width: 110, height: 130, color: '#FFF8E1' },
      { label: '实验室',  x: 125, y: 220, width: 110, height: 130, color: '#F3E5F5' },
      { label: '卫生间',  x: 235, y: 220, width: 110, height: 130, color: '#FCE4EC' },
    ],
    nodes: [
      // 上排房间中心
      { id: 1, name: '办公室A', x: 70,  y: 90  },
      { id: 2, name: '会议室',  x: 180, y: 90  },
      { id: 3, name: '办公室B', x: 290, y: 90  },
      // 走廊节点
      { id: 4, name: '走廊西',  x: 70,  y: 185 },
      { id: 5, name: '走廊中',  x: 180, y: 185 },
      { id: 6, name: '走廊东',  x: 290, y: 185 },
      // 下排房间中心
      { id: 7, name: '大厅',   x: 70,  y: 285 },
      { id: 8, name: '实验室',  x: 180, y: 285 },
      { id: 9, name: '卫生间',  x: 290, y: 285 },
    ]
  }
}
