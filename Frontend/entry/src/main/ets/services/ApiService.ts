import { Http } from '../utils/Http'
import { PathResponse } from '../models/NavigationModel'

/**
 * 后端 API 服务
 * 统一管理前端与后端的 HTTP 通信。
 */

/** 后端基础地址（开发环境，改为电脑的实际 IP） */
const BASE_URL: string = 'http://192.168.1.4:8080'

export class ApiService {

    /**
     * 请求最短路径规划（Dijkstra）
     *
     * 使用 GET 方式：/api/navigation/route?startId=x&endId=y
     * @param startId 起点节点 ID
     * @param endId   终点节点 ID
     * @returns PathResponse 或 null（网络异常时）
     */
    static async planRoute(startId: number, endId: number): Promise<PathResponse | null> {
        try {
            let url = `${BASE_URL}/api/navigation/route?startId=${startId}&endId=${endId}`
            console.info('ApiService planRoute request: ' + url)

            let responseString = await Http.get(url)

            if (responseString.length === 0) {
                console.error('ApiService planRoute: empty response')
                return null
            }

            console.info('ApiService planRoute response: ' + responseString)
            let result: PathResponse = JSON.parse(responseString) as PathResponse
            return result

        } catch (err) {
            console.error('ApiService planRoute error: ' + JSON.stringify(err))
            return null
        }
    }
}
