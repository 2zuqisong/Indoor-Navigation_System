
import router from '@ohos.router';

@Entry
@Component
struct Home {
    build() {
        Column() {
            Text("室内导航系统")
            .fontSize(24)
            .margin(20)

            Button("进入地图")
            .onClick(() => {
            router.pushUrl({ url: "pages/MapPage" })
            })
        }
    }
}
