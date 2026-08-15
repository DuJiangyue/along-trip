import request from '@/utils/request'

// 查询行程日程列表
export function listDay(query) {
  return request({
    url: '/system/day/list',
    method: 'get',
    params: query
  })
}

// 查询行程日程详细
export function getDay(id) {
  return request({
    url: '/system/day/' + id,
    method: 'get'
  })
}

// 新增行程日程
export function addDay(data) {
  return request({
    url: '/system/day',
    method: 'post',
    data: data
  })
}

// 修改行程日程
export function updateDay(data) {
  return request({
    url: '/system/day',
    method: 'put',
    data: data
  })
}

// 删除行程日程
export function delDay(id) {
  return request({
    url: '/system/day/' + id,
    method: 'delete'
  })
}

// 查询行程日程树（按天分组，含当天日程项）
export function listDayTree(tripId) {
  return request({
    url: '/system/day/tree/' + tripId,
    method: 'get'
  })
}
