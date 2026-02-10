import { Point } from '../models/Point'
import { NavNode, FloorMap, getDefaultMap } from '../models/MapData'

/**
 * 室内地图画布组件
 *
 * 功能：
 * - 绘制室内平面图（房间、走廊、墙壁、门、导航节点）
 * - 绘制起点标记（绿色）和终点标记（红色）
 * - 绘制导航路径（蓝色虚线）
 * - 点击地图时通过回调将位置信息传递给父组件
 */
@Component
export struct MapCanvas {

  // ===================================================================
  //  父组件传入的数据（Prop：单向同步）
  // ===================================================================

  /** 导航路径点集合 */
  @Prop @Watch('onDataChange') path: Point[] = []

  /** 起点坐标（-1 表示未选择） */
  @Prop @Watch('onDataChange') startPosX: number = -1
  @Prop @Watch('onDataChange') startPosY: number = -1

  /** 终点坐标（-1 表示未选择） */
  @Prop @Watch('onDataChange') endPosX: number = -1
  @Prop @Watch('onDataChange') endPosY: number = -1

  // ===================================================================
  //  回调：点击地图时通知父组件
  //  参数: x, y, areaName, nodeId（-1 表示未命中节点）
  // ===================================================================

  onMapClick: (x: number, y: number, area: string, nodeId: number) => void =
    (_x: number, _y: number, _area: string, _nodeId: number) => {}

  // ===================================================================
  //  Canvas 上下文 & 地图数据
  // ===================================================================

  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  private mapData: FloorMap = getDefaultMap()

  /** Prop 变化时触发重绘 */
  onDataChange() {
    this.draw()
  }

  // ===================================================================
  //  组件布局
  // ===================================================================

  build() {
    Column() {
      Canvas(this.context)
        .width('100%')
        .height(380)
        .onReady(() => {
          this.draw()
        })
        .onTouch((event: TouchEvent) => {
          if (event.type === TouchType.Down && event.touches.length > 0) {
            this.handleTouch(event.touches[0].x, event.touches[0].y)
          }
        })
    }
  }

  // ===================================================================
  //  Touch 处理
  // ===================================================================

  /** 处理触摸事件：查找最近节点 → 回调父组件 */
  handleTouch(x: number, y: number) {
    let nearest: NavNode | null = null
    let minDist = 999999
    let nodes = this.mapData.nodes

    for (let i = 0; i < nodes.length; i++) {
      let dx = nodes[i].x - x
      let dy = nodes[i].y - y
      let dist = Math.sqrt(dx * dx + dy * dy)
      if (dist < minDist) {
        minDist = dist
        nearest = nodes[i]
      }
    }

    if (nearest !== null && minDist < 35) {
      // 吸附到最近导航节点
      this.onMapClick(nearest.x, nearest.y, nearest.name, nearest.id)
    } else {
      // 未命中节点，返回原始坐标和区域名称
      let area = this.findArea(x, y)
      this.onMapClick(Math.round(x), Math.round(y), area, -1)
    }
  }

  /** 判断坐标所在的区域名称 */
  findArea(x: number, y: number): string {
    let map = this.mapData
    for (let i = 0; i < map.rooms.length; i++) {
      let r = map.rooms[i]
      if (x >= r.x && x <= r.x + r.width && y >= r.y && y <= r.y + r.height) {
        return r.label
      }
    }
    if (x >= map.buildingX && x <= map.buildingX + map.buildingWidth &&
      y >= map.corridorY && y <= map.corridorY + map.corridorHeight) {
      return '走廊'
    }
    return ''
  }

  // ===================================================================
  //  主绘制流程
  // ===================================================================

  draw() {
    let ctx = this.context
    let map = this.mapData

    // 1. 背景
    ctx.clearRect(0, 0, 500, 500)
    ctx.fillStyle = '#ECEFF1'
    ctx.fillRect(0, 0, 500, 500)

    // 2. 建筑底色（走廊颜色）
    ctx.fillStyle = map.corridorColor
    ctx.fillRect(map.buildingX, map.buildingY, map.buildingWidth, map.buildingHeight)

    // 3. 房间
    this.drawRooms(ctx)

    // 4. 墙壁（含门洞）
    this.drawWalls(ctx)

    // 5. 门弧线
    this.drawDoorArcs(ctx)

    // 6. 走廊标签
    ctx.fillStyle = '#8D6E63'
    ctx.font = '14vp sans-serif'
    ctx.textAlign = 'center'
    ctx.textBaseline = 'middle'
    ctx.fillText('走  廊',
      map.buildingX + map.buildingWidth / 2,
      map.corridorY + map.corridorHeight / 2)

    // 7. 入口标记
    this.drawEntrance(ctx, map)

    // 8. 楼层标签
    this.drawFloorLabel(ctx, map)

    // 9. 导航节点（蓝色圆点）
    this.drawNodes(ctx)

    // 10. 导航路径（蓝色虚线）
    if (this.path.length > 0) {
      this.drawPath(ctx)
    }

    // 11. 起点标记（绿色）
    if (this.startPosX >= 0 && this.startPosY >= 0) {
      this.drawMarker(ctx, this.startPosX, this.startPosY, '#4CAF50', '起')
    }

    // 12. 终点标记（红色）
    if (this.endPosX >= 0 && this.endPosY >= 0) {
      this.drawMarker(ctx, this.endPosX, this.endPosY, '#F44336', '终')
    }
  }

  // ===================================================================
  //  绘制——房间
  // ===================================================================

  drawRooms(ctx: CanvasRenderingContext2D) {
    let rooms = this.mapData.rooms
    for (let i = 0; i < rooms.length; i++) {
      let room = rooms[i]
      ctx.fillStyle = room.color
      ctx.fillRect(room.x, room.y, room.width, room.height)
      ctx.fillStyle = '#546E7A'
      ctx.font = '13vp sans-serif'
      ctx.textAlign = 'center'
      ctx.textBaseline = 'middle'
      ctx.fillText(room.label, room.x + room.width / 2, room.y + room.height / 2)
    }
  }

  // ===================================================================
  //  绘制——墙壁（含门洞缺口）
  // ===================================================================

  drawWalls(ctx: CanvasRenderingContext2D) {
    ctx.strokeStyle = '#37474F'
    ctx.lineWidth = 2.5

    // ======== 外墙 ========
    this.line(ctx, 15, 30, 345, 30)     // 上
    this.line(ctx, 15, 30, 15, 350)     // 左
    this.line(ctx, 345, 30, 345, 350)   // 右
    this.line(ctx, 15, 350, 55, 350)    // 下（入口门洞 55~85）
    this.line(ctx, 85, 350, 345, 350)

    // ======== 水平内墙 y=150（上排 ↔ 走廊），门洞 55~85, 165~195, 275~305 ========
    this.line(ctx, 15,  150, 55,  150)
    this.line(ctx, 85,  150, 165, 150)
    this.line(ctx, 195, 150, 275, 150)
    this.line(ctx, 305, 150, 345, 150)

    // ======== 水平内墙 y=220（走廊 ↔ 下排） ========
    this.line(ctx, 15,  220, 55,  220)
    this.line(ctx, 85,  220, 165, 220)
    this.line(ctx, 195, 220, 275, 220)
    this.line(ctx, 305, 220, 345, 220)

    // ======== 竖直内墙 ========
    this.line(ctx, 125, 30,  125, 150)
    this.line(ctx, 235, 30,  235, 150)
    this.line(ctx, 125, 220, 125, 350)
    this.line(ctx, 235, 220, 235, 350)
  }

  line(ctx: CanvasRenderingContext2D, x1: number, y1: number, x2: number, y2: number) {
    ctx.beginPath()
    ctx.moveTo(x1, y1)
    ctx.lineTo(x2, y2)
    ctx.stroke()
  }

  // ===================================================================
  //  绘制——门弧线
  // ===================================================================

  drawDoorArcs(ctx: CanvasRenderingContext2D) {
    ctx.strokeStyle = '#90A4AE'
    ctx.lineWidth = 1
    let r = 25

    let doorXs: number[] = [55, 165, 275]

    // 上排房间门（y=150，弧向上打开）
    for (let i = 0; i < doorXs.length; i++) {
      ctx.beginPath()
      ctx.arc(doorXs[i], 150, r, -Math.PI / 2, 0)
      ctx.stroke()
    }
    // 下排房间门（y=220，弧向下打开）
    for (let i = 0; i < doorXs.length; i++) {
      ctx.beginPath()
      ctx.arc(doorXs[i], 220, r, 0, Math.PI / 2)
      ctx.stroke()
    }
    // 入口大门
    ctx.beginPath()
    ctx.arc(55, 350, r, -Math.PI / 2, 0)
    ctx.stroke()
  }

  // ===================================================================
  //  绘制——入口 / 楼层标签
  // ===================================================================

  drawEntrance(ctx: CanvasRenderingContext2D, map: FloorMap) {
    ctx.fillStyle = '#FF5722'
    ctx.font = 'bold 11vp sans-serif'
    ctx.textAlign = 'center'
    ctx.textBaseline = 'top'
    ctx.fillText('▲ 入口', 70, map.buildingY + map.buildingHeight + 6)
  }

  drawFloorLabel(ctx: CanvasRenderingContext2D, map: FloorMap) {
    let x = map.buildingX + map.buildingWidth - 38
    let y = map.buildingY + 6
    ctx.fillStyle = '#FFFFFF'
    ctx.fillRect(x, y, 30, 18)
    ctx.strokeStyle = '#B0BEC5'
    ctx.lineWidth = 1
    ctx.strokeRect(x, y, 30, 18)
    ctx.fillStyle = '#37474F'
    ctx.font = 'bold 11vp sans-serif'
    ctx.textAlign = 'center'
    ctx.textBaseline = 'middle'
    ctx.fillText(map.floorName, x + 15, y + 9)
  }

  // ===================================================================
  //  绘制——导航节点（蓝色圆点）
  // ===================================================================

  drawNodes(ctx: CanvasRenderingContext2D) {
    let nodes = this.mapData.nodes
    for (let i = 0; i < nodes.length; i++) {
      let n = nodes[i]
      // 外圈光晕
      ctx.beginPath()
      ctx.arc(n.x, n.y, 8, 0, Math.PI * 2)
      ctx.fillStyle = 'rgba(25, 118, 210, 0.12)'
      ctx.fill()
      // 内圆点
      ctx.beginPath()
      ctx.arc(n.x, n.y, 3.5, 0, Math.PI * 2)
      ctx.fillStyle = '#1976D2'
      ctx.fill()
    }
  }

  // ===================================================================
  //  绘制——导航路径（蓝色虚线）
  // ===================================================================

  drawPath(ctx: CanvasRenderingContext2D) {
    ctx.beginPath()
    ctx.strokeStyle = '#1565C0'
    ctx.lineWidth = 3.5
    ctx.setLineDash([10, 5])

    ctx.moveTo(this.path[0].x, this.path[0].y)
    for (let i = 1; i < this.path.length; i++) {
      ctx.lineTo(this.path[i].x, this.path[i].y)
    }
    ctx.stroke()
    ctx.setLineDash([])
  }

  // ===================================================================
  //  绘制——位置标记（起点绿 / 终点红）
  // ===================================================================

  /**
   * 通用标记绘制：圆环 + 标签文字
   * @param color 主色调
   * @param label 标签文字（"起" / "终"）
   */
  drawMarker(ctx: CanvasRenderingContext2D,
    x: number, y: number, color: string, label: string) {

    // 外层光晕
    ctx.beginPath()
    ctx.arc(x, y, 18, 0, Math.PI * 2)
    ctx.fillStyle = color.replace(')', ', 0.12)').replace('rgb', 'rgba')
    // 简化处理：直接用半透明白底
    ctx.fillStyle = 'rgba(0, 0, 0, 0.06)'
    ctx.fill()

    // 圆环
    ctx.beginPath()
    ctx.arc(x, y, 12, 0, Math.PI * 2)
    ctx.strokeStyle = color
    ctx.lineWidth = 2.5
    ctx.stroke()

    // 内圆实心
    ctx.beginPath()
    ctx.arc(x, y, 6, 0, Math.PI * 2)
    ctx.fillStyle = color
    ctx.fill()

    // 白色中心
    ctx.beginPath()
    ctx.arc(x, y, 2.5, 0, Math.PI * 2)
    ctx.fillStyle = '#FFFFFF'
    ctx.fill()

    // 标签文字
    ctx.fillStyle = color
    ctx.font = 'bold 12vp sans-serif'
    ctx.textAlign = 'center'
    ctx.textBaseline = 'bottom'
    ctx.fillText(label, x, y - 20)
  }
}
