import http from '@ohos.net.http'

/**
 * HTTP 请求工具类
 * 封装 HarmonyOS @ohos.net.http 模块。
 */
export class Http {

    /**
     * 发送 GET 请求
     * @param url 请求地址
     * @returns 响应体字符串，失败返回空字符串
     */
    static async get(url: string): Promise<string> {
        let httpRequest = http.createHttp()
        try {
            let response = await httpRequest.request(url, {
                method: http.RequestMethod.GET,
                header: {
                    'Content-Type': 'application/json'
                },
                connectTimeout: 10000,
                readTimeout: 10000
            })

            console.info('Http GET status: ' + response.responseCode)

            if (response.responseCode === 200) {
                return response.result as string
            } else {
                console.error('Http GET failed, status: ' + response.responseCode)
                return ''
            }
        } catch (err) {
            console.error('Http GET error: ' + JSON.stringify(err))
            return ''
        } finally {
            httpRequest.destroy()
        }
    }
}
