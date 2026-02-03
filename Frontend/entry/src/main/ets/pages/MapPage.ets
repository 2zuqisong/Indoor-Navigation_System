import { ApiService } from '../services/ApiService'
import { Point } from '../models/Point'
import { MapCanvas } from '../components/MapCanvas'

@Entry
@Component
struct MapPage {
  @State path: Point[] = []
  async loadPath() {
    let pathData = await ApiService.getPath(1, 5)
    if (pathData) {
      this.path = pathData
    }
  }

  build() {
    Column() {
      // 传递路径数据
      MapCanvas({ path: this.path })

      Button("获取路径")
        .margin(20)
        .onClick(() => {
          this.loadPath()
        })
    }
    .width('100%')
  }
}