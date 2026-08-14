<template>
  <div class="app-container workspace">
    <!-- 顶部 -->
    <div class="workspace-header">
      <h2 class="workspace-title">我的行程</h2>
      <el-button type="primary" icon="Plus" round @click="handleCreate">新建行程</el-button>
    </div>

    <!-- 卡片流 -->
    <div v-loading="loading" class="trip-list">
      <div
        v-for="trip in tripList"
        :key="trip.id"
        class="trip-card"
        @click="handleDetail(trip)"
      >
        <div class="trip-card__cover" :style="{ background: trip.themeColor || '#409eff' }">
          <span class="trip-card__dest">{{ trip.destination || '未设置目的地' }}</span>
        </div>
        <div class="trip-card__body">
          <div class="trip-card__name">{{ trip.tripName }}</div>
          <div class="trip-card__date">{{ formatDate(trip.startDate) }} ~ {{ formatDate(trip.endDate) }}</div>
          <div class="trip-card__footer">
            <el-tag :type="statusType(trip.status)" size="small" effect="light">{{ statusText(trip.status) }}</el-tag>
          </div>
        </div>
      </div>

      <!-- 空状态 -->
      <el-empty v-if="!loading && !tripList.length" description="还没有行程，点击右上角新建一个吧" />
    </div>
  </div>
</template>

<script setup name="Index">
import { listTrip } from "@/api/trip/trip";

const router = useRouter()
const tripList = ref([])
const loading = ref(false)

function getList() {
  loading.value = true
  listTrip({ pageNum: 1, pageSize: 100 }).then(res => {
    tripList.value = res.rows || []
  }).finally(() => {
    loading.value = false
  })
}

function formatDate(date) {
  return date ? String(date).slice(0, 10) : '待定'
}

function statusText(status) {
  return { '0': '草稿', '1': '进行中', '2': '已完成' }[status] || '草稿'
}

function statusType(status) {
  return { '0': 'info', '1': 'primary', '2': 'success' }[status] || 'info'
}

function handleCreate() {
  router.push('/trip/index')
}

function handleDetail(trip) {
  router.push('/trip/index')
}

onMounted(() => {
  getList()
})
</script>

<style scoped lang="scss">
.workspace {
  padding: 16px;

  .workspace-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 16px;

    .workspace-title {
      font-size: 20px;
      font-weight: 600;
      color: #303133;
      margin: 0;
    }
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
    cursor: pointer;
    transition: transform 0.15s ease, box-shadow 0.15s ease;

    &:hover {
      transform: translateY(-2px);
      box-shadow: 0 6px 20px rgba(31, 45, 61, 0.14);
    }

    .trip-card__cover {
      width: 92px;
      min-height: 96px;
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
      }
    }
  }
}
</style>
