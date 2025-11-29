# 测试指南 - Airport Backend & Frontend

## 前置要求

确保你的电脑已安装：
- **Node.js** (建议版本 18 或更高)
- **npm** (通常随 Node.js 一起安装)

检查安装：
```bash
node --version
npm --version
```

## 测试步骤

### 第一步：启动 Backend (后端)

1. 打开终端/命令提示符，进入 backend 目录：
```bash
cd C:\airport-backend
```

2. 安装依赖：
```bash
npm install
```

3. 启动服务器：
```bash
npm start
```

或者使用开发模式（自动重启）：
```bash
npm run dev
```

4. 确认后端运行成功：
   - 终端应显示：`Server is running on http://localhost:3000`
   - 在浏览器访问：`http://localhost:3000/api/health`
   - 应看到：`{"status":"ok"}`

### 第二步：启动 Frontend (前端)

1. **打开新的终端/命令提示符窗口**（保持 backend 运行），进入 frontend 目录：
```bash
cd C:\airport-frontend
```

2. 安装依赖：
```bash
npm install
```

3. 启动开发服务器：
```bash
npm run dev
```

4. 确认前端运行成功：
   - 终端应显示类似：`Local: http://localhost:5173/`
   - 在浏览器访问：`http://localhost:5173`
   - 应看到航班管理界面

## 测试功能

### 后端 API 测试

可以使用以下方式测试后端 API：

#### 使用浏览器：
- 健康检查：`http://localhost:3000/api/health`
- 获取所有航班：`http://localhost:3000/api/flights`
- 获取单个航班：`http://localhost:3000/api/flights/1`

#### 使用 PowerShell (Windows)：
```powershell
# 测试健康检查
Invoke-RestMethod -Uri "http://localhost:3000/api/health"

# 获取所有航班
Invoke-RestMethod -Uri "http://localhost:3000/api/flights"

# 创建新航班
$body = @{
    flightNumber = "AA123"
    airline = "American Airlines"
    type = "Departure"
    status = "On Time"
    scheduledTime = "2024-01-15T10:00:00Z"
    gate = "A12"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:3000/api/flights" -Method POST -Body $body -ContentType "application/json"
```

### 前端功能测试

在前端界面 (`http://localhost:5173`) 测试：

1. **查看航班列表** - 应显示所有航班数据
2. **搜索功能** - 在搜索框输入班机号
3. **筛选功能** - 使用筛选栏筛选：
   - 类型（Departure/Arrival）
   - 航空公司
   - 状态（On Time/Delayed/Boarding/Cancelled/Landed）
4. **新增航班** - 点击"新增航班"按钮，填写表单并提交
5. **编辑航班** - 点击表格中的编辑按钮，修改航班信息
6. **删除航班** - 点击删除按钮，确认删除

## 常见问题

### 端口被占用

如果端口 3000 或 5173 已被占用：

**Backend** - 修改 `C:\airport-backend\index.js` 中的 `PORT` 变量
**Frontend** - 修改 `C:\airport-frontend\vite.config.js` 中的 `port` 值

### 依赖安装失败

尝试：
```bash
# 清除缓存
npm cache clean --force

# 删除 node_modules 和 package-lock.json 后重新安装
rm -rf node_modules package-lock.json
npm install
```

### 前端无法连接后端

确保：
1. 后端正在运行（检查 `http://localhost:3000/api/health`）
2. 前端 API 配置正确（`C:\airport-frontend\src\services\api.js` 中的 `API_BASE_URL`）
3. 没有防火墙阻止连接

## 快速测试命令

在 PowerShell 中，你可以使用以下命令快速测试：

```powershell
# 测试后端健康检查
curl http://localhost:3000/api/health

# 测试获取航班列表
curl http://localhost:3000/api/flights
```

