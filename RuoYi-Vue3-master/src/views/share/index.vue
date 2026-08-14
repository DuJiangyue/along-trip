<template>
  <div class="share-view">
    <div class="share-view__top">
      <div class="share-view__brand">一程随行</div>
      <div class="share-view__badge">只读分享</div>
    </div>

    <!-- 输入口令 -->
    <div v-if="!loaded" class="share-view__entry">
      <el-input v-model="codeInput" placeholder="输入分享口令" clearable @keyup.enter="loadShare">
        <template #append><el-button @click="loadShare">查看</el-button></template>
      </el-input>
    </div>

    <!-- 只读行程 -->
    <div v-else class="share-view__content">
      <div class="share-view__trip">
        <div class="share-view__trip-name">{{ trip.tripName }}</div>
        <div class="share-view__trip-meta">
          <span>{{ trip.destination || '未设置目的地' }}</span>
          <span>{{ (trip.startDate || '').slice(0, 10) }} ~ {{ (trip.endDate || '').slice(0, 10) }}</span>
        </div>
      </div>

      <div v-for="d in days" :key="d.id" class="share-view__day">
        <div class="share-view__day-title">
          <span class="day-no">第 {{ d.dayNo }} 天</span>
          <span class="day-date">{{ (d.tripDate || '').slice(5, 10) }}</span>
        </div>
        <div class="share-view__items">
          <div v-for="it in (d.itemList || [])" :key="it.id" class="share-view__item">
            <span class="item-time">{{ it.startTime || '--:--' }}</span>
            <span class="item-dot" :class="'type-' + it.itemType"></span>
            <span class="item-name">{{ it.itemName }}</span>
            <el-tag size="small" :type="typeTag(it.itemType)" effect="light">{{ typeText(it.itemType) }}</el-tag>
          </div>
          <div v-if="!(d.itemList || []).length" class="share-view__empty">这一天还没有安排</div>
        </div>
      </div>
    </div>

    <div class="share-view__footer">由「一程随行」生成 · 只读视图不可编辑</div>
  </div>
</template>

<script setup name="Share">
import { getShareInfo } from "@/api/trip/share";
import { ElMessage } from 'element-plus'

const route = useRoute()
const codeInput = ref(route.query.code || '')
const loaded = ref(false)
const trip = ref({})
const days = ref([])

function typeText(t) {
  return { '1': '景点', '2': '交通', '3': '住宿', '4': '餐饮', '5': '其他' }[t] || '其他'
}
function typeTag(t) {
  return { '1': 'primary', '2': 'success', '3': 'warning', '4': 'danger', '5': 'info' }[t] || 'info'
}

function loadShare() {
  if (!codeInput.value || !codeInput.value.trim()) {
    ElMessage.warning('请输入分享口令')
    return
  }
  getShareInfo(codeInput.value.trim()).then(res => {
    trip.value = res.trip || {}
    days.value = res.days || []
    loaded.value = true
  }).catch(() => {
    ElMessage.error('分享链接无效或已过期')
  })
}

onMounted(() => {
  if (codeInput.value) {
    loadShare()
  }
})
</script>

<style scoped lang="scss">
.share-view {
  min-height: 100vh;
  background: linear-gradient(135deg, #409eff 0%, #66b1ff 50%, #a0cfff 100%);
  padding-bottom: 60px;

  .share-view__top {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 16px 20px;
    color: #fff;
    .share-view__brand {
      font-size: 18px;
      font-weight: 700;
      letter-spacing: 1px;
    }
    .share-view__badge {
      font-size: 12px;
      background: rgba(255, 255, 255, 0.25);
      border-radius: 20px;
      padding: 4px 12px;
    }
  }

  .share-view__entry {
    max-width: 480px;
    margin: 40px auto 0;
    padding: 0 20px;
  }

  .share-view__content {
    max-width: 480px;
    margin: 12px auto 0;
    padding: 0 16px;

    .share-view__trip {
      background: #fff;
      border-radius: 16px;
      padding: 18px;
      box-shadow: 0 8px 24px rgba(31, 45, 61, 0.12);
      .share-view__trip-name {
        font-size: 20px;
        font-weight: 700;
        color: #303133;
      }
      .share-view__trip-meta {
        display: flex;
        gap: 12px;
        font-size: 13px;
        color: #909399;
        margin-top: 6px;
      }
    }

    .share-view__day {
      background: #fff;
      border-radius: 16px;
      padding: 16px;
      margin-top: 12px;
      box-shadow: 0 8px 24px rgba(31, 45, 61, 0.12);

      .share-view__day-title {
        display: flex;
        align-items: center;
        gap: 8px;
        margin-bottom: 10px;
        .day-no { font-size: 15px; font-weight: 700; color: #409eff; }
        .day-date { font-size: 13px; color: #909399; }
      }

      .share-view__items {
        .share-view__item {
          display: flex;
          align-items: center;
          gap: 8px;
          padding: 8px 0;
          border-bottom: 1px dashed #f0f2f5;
          &:last-child { border-bottom: none; }
          .item-time { font-size: 13px; color: #606266; font-weight: 600; min-width: 48px; }
          .item-dot {
            width: 8px; height: 8px; border-radius: 50%; flex-shrink: 0;
            &.type-1 { background: #409eff; }
            &.type-2 { background: #67c23a; }
            &.type-3 { background: #e6a23c; }
            &.type-4 { background: #f56c6c; }
            &.type-5 { background: #909399; }
          }
          .item-name { flex: 1; font-size: 14px; color: #303133; }
        }
        .share-view__empty {
          font-size: 13px;
          color: #c0c4cc;
          padding: 8px 0;
        }
      }
    }
  }

  .share-view__footer {
    text-align: center;
    color: rgba(255, 255, 255, 0.8);
    font-size: 12px;
    padding: 20px 0;
  }
}
</style>
