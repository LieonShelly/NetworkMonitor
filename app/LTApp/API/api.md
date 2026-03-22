### 5.3 读取周报
- URL: ``GET /api/weekly-report``
- 描述: 读取已生成的周报（仅读库，不触发生成）。返回结构化内容 ``report_json``、参与该周报的图标列表 ``icons``（带签名 URL），以及报告周期的开始/结束日期。若该周报尚未阅读，会在读取时自动标记为已读并写入 ``read_at``。
- 认证: 需要
- 查询参数:
    - ``week``: 周标识（可选）。格式为 ``YYYY-Wnn``（如 2024-W43）。不传则返回当前用户最新一条周报；传入则返回该周的报告。
- 响应示例:
    ```json
    {
            "id": "cludreport123456789",
            "week": "2024-W43",
            "period_start": "2024-10-21",
            "period_end": "2024-10-27",
            "reflection_count": 9,
            "read_at": "2026-03-18T03:20:00.000Z",
            "report_json": {
                "summary": "这一周你记录了 9 次反思...",
                "gem": {
                "scene": "On Wednesday afternoon, you sat by the window with a freshly brewed coffee in your hands.",
                "evidence": "'At that moment, I suddenly relaxed and felt the day was not as bad as I thought.'",
                "insight": "In that moment, you must have felt a quiet sense of being held by something small but steady."
                },
                "analyticalOverview": [
                { "title": "咖啡与专注", "content": "Coffee is your reliable focus trigger..." },
                { "title": "人际联结", "content": "..." },
                { "title": "情绪基调", "content": "..." }
                ]
            },
            "icons": [
                { "id": "cludicon123456789", "url": "https://..." },
                { "id": "cludicon098765432", "url": "https://..." }
            ]
    }   

    ```

### 5.4 获取周报列表
- URL: ``GET /api/weekly-reports``
- 描述: 分页获取当前用户的周报列表，返回简要信息，适合列表展示。
- 认证: 需要
- 查询参数:
    - ``limit``: 每页数量（可选，默认 20，最大 100）
    - ``cursor``: 周标识（可选）。格式 ``YYYY-Wnn``。传入则返回该周之前的报告，用于分页
    - ``isRead``: 读状态筛选（可选）。true 仅返回已读（``read_at != null``），``false`` 仅返回未读（``read_at = null``）；不传则返回全部
- 响应示例:
    ```json
    {
    "reports": [
        {
        "id": "cludreport123456789",
        "week": "2024-W43",
        "period_start": "2024-10-21",
        "period_end": "2024-10-27",
        "reflection_count": 9,
        "read_at": null
        },
        "summary": "",
        "icon": {
            "id": "cludicon123456789",
            "url": ""
            }
    ],
    "pagination": {
        "limit": 20,
        "hasMore": true,
        "nextCursor": "2024-W36"
        }
    }
    ```
- 说明:
    - 按 ``week`` 降序返回（最新在前）
    - ``read_at``：null 表示未读，非 null 表示已读时间（ISO 8601）
    - 示例：
        - ``GET /api/weekly-reports?isRead=false``：仅未读
        - ``GET /api/weekly-reports?isRead=true``：仅已读
- 获取单条周报详情请使用 ``GET /api/weekly-report?week=YYYY-Wnn``

 ### 5.5标记周报已读
- URL: POST /api/weekly-report/read
- 描述: 显式将指定周报标记为已读（幂等）。若此前已读，则返回原有 read_at。
- 认证: 需要
- 请求参数:
  ``` json
    {
      "week": "2024-W43"
    }
  ```
- 响应示例:
    ```json
        {
        "week": "2024-W43",
        "read_at": "2026-03-18T03:20:00.000Z"
        }
    ```

- 错误响应:
    - week 缺失或格式错误（非 YYYY-Wnn）：返回 400 Bad Request
    - 该周报不存在：返回 404 Not Found