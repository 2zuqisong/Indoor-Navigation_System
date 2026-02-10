import { ApiService } from '../services/ApiService'
import { Point } from '../models/Point'
import { PathResponse, PathNode } from '../models/NavigationModel'
import { MapCanvas } from '../components/MapCanvas'

/**
 * 室内导航主页面
 *
 * 业务流程：
 *   1. 用户点击地图 → 选择起点（吸附到蓝色导航节点）
 *   2. 自动切换为"选择终点"模式 → 用户再次点击 → 选择终点
 *   3. 点击"开始导航" → 发送 startId / endId 给后端
 *   4. 后端 Dijkstra 计算最短路径 → 返回路径 + 总距离
 *   5. 前端在地图上绘制蓝色虚线最短路径
 */
@Entry
@Component
struct MapPage {

  // ===== 导航模式 =====
  // 'start' = 选起点, 'end' = 选终点, 'ready' = 可导航, 'navigating' = 已出路径
  @State mode: string = 'start'

  // ===== 起点 =====
  @State startNodeId: number = -1
  @State startNodeName: string = ''
  @State startPosX: number = -1
  @State startPosY: number = -1

  // ===== 终点 =====
  @State endNodeId: number = -1
  @State endNodeName: string = ''
  @State endPosX: number = -1
  @State endPosY: number = -1

  // ===== 导航结果 =====
  @State path: Point[] = []
  @State totalDistance: number = 0

  // ===== UI 状态 =====
  @State isLoading: boolean = false
  @State statusMessage: string = ''

  // =================================================================
  //  业务逻辑
  // =================================================================

  /** 处理地图点击 */
  handleMapClick(x: number, y: number, area: string, nodeId: number): void {
    // 正在导航中，点击无效
    if (this.mode === 'navigating' || this.isLoading) {
      return
    }
    // 必须点中蓝色导航节点附近
    if (nodeId < 0) {
      this.statusMessage = '请点击蓝色导航点来选择位置'
      return
    }
    this.statusMessage = ''

    if (this.mode === 'start') {
      // —— 选择起点 ——
      this.startNodeId = nodeId
      this.startNodeName = area
      this.startPosX = x
      this.startPosY = y
      this.mode = 'end' // 自动切换到选终点
    } else if (this.mode === 'end' || this.mode === 'ready') {
      // —— 选择终点 ——
      if (nodeId === this.startNodeId) {
        this.statusMessage = '终点不能与起点相同'
        return
      }
      this.endNodeId = nodeId
      this.endNodeName = area
      this.endPosX = x
      this.endPosY = y
      this.path = [] // 清除旧路径
      this.mode = 'ready'
    }
  }

  /** 调用后端获取最短路径 */
  async startNavigation(): Promise<void> {
    this.isLoading = true
    this.statusMessage = ''

    try {
      let result: PathResponse | null =
        await ApiService.planRoute(this.startNodeId, this.endNodeId)

      if (result === null) {
        this.statusMessage = '网络请求失败，请检查后端是否启动'
        this.isLoading = false
        return
      }
      if (!result.success) {
        this.statusMessage = result.message
        this.isLoading = false
        return
      }

      // 后端返回的 PathNode[] → 转为 Point[] 供 Canvas 绘制
      let points: Point[] = []
      for (let i = 0; i < result.path.length; i++) {
        let node: PathNode = result.path[i]
        let pt: Point = { x: node.x, y: node.y }
        points.push(pt)
      }
      this.path = points
      this.totalDistance = result.totalDistance
      this.mode = 'navigating'
    } catch (err) {
      this.statusMessage = '路径规划异常'
      console.error('startNavigation error:', err)
    }
    this.isLoading = false
  }

  /** 重置全部状态 */
  resetNavigation(): void {
    this.mode = 'start'
    this.startNodeId = -1
    this.startNodeName = ''
    this.startPosX = -1
    this.startPosY = -1
    this.endNodeId = -1
    this.endNodeName = ''
    this.endPosX = -1
    this.endPosY = -1
    this.path = []
    this.totalDistance = 0
    this.statusMessage = ''
    this.isLoading = false
  }

  // =================================================================
  //  页面布局
  // =================================================================

  build() {
    Column() {

      // =============== 标题栏 ===============
      Row() {
        Text('室内导航')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#263238')
        Blank()
        Text('1F')
          .fontSize(13)
          .fontColor('#546E7A')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .borderRadius(4)
          .backgroundColor('#ECEFF1')
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 8 })

      // =============== 地图画布 ===============
      MapCanvas({
        path: this.path,
        startPosX: this.startPosX,
        startPosY: this.startPosY,
        endPosX: this.endPosX,
        endPosY: this.endPosY,
        onMapClick: (x: number, y: number, area: string, nodeId: number) => {
          this.handleMapClick(x, y, area, nodeId)
        }
      })

      // =============== 导航信息面板 ===============
      Column() {

        // 错误 / 提示信息
        if (this.statusMessage.length > 0) {
          Text(this.statusMessage)
            .fontSize(13)
            .fontColor('#E65100')
            .width('100%')
            .margin({ bottom: 8 })
        }

        if (this.mode === 'start') {
          // —— 等待选择起点 ——
          Row() {
            Text('👆')
              .fontSize(18)
              .margin({ right: 8 })
            Text('请点击地图上的蓝色节点选择起点')
              .fontSize(14)
              .fontColor('#78909C')
          }
          .width('100%')
        }

        if (this.mode !== 'start') {
          // —— 起点已选 ——
          Row() {
            Text('●')
              .fontSize(16)
              .fontColor('#4CAF50')
              .margin({ right: 8 })
            Text('起点：' + this.startNodeName)
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor('#2E7D32')
          }
          .width('100%')
          .margin({ bottom: 6 })
        }

        if (this.mode === 'end') {
          // —— 等待选择终点 ——
          Row() {
            Text('👆')
              .fontSize(18)
              .margin({ right: 8 })
            Text('请点击地图选择目的地')
              .fontSize(14)
              .fontColor('#78909C')
          }
          .width('100%')
        }

        if (this.mode === 'ready' || this.mode === 'navigating') {
          // —— 终点已选 ——
          Row() {
            Text('●')
              .fontSize(16)
              .fontColor('#F44336')
              .margin({ right: 8 })
            Text('终点：' + this.endNodeName)
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor('#C62828')
          }
          .width('100%')
          .margin({ bottom: 6 })
        }

        if (this.mode === 'navigating') {
          // —— 路径结果 ——
          Row() {
            Text('📏')
              .fontSize(14)
              .margin({ right: 8 })
            Text('最短距离：' + this.totalDistance.toFixed(1))
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1565C0')
          }
          .width('100%')
        }
      }
      .width('100%')
      .padding(16)
      .margin({ left: 12, right: 12, top: 10 })
      .backgroundColor('#FFFFFF')
      .borderRadius(12)

      // =============== 操作按钮区 ===============

      if (this.isLoading) {
        Row() {
          LoadingProgress()
            .width(28)
            .height(28)
            .color('#1976D2')
          Text('正在规划路线...')
            .fontSize(14)
            .fontColor('#78909C')
            .margin({ left: 10 })
        }
        .margin({ top: 20 })
        .justifyContent(FlexAlign.Center)
      }

      if (this.mode === 'ready' && !this.isLoading) {
        Row() {
          Button('开始导航')
            .width('48%')
            .height(44)
            .backgroundColor('#1976D2')
            .fontColor('#FFFFFF')
            .fontSize(16)
            .borderRadius(22)
            .onClick(() => {
              this.startNavigation()
            })
          Button('重新选择')
            .width('38%')
            .height(44)
            .backgroundColor('#ECEFF1')
            .fontColor('#546E7A')
            .fontSize(15)
            .borderRadius(22)
            .onClick(() => {
              this.resetNavigation()
            })
        }
        .width('90%')
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ top: 16 })
      }

      if (this.mode === 'navigating' && !this.isLoading) {
        Button('重新规划')
          .width('60%')
          .height(44)
          .backgroundColor('#FF7043')
          .fontColor('#FFFFFF')
          .fontSize(16)
          .borderRadius(22)
          .margin({ top: 16 })
          .onClick(() => {
            this.resetNavigation()
          })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
