import request from '@/utils/request'

// 查询景点库列表
export function listSpot(query) {
  return request({
    url: '/system/spot/list',
    method: 'get',
    params: query
  })
}

// 查询景点库详细
export function getSpot(id) {
  return request({
    url: '/system/spot/' + id,
    method: 'get'
  })
}

// 新增景点库
export function addSpot(data) {
  return request({
    url: '/system/spot',
    method: 'post',
    data: data
  })
}

// 修改景点库
export function updateSpot(data) {
  return request({
    url: '/system/spot',
    method: 'put',
    data: data
  })
}

// 删除景点库
export function delSpot(id) {
  return request({
    url: '/system/spot/' + id,
    method: 'delete'
  })
}
