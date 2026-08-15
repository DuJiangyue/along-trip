import request from '@/utils/request'

// 查询行程列表
export function listTrip(query) {
  return request({
    url: '/system/trip/list',
    method: 'get',
    params: query
  })
}

// 查询行程详细
export function getTrip(id) {
  return request({
    url: '/system/trip/' + id,
    method: 'get'
  })
}

// 新增行程
export function addTrip(data) {
  return request({
    url: '/system/trip',
    method: 'post',
    data: data
  })
}

// 修改行程
export function updateTrip(data) {
  return request({
    url: '/system/trip',
    method: 'put',
    data: data
  })
}

// 删除行程
export function delTrip(id) {
  return request({
    url: '/system/trip/' + id,
    method: 'delete'
  })
}
