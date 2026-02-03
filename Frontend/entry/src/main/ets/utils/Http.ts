import http from '@ohos.net.http'

export class Http {
    static async get(url: string): Promise<string> {
        let httpRequest = http.createHttp()

        try {
            let response = await httpRequest.request(url, {
                method: http.RequestMethod.GET,
                header: { 'Content-Type': 'application/json' }
            })

            let result = response.result as string
            return result

        } catch (err) {
            console.error("Http GET error:", err)
            return ""   // 返回空字符串防止崩溃

        } finally {
            httpRequest.destroy()
        }
    }
}
