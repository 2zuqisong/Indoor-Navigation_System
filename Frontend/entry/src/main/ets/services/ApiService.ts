import { Http } from '../utils/Http'

export class ApiService {

    static getPath(startId: number, endId: number) {
        return Http.get(
            `http://localhost:8080/api/path?start=${startId}&end=${endId}`
        )
    }

}
