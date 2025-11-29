# Airport Flight Management Admin - Backend

後端 API 服務，提供航班管理的 RESTful API。

## 技術棧

- Node.js
- Express
- CORS

## 安裝與執行

```bash
# 安裝依賴
npm install

# 啟動伺服器
npm start

# 開發模式（自動重啟）
npm run dev
```

伺服器將運行在 `http://localhost:3000`

## API 端點

### GET /api/flights
取得航班列表，支援查詢參數：
- `type`: Departure | Arrival
- `airline`: 航空公司名稱
- `status`: On Time | Delayed | Boarding | Cancelled | Landed
- `q`: 班機號模糊搜尋
- `sortBy`: scheduledTime
- `order`: asc | desc

### GET /api/flights/:id
取得單一航班

### POST /api/flights
新增航班

### PUT /api/flights/:id
更新航班

### DELETE /api/flights/:id
刪除航班

