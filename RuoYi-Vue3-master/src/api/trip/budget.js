import request from '@/utils/request'

// 查询预算项列表
export function listBudget(query) {
  return request({
    url: '/system/budget/list',
    method: 'get',
    params: query
  })
}

// 查询预算项详细
export function getBudget(id) {
  return request({
    url: '/system/budget/' + id,
    method: 'get'
  })
}

// 新增预算项
export function addBudget(data) {
  return request({
    url: '/system/budget',
    method: 'post',
    data: data
  })
}

// 修改预算项
export function updateBudget(data) {
  return request({
    url: '/system/budget',
    method: 'put',
    data: data
  })
}

// 删除预算项
export function delBudget(id) {
  return request({
    url: '/system/budget/' + id,
    method: 'delete'
  })
}
