<template>
  <div class="app-container spot-page">
    <!-- 搜索栏 -->
    <div class="spot-toolbar">
      <el-input v-model="queryParams.spotName" placeholder="搜索景点名称" clearable @keyup.enter="handleQuery" style="flex: 1" />
      <el-input v-model="queryParams.city" placeholder="城市" clearable @keyup.enter="handleQuery" style="max-width: 110px" />
      <el-button type="primary" icon="Plus" round @click="handleAdd" v-hasPermi="['trip:spot:add']">新增</el-button>
    </div>

    <!-- 景点卡片列表 -->
    <div v-loading="loading" class="spot-list">
      <div v-for="spot in spotList" :key="spot.id" class="spot-card">
        <div class="spot-card__img">
          <img v-if="spot.imageUrl" :src="spot.imageUrl" />
          <el-icon v-else class="spot-card__placeholder"><Picture /></el-icon>
        </div>
        <div class="spot-card__body">
          <div class="spot-card__name">
            {{ spot.spotName }}
            <el-rate v-if="spot.rating" :model-value="Number(spot.rating)" disabled size="small" style="display: inline-flex" />
          </div>
          <div class="spot-card__city">{{ spot.city || '未知城市' }}{{ spot.address ? ' · ' + spot.address : '' }}</div>
          <div class="spot-card__intro">{{ spot.intro || '暂无简介' }}</div>
          <div class="spot-card__footer">
            <span class="spot-card__coord" v-if="spot.lng && spot.lat">坐标 {{ spot.lng }}, {{ spot.lat }}</span>
            <div class="spot-card__actions">
              <el-button link type="primary" icon="Edit" @click="handleUpdate(spot)" v-hasPermi="['trip:spot:edit']">编辑</el-button>
              <el-button link type="danger" icon="Delete" @click="handleDelete(spot)" v-hasPermi="['trip:spot:remove']">删除</el-button>
            </div>
          </div>
        </div>
      </div>
      <el-empty v-if="!loading && !spotList.length" description="暂无景点" />
    </div>

    <pagination
      v-show="total > 0"
      :total="total"
      v-model:page="queryParams.pageNum"
      v-model:limit="queryParams.pageSize"
      @pagination="getList"
    />

    <!-- 新增/编辑弹窗 -->
    <el-dialog :title="title" v-model="open" width="480px" append-to-body>
      <el-form ref="spotRef" :model="form" :rules="rules" label-width="70px">
        <el-form-item label="名称" prop="spotName">
          <el-input v-model="form.spotName" placeholder="请输入景点名称" />
        </el-form-item>
        <el-form-item label="城市" prop="city">
          <el-input v-model="form.city" placeholder="请输入城市" />
        </el-form-item>
        <el-form-item label="地址" prop="address">
          <el-input v-model="form.address" placeholder="请输入地址" />
        </el-form-item>
        <el-form-item label="地图选点">
          <map-picker :lng="form.lng" :lat="form.lat" @update="handleMapPick" />
        </el-form-item>
        <el-form-item label="评分">
          <el-rate v-model="form.rating" allow-half />
        </el-form-item>
        <el-form-item label="图片" prop="imageUrl">
          <el-input v-model="form.imageUrl" placeholder="图片 URL（可选）" />
        </el-form-item>
        <el-form-item label="简介">
          <el-input v-model="form.intro" type="textarea" :rows="3" placeholder="请输入简介" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="open = false">取 消</el-button>
        <el-button type="primary" @click="submitForm">确 定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup name="TripSpot">
import { listSpot, addSpot, updateSpot, delSpot } from "@/api/trip/spot";
import MapPicker from "@/components/MapPicker";
import { ElMessage, ElMessageBox } from 'element-plus'

const { proxy } = getCurrentInstance()
const spotList = ref([])
const loading = ref(false)
const total = ref(0)
const open = ref(false)
const title = ref('')

const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  spotName: undefined,
  city: undefined
})

const form = ref({})
const rules = {
  spotName: [{ required: true, message: '景点名称不能为空', trigger: 'blur' }]
}

function getList() {
  loading.value = true
  listSpot(queryParams).then(res => {
    spotList.value = res.rows || []
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
    spotName: undefined,
    city: undefined,
    address: undefined,
    lng: undefined,
    lat: undefined,
    rating: 0,
    intro: undefined,
    imageUrl: undefined
  }
}

function handleMapPick(pos) {
  form.value.lng = pos.lng
  form.value.lat = pos.lat
  if (pos.name) form.value.spotName = pos.name
  if (pos.address) form.value.address = pos.address
}

function handleAdd() {
  reset()
  open.value = true
  title.value = '新增景点'
}

function handleUpdate(row) {
  form.value = { ...row }
  open.value = true
  title.value = '编辑景点'
}

function submitForm() {
  proxy.$refs.spotRef.validate(valid => {
    if (!valid) return
    const data = { ...form.value }
    if (data.id) {
      updateSpot(data).then(() => {
        ElMessage.success('修改成功')
        open.value = false
        getList()
      })
    } else {
      addSpot(data).then(() => {
        ElMessage.success('新增成功')
        open.value = false
        getList()
      })
    }
  })
}

function handleDelete(row) {
  ElMessageBox.confirm(`确认删除景点「${row.spotName}」吗？`, '提示', { type: 'warning' }).then(() => {
    return delSpot(row.id)
  }).then(() => {
    ElMessage.success('删除成功')
    getList()
  }).catch(() => {})
}

onMounted(() => {
  getList()
})
</script>

<style scoped lang="scss">
.spot-page {
  padding: 16px;

  .spot-toolbar {
    display: flex;
    align-items: center;
    gap: 8px;
    margin-bottom: 16px;
  }

  .spot-list {
    min-height: 200px;
  }

  .spot-card {
    display: flex;
    background: #fff;
    border-radius: 12px;
    overflow: hidden;
    margin-bottom: 14px;
    box-shadow: 0 2px 12px rgba(31, 45, 61, 0.08);

    .spot-card__img {
      width: 96px;
      min-height: 100px;
      background: #f5f7fa;
      display: flex;
      align-items: center;
      justify-content: center;
      flex-shrink: 0;
      img {
        width: 100%;
        height: 100%;
        object-fit: cover;
      }
      .spot-card__placeholder {
        font-size: 30px;
        color: #c0c4cc;
      }
    }

    .spot-card__body {
      flex: 1;
      padding: 12px 14px;
      min-width: 0;

      .spot-card__name {
        font-size: 15px;
        font-weight: 600;
        color: #303133;
        margin-bottom: 4px;
      }
      .spot-card__city {
        font-size: 12px;
        color: #909399;
        margin-bottom: 6px;
      }
      .spot-card__intro {
        font-size: 12px;
        color: #606266;
        margin-bottom: 8px;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
      }
      .spot-card__footer {
        display: flex;
        align-items: center;
        justify-content: space-between;
        .spot-card__coord {
          font-size: 11px;
          color: #c0c4cc;
        }
        .spot-card__actions {
          display: flex;
          gap: 4px;
        }
      }
    }
  }
}
</style>
