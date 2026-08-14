<template>
  <div class="app-container day-page">
    <!-- 行程选择 + 信息 -->
    <div class="day-header">
      <el-select
        v-model="tripId"
        placeholder="选择行程"
        filterable
        style="flex: 1"
        @change="handleTripChange"
      >
        <el-option v-for="t in tripOptions" :key="t.id" :label="t.tripName" :value="t.id" />
      </el-select>
      <el-button v-if="trip" link type="primary" @click="handleCreateDay">+ 添加日程</el-button>
    </div>

    <template v-if="trip">
      <div class="day-trip-info">
        <div class="day-trip-dest">{{ trip.destination || '未设置目的地' }}</div>
        <div class="day-trip-date">{{ (trip.startDate || '').slice(0, 10) }} ~ {{ (trip.endDate || '').slice(0, 10) }}</div>
      </div>

      <!-- 按天 Tab 横滑 -->
      <div class="day-tabs">
        <div
          v-for="day in days"
          :key="day.id"
          class="day-tab"
          :class="{ active: activeDayId === day.id }"
          @click="activeDayId = day.id"
        >
          <span class="day-tab__no">D{{ day.dayNo }}</span>
          <span class="day-tab__date">{{ (day.tripDate || '').slice(5, 10) }}</span>
        </div>
      </div>

      <!-- 当天日程项时间轴 -->
      <div class="day-items">
        <div v-if="!activeDayItems.length" class="day-items__empty">
          这一天还没有安排，点击右上角「添加日程」吧
        </div>
        <draggable
          v-else
          v-model="activeDayItems"
          item-key="id"
          handle=".drag-handle"
          ghost-class="ghost"
          animation="200"
          @end="handleSortEnd"
        >
          <template #item="{ element }">
            <div class="day-item">
              <div class="day-item__time">
                <span>{{ element.startTime || '--:--' }}</span>
                <span class="day-item__time-end">{{ element.endTime || '' }}</span>
              </div>
              <div class="day-item__dot" :class="'type-' + element.itemType"></div>
              <div class="day-item__content">
                <div class="day-item__name">
                  {{ element.itemName }}
                  <el-tag size="small" :type="typeTag(element.itemType)" effect="light">{{ typeText(element.itemType) }}</el-tag>
                </div>
                <div v-if="element.note" class="day-item__note">{{ element.note }}</div>
              </div>
              <div class="day-item__actions">
                <span class="drag-handle"><el-icon><Rank /></el-icon></span>
                <el-button link type="primary" icon="Edit" @click="handleEditItem(element)"></el-button>
                <el-button link type="danger" icon="Delete" @click="handleDelItem(element)"></el-button>
              </div>
            </div>
          </template>
        </draggable>
      </div>
    </template>

    <el-empty v-else description="请选择行程" />

    <!-- 新增/编辑日程项弹窗 -->
    <el-dialog :title="itemDialogTitle" v-model="itemDialogOpen" width="480px" append-to-body>
      <el-form ref="itemRef" :model="itemForm" :rules="itemRules" label-width="70px">
        <el-form-item label="类型" prop="itemType">
          <el-radio-group v-model="itemForm.itemType">
            <el-radio-button v-for="t in itemTypeOptions" :key="t.value" :value="t.value">{{ t.label }}</el-radio-button>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="从景点选" v-if="itemForm.itemType === '1'">
          <el-select v-model="selectedSpotId" filterable clearable placeholder="搜索选择景点（可选）" style="width: 100%" @change="handleSpotSelect">
            <el-option v-for="s in spotOptions" :key="s.id" :label="s.spotName" :value="s.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="名称" prop="itemName">
          <el-input v-model="itemForm.itemName" placeholder="请输入名称（景点/车次/酒店等）" />
        </el-form-item>
        <el-form-item label="时间">
          <div style="display: flex; gap: 8px; width: 100%">
            <el-time-picker v-model="itemForm.startTime" format="HH:mm" value-format="HH:mm" placeholder="开始" style="flex: 1" />
            <el-time-picker v-model="itemForm.endTime" format="HH:mm" value-format="HH:mm" placeholder="结束" style="flex: 1" />
          </div>
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="itemForm.note" type="textarea" placeholder="备注（可选）" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="itemDialogOpen = false">取 消</el-button>
        <el-button type="primary" @click="submitItem">确 定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup name="TripDay">
import draggable from "vuedraggable";
import { listTrip } from "@/api/trip/trip";
import { listDayTree, addDay } from "@/api/trip/day";
import { addItem, updateItem, delItem, updateItemSort } from "@/api/trip/item";
import { listSpot } from "@/api/trip/spot";
import { ElMessage, ElMessageBox } from 'element-plus'

const { proxy } = getCurrentInstance()
const tripId = ref(undefined)
const tripOptions = ref([])
const trip = ref(undefined)
const days = ref([])
const activeDayId = ref(undefined)
const spotOptions = ref([])
const selectedSpotId = ref(undefined)

const itemDialogOpen = ref(false)
const itemDialogTitle = ref('')
const itemForm = ref({})
const itemRules = {
  itemName: [{ required: true, message: '名称不能为空', trigger: 'blur' }]
}

const itemTypeOptions = [
  { value: '1', label: '景点' },
  { value: '2', label: '交通' },
  { value: '3', label: '住宿' },
  { value: '4', label: '餐饮' },
  { value: '5', label: '其他' }
]

const activeDay = computed(() => days.value.find(d => d.id === activeDayId.value))
const activeDayItems = computed({
  get() {
    return activeDay.value ? (activeDay.value.itemList || []) : []
  },
  set(val) {
    if (activeDay.value) activeDay.value.itemList = val
  }
})

function typeText(t) {
  return { '1': '景点', '2': '交通', '3': '住宿', '4': '餐饮', '5': '其他' }[t] || '其他'
}
function typeTag(t) {
  return { '1': 'primary', '2': 'success', '3': 'warning', '4': 'danger', '5': 'info' }[t] || 'info'
}

function loadTripOptions() {
  listTrip({ pageNum: 1, pageSize: 100 }).then(res => {
    tripOptions.value = res.rows || []
  })
}

function loadSpots() {
  listSpot({ pageNum: 1, pageSize: 200 }).then(res => {
    spotOptions.value = res.rows || []
  })
}

async function handleTripChange() {
  trip.value = tripOptions.value.find(t => t.id === tripId.value)
  await ensureDays()
  await loadDays()
}

function diffDays(start, end) {
  if (!start || !end) return 0
  const s = new Date(String(start).slice(0, 10))
  const e = new Date(String(end).slice(0, 10))
  return Math.floor((e - s) / 86400000) + 1
}

function addDays(dateStr, n) {
  const d = new Date(String(dateStr).slice(0, 10))
  d.setDate(d.getDate() + n)
  return d.toISOString().slice(0, 10)
}

// 自动补齐缺失的天
async function ensureDays() {
  if (!trip.value) return
  const total = diffDays(trip.value.startDate, trip.value.endDate)
  if (total <= 0) return
  const current = await listDayTree(tripId.value)
  const existing = current.data || current.rows || []
  for (let i = 1; i <= total; i++) {
    if (!existing.find(d => Number(d.dayNo) === i)) {
      await addDay({ tripId: tripId.value, dayNo: i, tripDate: addDays(trip.value.startDate, i - 1) })
    }
  }
}

async function loadDays() {
  const res = await listDayTree(tripId.value)
  days.value = (res.data || res.rows || []).sort((a, b) => Number(a.dayNo) - Number(b.dayNo))
  if (days.value.length && !activeDayId.value) {
    activeDayId.value = days.value[0].id
  }
}

function handleCreateDay() {
  if (!activeDayId.value) {
    ElMessage.warning('请先选择行程')
    return
  }
  resetItemForm()
  itemDialogTitle.value = '添加日程项'
  itemDialogOpen.value = true
}

function resetItemForm() {
  itemForm.value = {
    id: undefined,
    dayId: activeDayId.value,
    itemName: undefined,
    itemType: '1',
    startTime: undefined,
    endTime: undefined,
    spotId: undefined,
    note: undefined,
    sortOrder: undefined
  }
  selectedSpotId.value = undefined
}

function handleSpotSelect(spotId) {
  const spot = spotOptions.value.find(s => s.id === spotId)
  if (spot) {
    itemForm.value.itemName = spot.spotName
    itemForm.value.spotId = spot.id
  }
}

function handleEditItem(row) {
  resetItemForm()
  itemForm.value = { ...row, dayId: activeDayId.value }
  selectedSpotId.value = row.spotId
  itemDialogTitle.value = '编辑日程项'
  itemDialogOpen.value = true
}

function submitItem() {
  proxy.$refs.itemRef.validate(valid => {
    if (!valid) return
    const data = { ...itemForm.value }
    if (data.itemType !== '1') data.spotId = undefined
    if (data.id) {
      updateItem(data).then(() => {
        ElMessage.success('修改成功')
        itemDialogOpen.value = false
        loadDays()
      })
    } else {
      const maxSort = (activeDay.value.itemList || []).length
      data.sortOrder = maxSort + 1
      addItem(data).then(() => {
        ElMessage.success('新增成功')
        itemDialogOpen.value = false
        loadDays()
      })
    }
  })
}

function handleDelItem(row) {
  ElMessageBox.confirm(`确认删除「${row.itemName}」吗？`, '提示', { type: 'warning' }).then(() => {
    return delItem(row.id)
  }).then(() => {
    ElMessage.success('删除成功')
    loadDays()
  }).catch(() => {})
}

function handleSortEnd() {
  const list = activeDayItems.value.map((item, index) => ({ id: item.id, sortOrder: index + 1 }))
  updateItemSort(list).then(() => {
    ElMessage.success('排序已保存')
  })
}

onMounted(() => {
  loadTripOptions()
  loadSpots()
})
</script>

<style scoped lang="scss">
.day-page {
  padding: 12px 16px;

  .day-header {
    display: flex;
    align-items: center;
    gap: 8px;
    margin-bottom: 10px;
  }

  .day-trip-info {
    margin-bottom: 12px;
    .day-trip-dest {
      font-size: 18px;
      font-weight: 600;
      color: #303133;
    }
    .day-trip-date {
      font-size: 12px;
      color: #909399;
      margin-top: 2px;
    }
  }

  .day-tabs {
    display: flex;
    gap: 8px;
    overflow-x: auto;
    padding-bottom: 10px;
    -webkit-overflow-scrolling: touch;

    .day-tab {
      flex-shrink: 0;
      min-width: 64px;
      text-align: center;
      padding: 8px 12px;
      border-radius: 10px;
      background: #f5f7fa;
      cursor: pointer;
      transition: all 0.15s;

      &.active {
        background: #409eff;
        color: #fff;
      }

      .day-tab__no {
        display: block;
        font-size: 14px;
        font-weight: 600;
      }
      .day-tab__date {
        display: block;
        font-size: 11px;
        opacity: 0.75;
        margin-top: 2px;
      }
    }
  }

  .day-items {
    min-height: 200px;

    .day-items__empty {
      text-align: center;
      color: #c0c4cc;
      padding: 60px 0;
      font-size: 13px;
    }
  }

  .day-item {
    display: flex;
    align-items: flex-start;
    background: #fff;
    border-radius: 10px;
    padding: 12px;
    margin-bottom: 10px;
    box-shadow: 0 1px 8px rgba(31, 45, 61, 0.06);

    .day-item__time {
      width: 52px;
      flex-shrink: 0;
      text-align: center;
      font-size: 14px;
      font-weight: 600;
      color: #303133;
      .day-item__time-end {
        display: block;
        font-size: 11px;
        font-weight: 400;
        color: #909399;
      }
    }

    .day-item__dot {
      width: 8px;
      height: 8px;
      border-radius: 50%;
      margin: 6px 10px 0 0;
      flex-shrink: 0;
      &.type-1 { background: #409eff; }
      &.type-2 { background: #67c23a; }
      &.type-3 { background: #e6a23c; }
      &.type-4 { background: #f56c6c; }
      &.type-5 { background: #909399; }
    }

    .day-item__content {
      flex: 1;
      .day-item__name {
        font-size: 15px;
        color: #303133;
        display: flex;
        align-items: center;
        gap: 6px;
        flex-wrap: wrap;
      }
      .day-item__note {
        font-size: 12px;
        color: #909399;
        margin-top: 4px;
      }
    }

    .day-item__actions {
      display: flex;
      align-items: center;
      gap: 2px;
      flex-shrink: 0;
      .drag-handle {
        cursor: grab;
        color: #c0c4cc;
        display: inline-flex;
        padding: 4px;
        &:active { cursor: grabbing; }
      }
    }
  }
}
</style>

<style lang="scss">
.ghost {
  opacity: 0.5;
  background: #ecf5ff !important;
}
</style>
