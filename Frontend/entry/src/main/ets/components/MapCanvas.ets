import { Point } from '../models/Point'

@Component
struct MapCanvas {
  @Prop path: Point[]

  build() {
    Canvas(this.draw.bind(this))
      .width('100%')
      .height(400)
      .backgroundColor('#f0f0f0')
  }

  draw(ctx: CanvasRenderingContext2D) {
    // 背景
    ctx.fillStyle = '#ffffff'
    ctx.fillRect(0, 0, 1000, 1000)

    // 画路径
    if (this.path.length > 0) {
      ctx.strokeStyle = 'blue'
      ctx.lineWidth = 4
      ctx.beginPath()
      ctx.moveTo(this.path[0].x, this.path[0].y)

      for (let p of this.path) {
        ctx.lineTo(p.x, p.y)
      }
      ctx.stroke()
    }
  }
}
