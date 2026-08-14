<template>
  <div class="app-container trip-page">
    <!-- 工具栏 -->
    <div class="trip-toolbar">
      <el-input
        v-model="queryParams.tripName"
        placeholder="搜索行程名称"
        clearable
        style="max-width: 220px"
        @keyup.enter="handleQuery"
      >
        <template #prefix><el-icon><Search /></el-icon></template>
      </el-input>
      <el-button type="primary" icon="Plus" round @click="handleAdd" v-hasPermi="['trip:trip:add']">新建行程</el-button>
    </div>

    <!-- 卡片流 -->
    <div v-loading="loading" class="trip-list">
      <div v-for="trip in tripList" :key="trip.id" class="trip-card">
        <div class="trip-card__cover" :style="{ background: trip.themeColor || '#409eff' }">
          <span>{{ trip.destination || '未设置目的地' }}</span>
        </div>
        <div class="trip-card__body">
          <div class="trip-card__name">{{ trip.tripName }}</div>
          <div class="trip-card__date">{{ (trip.startDate || '').slice(0, 10) }} ~ {{ (trip.endDate || '').slice(0, 10) }}</div>
          <div class="trip-card__footer">
            <el-tag :type="statusType(trip.status)" size="small" effect="light">{{ statusText(trip.status) }}</el-tag>
            <div class="trip-card__actions">
              <el-button link type="primary" icon="Edit" @click="handleUpdate(trip)" v-hasPermi="['trip:trip:edit']">编辑</el-button>
              <el-button link type="danger" icon="Delete" @click="handleDelete(trip)" v-hasPermi="['trip:trip:remove']">删除</el-button>
            </div>
          </div>
        </div>
      </div>
      <el-empty v-if="!loading && !tripList.length" description="暂无行程" />
    </div>

    <pagination
      v-show="total > 0"
      :total="total"
      v-model:page="queryParams.pageNum"
      v-model:limit="queryParams.pageSize"
      @pagination="getList"
    />

    <!-- 新建/编辑弹窗 -->
    <el-dialog :title="title" v-model="open" width="480px" append-to-body>
      <el-form ref="tripRef" :model="form" :rules="rules" label-width="80px">
        <el-form-item label="行程名称" prop="tripName">
          <el-input v-model="form.tripName" placeholder="请输入行程名称" />
        </el-form-item>
        <el-form-item label="目的地" prop="destination">
          <el-input v-model="form.destination" placeholder="请输入目的地" />
        </el-form-item>
        <el-form-item label="起止日期" prop="dateRange">
          <el-date-picker
            v-model="form.dateRange"
            type="daterange"
            value-format="YYYY-MM-DD"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="主题色" prop="themeColor">
          <el-color-picker v-model="form.themeColor" />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="form.status">
            <el-radio value="0">草稿</el-radio>
            <el-radio value="1">进行中</el-radio>
            <el-radio value="2">已完成</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="备注" prop="remark">
          <el-input v-model="form.remark" type="textarea" placeholder="请输入备注" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="open = false">取 消</el-button>
        <el-button type="primary" @click="submitForm">确 定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup name="Trip">
import { listTrip, addTrip, updateTrip, delTrip } from "@/api/trip/trip";
import { ElMessage, ElMessageBox } from 'element-plus'

const { proxy } = getCurrentInstance()
const tripList = ref([])
const loading = ref(false)
const total = ref(0)
const open = ref(false)
const title = ref('')

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  tripName: undefined
})

const form = ref({})
const rules = {
  tripName: [{ required: true, message: '行程名称不能为空', trigger: 'blur' }]
}

function getList() {
  loading.value = true
  listTrip(queryParams).then(res => {
    tripList.value = res.rows || []
    total.value = res.total || 0
  }).finally(() => {
    loading.value = false
  })
}

function handleQuery() {
  queryParams.pageNum = 1
  getList()
}

function reset() {
  form.value = {
    id: undefined,
    tripName: undefined,
    destination: undefined,
    dateRange: [],
    themeColor: '#409eff',
    status: '0',
    remark: undefined
  }
}

function handleAdd() {
  reset()
  open.value = true
  title.value = '新建行程'
}

function handleUpdate(row) {
  reset()
  form.value = {
    id: row.id,
    tripName: row.tripName,
    destination: row.destination,
    dateRange: [row.startDate, row.endDate],
    themeColor: row.themeColor || '#409eff',
    status: row.status || '0',
    remark: row.remark
  }
  open.value = true
  title.value = '编辑行程'
}

function submitForm() {
  proxy.$refs.tripRef.validate(valid => {
    if (!valid) return
    const data = { ...form.value }
    if (data.dateRange && data.dateRange.length === 2) {
      data.startDate = data.dateRange[0]
      data.endDate = data.dateRange[1]
    }
    delete data.dateRange
    if (data.id) {
      updateTrip(data).then(() => {
        ElMessage.success('修改成功')
        open.value = false
        getList()
      })
    } else {
      addTrip(data).then(() => {
        ElMessage.success('新增成功')
        open.value = false
        getList()
      })
    }
  })
}

function handleDelete(row) {
  ElMessageBox.confirm(`确认删除行程「${row.tripName}」吗？`, '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    return delTrip(row.id)
  }).then(() => {
    ElMessage.success('删除成功')
    getList()
  }).catch(() => {})
}

function statusText(status) {
  return { '0': '草稿', '1': '进行中', '2': '已完成' }[status] || '草稿'
}

function statusType(status) {
  return { '0': 'info', '1': 'primary', '2': 'success' }[status] || 'info'
}

onMounted(() => {
  getList()
})
</script>

<style scoped lang="scss">
.trip-page {
  padding: 16px;

  .trip-toolbar {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 16px;
  }

  .trip-list {
    min-height: 200px;
  }

  .trip-card {
    display: flex;
    background: #fff;
    border-radius: 12px;
    overflow: hidden;
    margin-bottom: 14px;
    box-shadow: 0 2px 12px rgba(31, 45, 61, 0.08);
    transition: transform 0.15s ease, box-shadow 0.15s ease;

    &:hover {
      transform: translateY(-2px);
      box-shadow: 0 6px 20px rgba(31, 45, 61, 0.14);
    }

    .trip-card__cover {
      width: 92px;
      min-height: 100px;
      display: flex;
      align-items: center;
      justify-content: center;
      flex-shrink: 0;
      color: #fff;
      font-size: 15px;
      font-weight: 600;
      text-align: center;
      padding: 8px;
      word-break: break-all;
    }

    .trip-card__body {
      flex: 1;
      padding: 12px 14px;
      display: flex;
      flex-direction: column;

      .trip-card__name {
        font-size: 16px;
        font-weight: 600;
        color: #303133;
        margin-bottom: 6px;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
      }

      .trip-card__date {
        font-size: 12px;
        color: #909399;
        margin-bottom: 8px;
      }

      .trip-card__footer {
        margin-top: auto;
        display: flex;
        align-items: center;
        justify-content: space-between;

        .trip-card__actions {
          display: flex;
          gap: 4px;
        }
      }
    }
  }
}
</style>
