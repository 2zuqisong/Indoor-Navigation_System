import { Http } from '../utils/Http'
import { Point } from '../models/Point'

export class ApiService {

    static async getPath(startId: number, endId: number): Promise<Point[]> {
        try {
            const responseString = await Http.get(
                `http://192.168.0.101:8080/api/path?start=${startId}&end=${endId}`
            )

            if (responseString.length === 0) {
                console.error("Empty response from server")
                return []
            }

            console.info("ApiService raw response: " + responseString)

            return JSON.parse(responseString) as Point[]

        } catch (err) {
            console.error("getPath error:", err)
            return []
        }
    }
}
