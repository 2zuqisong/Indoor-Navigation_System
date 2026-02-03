
import { Http } from '../utils/Http'
import { Point } from '../models/Point'

export class ApiService {
    static async getPath(startId: number, endId: number): Promise<Point[]> {
        const responseString = await Http.get(
            `http://192.168.0.101:8080/api/path?start=${startId}&end=${endId}`
        )
        // 打印一下，确认字符串确实拿到了
        console.info("ApiService raw response: " + responseString)
        return JSON.parse(responseString) as Point[]
    }
}
