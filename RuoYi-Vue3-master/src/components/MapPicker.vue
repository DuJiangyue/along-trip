<template>
  <div class="map-picker">
    <div class="map-picker__search">
      <el-input v-model="keyword" placeholder="搜索地点（POI）" clearable @keyup.enter="doSearch">
        <template #append>
          <el-button icon="Search" @click="doSearch" />
        </template>
      </el-input>
    </div>

    <div v-if="amapReady" ref="mapRef" class="map-picker__map"></div>
    <div v-else class="map-picker__tip">{{ tip }}</div>

    <div v-if="searchResults.length" class="map-picker__results">
      <div v-for="r in searchResults" :key="r.id" class="map-picker__result" @click="pickResult(r)">
        <div class="map-picker__result-name">{{ r.name }}</div>
        <div class="map-picker__result-addr">{{ r.address }}</div>
      </div>
    </div>
  </div>
</template>

<script setup name="MapPicker">
import { ElMessage } from 'element-plus'

// ====== 高德地图（AMap）合规配置 ======
// 图商：高德地图（国家有资质图商，符合地图合规要求）
// 坐标：GCJ-02
// 请在高德开放平台 https://lbs.amap.com 申请「Web 端(JS API)」key 与安全密钥，
// 替换下方两个占位符即可启用地图。
const AMAP_KEY = 'Please apply for your own key at the AMap Open Platform and replace this placeholder'
const AMAP_SECURITY_CODE = 'Please apply for your own security code at the AMap Open Platform and replace this placeholder'
// ======================================

const props = defineProps({
  lng: { type: Number, default: undefined },
  lat: { type: Number, default: undefined }
})
const emit = defineEmits(['update'])

const mapRef = ref(null)
const keyword = ref('')
const searchResults = ref([])
const amapReady = ref(false)
const tip = ref('正在加载地图...')

let map = null
let placeSearch = null
let marker = null

function loadAMap() {
  return new Promise((resolve, reject) => {
    if (window.AMap) {
      resolve(window.AMap)
      return
    }
    window._AMapSecurityConfig = { securityJsCode: AMAP_SECURITY_CODE }
    const script = document.createElement('script')
    script.src = `https://webapi.amap.com/maps?v=2.0&key=${encodeURIComponent(AMAP_KEY)}&plugin=AMap.PlaceSearch`
    script.onload = () => resolve(window.AMap)
    script.onerror = () => reject(new Error('高德地图 SDK 加载失败'))
    document.head.appendChild(script)
  })
}

function initMap() {
  const center = (props.lng && props.lat) ? [props.lng, props.lat] : [116.397428, 39.90923]
  map = new AMap.Map(mapRef.value, { zoom: 13, center })
  amapReady.value = true

  // 地图点选回填经纬度
  map.on('click', e => {
    const lng = e.lnglat.getLng()
    const lat = e.lnglat.getLat()
    setMarker(lng, lat)
    emit('update', { lng, lat })
  })

  if (props.lng && props.lat) {
    setMarker(props.lng, props.lat)
  }

  AMap.plugin('AMap.PlaceSearch', () => {
    placeSearch = new AMap.PlaceSearch({ city: '全国', pageSize: 10 })
  })
}

function setMarker(lng, lat) {
  if (marker) {
    marker.setPosition([lng, lat])
  } else {
    marker = new AMap.Marker({ position: [lng, lat] })
    map.add(marker)
  }
  map.setCenter([lng, lat])
}

function doSearch() {
  if (!keyword.value || !keyword.value.trim() || !placeSearch) return
  placeSearch.search(keyword.value.trim(), (status, result) => {
    if (status === 'complete' && result.poiList && result.poiList.pois) {
      searchResults.value = result.poiList.pois.map(p => ({
        id: p.id,
        name: p.name,
        address: p.address,
        lng: p.location.lng,
        lat: p.location.lat
      }))
    } else {
      searchResults.value = []
    }
  })
}

function pickResult(r) {
  setMarker(r.lng, r.lat)
  keyword.value = r.name
  emit('update', { lng: r.lng, lat: r.lat, name: r.name, address: r.address })
  searchResults.value = []
}

onMounted(async () => {
  try {
    await loadAMap()
    initMap()
  } catch (e) {
    tip.value = '地图未配置：请在高德开放平台申请 Web 端(JS API) key 与安全密钥，替换 MapPicker.vue 中的占位符后即可使用'
  }
})

onBeforeUnmount(() => {
  if (map) {
    map.destroy()
    map = null
  }
})
</script>

<style scoped lang="scss">
.map-picker {
  width: 100%;

  .map-picker__search {
    margin-bottom: 8px;
  }

  .map-picker__map {
    width: 100%;
    height: 280px;
    border-radius: 8px;
    border: 1px solid #e4e7ed;
  }

  .map-picker__tip {
    width: 100%;
    height: 280px;
    border-radius: 8px;
    border: 1px dashed #dcdfe6;
    display: flex;
    align-items: center;
    justify-content: center;
    color: #909399;
    font-size: 13px;
    text-align: center;
    padding: 12px;
  }

  .map-picker__results {
    max-height: 180px;
    overflow-y: auto;
    margin-top: 6px;
    border: 1px solid #e4e7ed;
    border-radius: 8px;

    .map-picker__result {
      padding: 8px 12px;
      cursor: pointer;
      border-bottom: 1px solid #f0f2f5;

      &:last-child { border-bottom: none; }
      &:hover { background: #f5f7fa; }

      .map-picker__result-name {
        font-size: 13px;
        color: #303133;
      }
      .map-picker__result-addr {
        font-size: 11px;
        color: #909399;
        margin-top: 2px;
      }
    }
  }
}
</style>
