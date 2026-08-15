import request from '@/utils/request'

// 生成分享口令
export function createShare(tripId) {
  return request({
    url: '/system/share/' + tripId,
    method: 'post'
  })
}

// 根据口令获取只读行程（匿名访问）
export function getShareInfo(code) {
  return request({
    url: '/system/share/info/' + code,
    method: 'get',
    headers: { isToken: false }
  })
}
