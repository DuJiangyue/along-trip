<template>
  <div class="app-container share-page">
    <!-- 行程选择 -->
    <div class="share-header">
      <el-select v-model="tripId" placeholder="选择行程" filterable style="flex: 1" @change="handleTripChange">
        <el-option v-for="t in tripOptions" :key="t.id" :label="t.tripName" :value="t.id" />
      </el-select>
      <el-button type="primary" icon="Share" round @click="handleCreateShare">生成分享</el-button>
    </div>

    <template v-if="tripId">
      <!-- 分享结果 -->
      <div v-if="shareCode" class="share-result">
        <div class="share-result__label">分享口令</div>
        <div class="share-result__code">{{ shareCode }}</div>
        <div class="share-result__link">{{ shareLink }}</div>
        <div class="share-result__actions">
          <el-button type="primary" plain icon="CopyDocument" @click="copyShare">复制链接</el-button>
          <el-button plain icon="View" @click="previewShare">只读预览</el-button>
        </div>
        <div class="share-result__hint">打开分享链接或输入口令，即可查看只读行程（无需登录，不可编辑）</div>
      </div>

      <!-- 只读预览 -->
      <div v-if="previewOpen" class="share-preview">
        <div class="share-preview__header">
          <div class="share-preview__title">{{ preview.trip.tripName }}</div>
          <div class="share-preview__dest">{{ preview.trip.destination }} · {{ (preview.trip.startDate || '').slice(0, 10) }} ~ {{ (preview.trip.endDate || '').slice(0, 10) }}</div>
        </div>
        <div v-for="d in preview.days" :key="d.id" class="share-preview__day">
          <div class="share-preview__day-title">第 {{ d.dayNo }} 天 · {{ (d.tripDate || '').slice(5, 10) }}</div>
          <div v-for="it in (d.itemList || [])" :key="it.id" class="share-preview__item">
            <span class="item-time">{{ it.startTime || '--:--' }}</span>
            <span class="item-name">{{ it.itemName }}</span>
            <el-tag size="small" :type="typeTag(it.itemType)" effect="light">{{ typeText(it.itemType) }}</el-tag>
          </div>
          <div v-if="!(d.itemList || []).length" class="share-preview__empty">暂无安排</div>
        </div>
      </div>

      <el-empty v-if="!shareCode && !previewOpen" description="选择行程后点击「生成分享」" />
    </template>
    <el-empty v-else description="请选择行程" />
  </div>
</template>

<script setup name="TripShare">
import { listTrip } from "@/api/trip/trip";
import { createShare, getShareInfo } from "@/api/trip/share";
import { ElMessage } from 'element-plus'

const tripId = ref(undefined)
const tripOptions = ref([])
const shareCode = ref(undefined)
const previewOpen = ref(false)
const preview = ref({ trip: {}, days: [] })

const shareLink = computed(() => shareCode.value ? `${window.location.origin}/share?code=${shareCode.value}` : '')

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

function handleTripChange() {
  shareCode.value = undefined
  previewOpen.value = false
}

function handleCreateShare() {
  createShare(tripId.value).then(res => {
    shareCode.value = res.data || res.msg
    ElMessage.success('分享口令已生成')
  })
}

function copyShare() {
  if (navigator.clipboard) {
    navigator.clipboard.writeText(shareLink.value).then(() => ElMessage.success('链接已复制'))
  } else {
    ElMessage.info('请手动复制：' + shareLink.value)
  }
}

function previewShare() {
  getShareInfo(shareCode.value).then(res => {
    preview.value = {
      trip: res.trip || {},
      days: res.days || []
    }
    previewOpen.value = true
  })
}

onMounted(() => {
  loadTripOptions()
})
</script>

<style scoped lang="scss">
.share-page {
  padding: 16px;

  .share-header {
    display: flex;
    align-items: center;
    gap: 8px;
    margin-bottom: 14px;
  }

  .share-result {
    background: #fff;
    border-radius: 12px;
    padding: 18px;
    box-shadow: 0 2px 12px rgba(31, 45, 61, 0.08);

    .share-result__label {
      font-size: 13px;
      color: #909399;
    }
    .share-result__code {
      font-size: 26px;
      font-weight: 700;
      color: #409eff;
      letter-spacing: 3px;
      margin: 6px 0;
    }
    .share-result__link {
      font-size: 12px;
      color: #909399;
      word-break: break-all;
      margin-bottom: 12px;
    }
    .share-result__actions {
      display: flex;
      gap: 8px;
    }
    .share-result__hint {
      font-size: 12px;
      color: #c0c4cc;
      margin-top: 10px;
    }
  }

  .share-preview {
    margin-top: 14px;
    background: #fff;
    border-radius: 12px;
    padding: 16px;
    box-shadow: 0 2px 12px rgba(31, 45, 61, 0.08);

    .share-preview__header {
      margin-bottom: 12px;
      .share-preview__title {
        font-size: 18px;
        font-weight: 700;
        color: #303133;
      }
      .share-preview__dest {
        font-size: 13px;
        color: #909399;
        margin-top: 4px;
      }
    }

    .share-preview__day {
      margin-bottom: 12px;
      .share-preview__day-title {
        font-size: 14px;
        font-weight: 600;
        color: #409eff;
        margin-bottom: 6px;
      }
      .share-preview__item {
        display: flex;
        align-items: center;
        gap: 8px;
        padding: 8px 0;
        border-bottom: 1px dashed #f0f2f5;
        .item-time { font-size: 13px; color: #606266; font-weight: 600; min-width: 48px; }
        .item-name { flex: 1; font-size: 14px; color: #303133; }
      }
      .share-preview__empty {
        font-size: 12px;
        color: #c0c4cc;
        padding: 8px 0;
      }
    }
  }
}
</style>
