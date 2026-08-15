<template>
  <div class="app-container member-page">
    <!-- 行程选择 -->
    <div class="member-header">
      <el-select v-model="tripId" placeholder="选择行程" filterable style="flex: 1" @change="handleTripChange">
        <el-option v-for="t in tripOptions" :key="t.id" :label="t.tripName" :value="t.id" />
      </el-select>
      <el-button v-if="isOwner" type="primary" icon="Plus" round @click="handleAdd" v-hasPermi="['trip:member:add']">邀请成员</el-button>
    </div>

    <template v-if="tripId">
      <div class="member-role-tip">
        当前角色：{{ roleText(currentRole) }}
        <span v-if="!isOwner" class="member-role-tip__hint">（仅行程所有者可管理成员）</span>
      </div>

      <!-- 成员列表 -->
      <div v-loading="loading" class="member-list">
        <div v-for="m in memberList" :key="m.id" class="member-item">
          <el-avatar :size="40" class="member-item__avatar">{{ (m.userName || m.userId).slice(0, 1) }}</el-avatar>
          <div class="member-item__info">
            <div class="member-item__name">{{ m.userName || ('用户 ' + m.userId) }}</div>
            <div class="member-item__id">ID: {{ m.userId }}</div>
          </div>
          <el-tag :type="roleTag(m.role)" size="small" effect="light">{{ roleText(m.role) }}</el-tag>
          <el-button v-if="isOwner" link type="danger" icon="Delete" @click="handleDelete(m)" v-hasPermi="['trip:member:remove']"></el-button>
        </div>
        <el-empty v-if="!loading && !memberList.length" description="暂无成员" />
      </div>
    </template>
    <el-empty v-else description="请选择行程" />

    <!-- 邀请成员弹窗 -->
    <el-dialog title="邀请成员" v-model="open" width="420px" append-to-body>
      <el-form ref="memberRef" :model="form" :rules="rules" label-width="80px">
        <el-form-item label="用户ID" prop="userId">
          <el-input-number v-model="form.userId" :min="1" :controls="false" placeholder="输入用户ID" style="width: 100%" />
        </el-form-item>
        <el-form-item label="角色" prop="role">
          <el-radio-group v-model="form.role">
            <el-radio value="2">编辑者</el-radio>
            <el-radio value="3">浏览者</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="open = false">取 消</el-button>
        <el-button type="primary" @click="submitForm">确 定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup name="TripMember">
import { listTrip } from "@/api/trip/trip";
import { listMember, addMember, delMember } from "@/api/trip/member";
import { ElMessage, ElMessageBox } from 'element-plus'

const { proxy } = getCurrentInstance()
const tripId = ref(undefined)
const tripOptions = ref([])
const memberList = ref([])
const loading = ref(false)
const open = ref(false)
const currentRole = ref(undefined)

const form = ref({})
const rules = {
  userId: [{ required: true, message: '请输入用户ID', trigger: 'blur' }],
  role: [{ required: true, message: '请选择角色', trigger: 'change' }]
}

const isOwner = computed(() => currentRole.value === '1')

function roleText(r) {
  return { '1': '所有者', '2': '编辑者', '3': '浏览者' }[r] || '浏览者'
}
function roleTag(r) {
  return { '1': 'primary', '2': 'warning', '3': 'info' }[r] || 'info'
}

function loadTripOptions() {
  listTrip({ pageNum: 1, pageSize: 100 }).then(res => {
    tripOptions.value = res.rows || []
  })
}

function handleTripChange() {
  const t = tripOptions.value.find(x => x.id === tripId.value)
  currentRole.value = t ? t.userRole : undefined
  loadMembers()
}

function loadMembers() {
  loading.value = true
  listMember({ tripId: tripId.value }).then(res => {
    memberList.value = res.rows || []
  }).finally(() => {
    loading.value = false
  })
}

function handleAdd() {
  form.value = { tripId: tripId.value, userId: undefined, role: '2' }
  open.value = true
}

function submitForm() {
  proxy.$refs.memberRef.validate(valid => {
    if (!valid) return
    addMember(form.value).then(() => {
      ElMessage.success('邀请成功')
      open.value = false
      loadMembers()
    })
  })
}

function handleDelete(row) {
  ElMessageBox.confirm(`确认移除成员「${row.userName || row.userId}」吗？`, '提示', { type: 'warning' }).then(() => {
    return delMember(row.id)
  }).then(() => {
    ElMessage.success('移除成功')
    loadMembers()
  }).catch(() => {})
}

onMounted(() => {
  loadTripOptions()
})
</script>

<style scoped lang="scss">
.member-page {
  padding: 16px;

  .member-header {
    display: flex;
    align-items: center;
    gap: 8px;
    margin-bottom: 12px;
  }

  .member-role-tip {
    font-size: 13px;
    color: #606266;
    margin-bottom: 12px;
    .member-role-tip__hint {
      color: #c0c4cc;
      font-size: 12px;
    }
  }

  .member-list {
    min-height: 150px;
  }

  .member-item {
    display: flex;
    align-items: center;
    gap: 12px;
    background: #fff;
    border-radius: 10px;
    padding: 12px;
    margin-bottom: 10px;
    box-shadow: 0 1px 8px rgba(31, 45, 61, 0.06);

    .member-item__avatar {
      flex-shrink: 0;
      background: #409eff;
      color: #fff;
      font-size: 16px;
    }

    .member-item__info {
      flex: 1;
      min-width: 0;
      .member-item__name {
        font-size: 15px;
        color: #303133;
        font-weight: 600;
      }
      .member-item__id {
        font-size: 12px;
        color: #909399;
      }
    }
  }
}
</style>
