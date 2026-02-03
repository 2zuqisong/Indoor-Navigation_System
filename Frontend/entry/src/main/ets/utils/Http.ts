export class Http {
    static async get(url: string): Promise<any> {
        const res = await fetch(url)
        return await res.json()
    }
}