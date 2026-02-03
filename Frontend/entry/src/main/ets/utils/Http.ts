
import http from '@ohos.net.http'

export class Http {
    static async get(url: string): Promise<string> { // 返回原始字符串
        let httpRequest = http.createHttp()
        let response = await httpRequest.request(url, {
            method: http.RequestMethod.GET,
            header: { 'Content-Type': 'application/json' }
        })
        let result = response.result as string
        httpRequest.destroy()
        return result
    }
}