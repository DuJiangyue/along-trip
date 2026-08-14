<template>
  <div class="app-container budget-page">
    <!-- 行程选择 -->
    <div class="budget-header">
      <el-select v-model="tripId" placeholder="选择行程" filterable style="flex: 1" @change="handleTripChange">
        <el-option v-for="t in tripOptions" :key="t.id" :label="t.tripName" :value="t.id" />
      </el-select>
      <el-button type="primary" icon="Plus" round @click="handleAdd" v-hasPermi="['trip:budget:add']">新增预算</el-button>
    </div>

    <template v-if="tripId">
      <!-- 汇总卡片 -->
      <div class="budget-summary">
        <div class="summary-item">
          <div class="summary-item__value">¥{{ formatMoney(totalBudget) }}</div>
          <div class="summary-item__label">总预算</div>
        </div>
        <div class="summary-item">
          <div class="summary-item__value">¥{{ formatMoney(totalActual) }}</div>
          <div class="summary-item__label">已花费</div>
        </div>
        <div class="summary-item" :class="{ over: remain < 0 }">
          <div class="summary-item__value">¥{{ formatMoney(remain) }}</div>
          <div class="summary-item__label">剩余</div>
        </div>
      </div>

      <!-- 饼图 -->
      <div v-if="budgetList.length" ref="chartRef" class="budget-chart"></div>

      <!-- 分类预算列表 -->
      <div v-loading="loading" class="budget-list">
        <div v-for="b in budgetList" :key="b.id" class="budget-item">
          <div class="budget-item__cat" :class="'cat-' + b.category">{{ catText(b.category) }}</div>
          <div class="budget-item__info">
            <div class="budget-item__row">
              <span class="budget-item__label">预算</span>
              <span class="budget-item__amount">¥{{ formatMoney(b.budgetAmount) }}</span>
            </div>
            <div class="budget-item__row">
              <span class="budget-item__label">实际</span>
              <span class="budget-item__amount actual">¥{{ formatMoney(b.actualAmount) }}</span>
            </div>
          </div>
          <div class="budget-item__actions">
            <el-button link type="primary" icon="Edit" @click="handleUpdate(b)" v-hasPermi="['trip:budget:edit']"></el-button>
            <el-button link type="danger" icon="Delete" @click="handleDelete(b)" v-hasPermi="['trip:budget:remove']"></el-button>
          </div>
        </div>
        <el-empty v-if="!loading && !budgetList.length" description="暂无预算记录，点击右上角新增" />
      </div>
    </template>
    <el-empty v-else description="请选择行程" />

    <!-- 新增/编辑弹窗 -->
    <el-dialog :title="title" v-model="open" width="440px" append-to-body>
      <el-form ref="budgetRef" :model="form" :rules="rules" label-width="80px">
        <el-form-item label="分类" prop="category">
          <el-select v-model="form.category" placeholder="选择分类" style="width: 100%">
            <el-option v-for="c in catOptions" :key="c.value" :label="c.label" :value="c.value" />
          </el-select>
        </el-form-item>
        <el-form-item label="预算金额" prop="budgetAmount">
          <el-input-number v-model="form.budgetAmount" :precision="2" :min="0" :step="100" style="width: 100%" />
        </el-form-item>
        <el-form-item label="实际花费" prop="actualAmount">
          <el-input-number v-model="form.actualAmount" :precision="2" :min="0" :step="100" style="width: 100%" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="open = false">取 消</el-button>
        <el-button type="primary" @click="submitForm">确 定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup name="TripBudget">
import * as echarts from 'echarts'
import { listTrip } from "@/api/trip/trip";
import { listBudget, addBudget, updateBudget, delBudget } from "@/api/trip/budget";
import { ElMessage, ElMessageBox } from 'element-plus'

const { proxy } = getCurrentInstance()
const tripId = ref(undefined)
const tripOptions = ref([])
const budgetList = ref([])
const loading = ref(false)
const open = ref(false)
const title = ref('')
const chartRef = ref(null)

const form = ref({})
const rules = {
  category: [{ required: true, message: '请选择分类', trigger: 'change' }]
}

const catOptions = [
  { value: '1', label: '交通' },
  { value: '2', label: '住宿' },
  { value: '3', label: '餐饮' },
  { value: '4', label: '门票' },
  { value: '5', label: '其他' }
]

const totalBudget = computed(() => budgetList.value.reduce((s, b) => s + Number(b.budgetAmount || 0), 0))
const totalActual = computed(() => budgetList.value.reduce((s, b) => s + Number(b.actualAmount || 0), 0))
const remain = computed(() => totalBudget.value - totalActual.value)

function catText(c) {
  return { '1': '交通', '2': '住宿', '3': '餐饮', '4': '门票', '5': '其他' }[c] || '其他'
}
function formatMoney(v) {
  return Number(v || 0).toFixed(2)
}

function loadTripOptions() {
  listTrip({ pageNum: 1, pageSize: 100 }).then(res => {
    tripOptions.value = res.rows || []
  })
}

function handleTripChange() {
  loadBudgets()
}

function loadBudgets() {
  loading.value = true
  listBudget({ tripId: tripId.value }).then(res => {
    budgetList.value = res.rows || []
    nextTick(renderChart)
  }).finally(() => {
    loading.value = false
  })
}

function renderChart() {
  if (!chartRef.value || !budgetList.value.length) return
  if (!chartRef.value._chart) {
    chartRef.value._chart = echarts.init(chartRef.value)
  }
  chartRef.value._chart.setOption({
    tooltip: { trigger: 'item', formatter: '{b}: ¥{c} ({d}%)' },
    series: [{
      type: 'pie',
      radius: ['40%', '68%'],
      data: budgetList.value.map(b => ({ name: catText(b.category), value: Number(b.actualAmount || 0) }))
    }]
  })
}

function reset() {
  form.value = { id: undefined, tripId: tripId.value, category: undefined, budgetAmount: 0, actualAmount: 0 }
}

function handleAdd() {
  reset()
  open.value = true
  title.value = '新增预算'
}

function handleUpdate(row) {
  form.value = { ...row, tripId: tripId.value }
  open.value = true
  title.value = '编辑预算'
}

function submitForm() {
  proxy.$refs.budgetRef.validate(valid => {
    if (!valid) return
    const data = { ...form.value }
    if (data.id) {
      updateBudget(data).then(() => {
        ElMessage.success('修改成功')
        open.value = false
        loadBudgets()
      })
    } else {
      addBudget(data).then(() => {
        ElMessage.success('新增成功')
        open.value = false
        loadBudgets()
      })
    }
  })
}

function handleDelete(row) {
  ElMessageBox.confirm(`确认删除「${catText(row.category)}」预算项吗？`, '提示', { type: 'warning' }).then(() => {
    return delBudget(row.id)
  }).then(() => {
    ElMessage.success('删除成功')
    loadBudgets()
  }).catch(() => {})
}

onMounted(() => {
  loadTripOptions()
})
</script>

<style scoped lang="scss">
.budget-page {
  padding: 16px;

  .budget-header {
    display: flex;
    align-items: center;
    gap: 8px;
    margin-bottom: 14px;
  }

  .budget-summary {
    display: flex;
    gap: 10px;
    margin-bottom: 14px;

    .summary-item {
      flex: 1;
      background: #fff;
      border-radius: 12px;
      padding: 14px 12px;
      text-align: center;
      box-shadow: 0 2px 10px rgba(31, 45, 61, 0.06);

      .summary-item__value {
        font-size: 20px;
        font-weight: 700;
        color: #303133;
      }
      .summary-item__label {
        font-size: 12px;
        color: #909399;
        margin-top: 4px;
      }
      &.over .summary-item__value { color: #f56c6c; }
    }
  }

  .budget-chart {
    width: 100%;
    height: 220px;
    margin-bottom: 14px;
  }

  .budget-list {
    min-height: 120px;
  }

  .budget-item {
    display: flex;
    align-items: center;
    background: #fff;
    border-radius: 10px;
    padding: 12px;
    margin-bottom: 10px;
    box-shadow: 0 1px 8px rgba(31, 45, 61, 0.06);

    .budget-item__cat {
      width: 46px;
      height: 46px;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      color: #fff;
      font-size: 13px;
      font-weight: 600;
      flex-shrink: 0;
      &.cat-1 { background: #409eff; }
      &.cat-2 { background: #67c23a; }
      &.cat-3 { background: #e6a23c; }
      &.cat-4 { background: #f56c6c; }
      &.cat-5 { background: #909399; }
    }

    .budget-item__info {
      flex: 1;
      margin-left: 12px;
      .budget-item__row {
        display: flex;
        justify-content: space-between;
        font-size: 13px;
        padding: 2px 0;
        .budget-item__label { color: #909399; }
        .budget-item__amount { color: #303133; font-weight: 600; }
        .budget-item__amount.actual { color: #f56c6c; }
      }
    }

    .budget-item__actions {
      display: flex;
      gap: 2px;
    }
  }
}
</style>
