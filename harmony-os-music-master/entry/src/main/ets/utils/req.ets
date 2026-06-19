import axios, {
  AxiosError,
  AxiosResponse,
  InternalAxiosRequestConfig,
  Method,
  RawAxiosRequestHeaders
} from '@ohos/axios'

const instance = axios.create({
  baseURL: '',
  timeout: 5000
})

// 请求拦截器
instance.interceptors.request.use((config: InternalAxiosRequestConfig) => {
  return config
}, (err: AxiosError) => {
  Promise.reject(err)
})

// 响应拦截器
instance.interceptors.response.use((res: AxiosResponse) => {
  return res.data
}, (err: AxiosError) => {
  return Promise.reject(err)
})

// get方法
export const get = <T, D = null>(url: string, data?: D, headers?: RawAxiosRequestHeaders): Promise<T> => {
  return instance.get(encodeURI(url), { params: data, headers })
}

// post方法
export const post = <T, D = null>(url: string, data?: D, headers?: RawAxiosRequestHeaders): Promise<T> => {
  return instance.post(url, data, { headers })
}

export const request =
  <T, D = null>(url: string, method: Method = 'get', data?: D, headers?: RawAxiosRequestHeaders): Promise<T> => {
    return instance({
      url: encodeURI(url),
      method,
      data,
      headers
    })
  }