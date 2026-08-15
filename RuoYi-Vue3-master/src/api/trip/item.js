import request from '@/utils/request'

// 查询行程日程项列表
export function listItem(query) {
  return request({
    url: '/system/item/list',
    method: 'get',
    params: query
  })
}

// 查询行程日程项详细
export function getItem(id) {
  return request({
    url: '/system/item/' + id,
    method: 'get'
  })
}

// 新增行程日程项
export function addItem(data) {
  return request({
    url: '/system/item',
    method: 'post',
    data: data
  })
}

// 修改行程日程项
export function updateItem(data) {
  return request({
    url: '/system/item',
    method: 'put',
    data: data
  })
}

// 删除行程日程项
export function delItem(id) {
  return request({
    url: '/system/item/' + id,
    method: 'delete'
  })
}

// 日程项拖拽排序
export function updateItemSort(data) {
  return request({
    url: '/system/item/sort',
    method: 'put',
    data: data
  })
}
