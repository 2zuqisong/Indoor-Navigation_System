import { Point } from '../models/Point'

@Component
export struct MapCanvas {
  // 使用 @Watch 监听 path 的变化，一旦数据更新就执行 onPathUpdate
  @Prop @Watch('onPathUpdate') path: Point[] = []

  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)

  // 当 path 发生变化时被调用
  onPathUpdate() {
    this.draw()
  }

  build() {
    Column() {
      Canvas(this.context)
        .width('100%')
        .height(400)
        .backgroundColor('#f0f0f0')
        .onReady(() => {
          this.draw()
        })
    }
  }

  draw() {
    let ctx = this.context
    // 调试日志：如果控制台没打印这一行，说明 draw 没被触发
    console.info("Canvas draw method called. Path length: " + this.path.length)

    ctx.clearRect(0, 0, 1000, 1000)
    ctx.fillStyle = '#ffffff'
    ctx.fillRect(0, 0, 1000, 1000)

    if (this.path && this.path.length > 0) {
      ctx.beginPath()
      ctx.strokeStyle = '#007DFF'
      ctx.lineWidth = 5

      // 后端 x,y 是 50.0, 150.0 等，确保它们在画布范围内
      ctx.moveTo(this.path[0].x, this.path[0].y)
      for (let i = 1; i < this.path.length; i++) {
        ctx.lineTo(this.path[i].x, this.path[i].y)
        console.info(`Line to: ${this.path[i].x}, ${this.path[i].y}`)
      }
      ctx.stroke()
    }
  }
}