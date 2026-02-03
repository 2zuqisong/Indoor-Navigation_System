import { ApiService } from '../services/ApiService'
import { Point } from '../models/Point'

@Entry
@Component
struct MapPage {

  @State path: Point[] = []

  async loadPath() {
    let res = await ApiService.getPath(1, 5)
    this.path = res
  }

  build() {
    Column() {

      MapCanvas({ path: this.path })

      Button("获取路径")
        .onClick(() => {
          this.loadPath()
        })

    }
  }
}
