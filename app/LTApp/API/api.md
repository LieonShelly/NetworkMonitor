### 5.3 读取周报
- URL: ``GET /api/weekly-report``
- 描述: 读取已生成的周报（仅读库，不触发生成）。返回结构化内容 ``report_json``、参与该周报的图标列表 ``icons``（带签名 URL），以及报告周期的开始/结束日期。若该周报尚未阅读，会在读取时自动标记为已读并写入 ``read_at``。
- 认证: 需要
- 查询参数:
    - ``week``: 周标识（可选）。格式为 ``YYYY-Wnn``（如 2024-W43）。不传则返回当前用户最新一条周报；传入则返回该周的报告。
- 响应示例:
    ```json
    {
		"id": "cmnvswhmh0000lgppw17ef1pk",
		"week": "2026-W14",
		"period_start": "2026-04-05",
		"period_end": "2026-04-11",
		"reflection_count": 14,
		"report_json": {
			"gem": {
				"icon": {
					"id": "cmnpyfg6o00013sppj1ey4ghx",
					"url": "https://little-things-app.oss-cn-shanghai.aliyuncs.com/icons/cmnpyfg6o00013sppj1ey4ghx-1775647099328.webp?OSSAccessKeyId=LTAI5tSRABgPkhdcz6K9xXp7&Expires=1776853481&Signature=xzuLQUErCSWg%2FaMnUEl3I8HjOg0%3D"
				},
				"insight": "In that moment, you weren't just seeking comfort; you were allowing the roots of a relationship to find soft, nurturing ground in the quiet.",
				"evidence": "...and you captured the warmth of connection perfectly: '磨一下'",
				"answer_id": "cmnpyfg6i00003sppnuaqnv5j"
			},
			"glance": "Tending to the soft sprouts of connection.",
			"summary": "You have tended to the landscape of your heart this season, cultivating moments of gentle release and finding nourishment in the playful rhythm of your daily growth.",
			"reminders": ["Let your roots settle into this quiet season.", "Trust the sunlight found in small treats.", "Allow your heart to bloom at its own pace."]
		},
		"read_at": "2026-04-21T09:33:12.345Z",
		"icons": [{
			"id": "cmnmnzlji003fc8pphcc0byr6",
			"url": "https://little-things-app.oss-cn-shanghai.aliyuncs.com/icons/cmnmnzlji003fc8pphcc0byr6-1775448164142.webp?OSSAccessKeyId=LTAI5tSRABgPkhdcz6K9xXp7&Expires=1776853481&Signature=jhhNqZUs27%2FDCNs0Y45IUWuAjW8%3D"
		}, {
			"id": "cmnmoegmx003mc8ppn3dlsl61",
			"url": "https://little-things-app.oss-cn-shanghai.aliyuncs.com/icons/cmnmoegmx003mc8ppn3dlsl61-1775448860368.webp?OSSAccessKeyId=LTAI5tSRABgPkhdcz6K9xXp7&Expires=1776853481&Signature=MhWr7w6hkpNRDiM8buSh5J6zR1w%3D"
		}, {
			"id": "cmnmp3ro6003zc8ppv6haw3v4",
			"url": "https://little-things-app.oss-cn-shanghai.aliyuncs.com/icons/cmnmp3ro6003zc8ppv6haw3v4-1775450037772.webp?OSSAccessKeyId=LTAI5tSRABgPkhdcz6K9xXp7&Expires=1776853481&Signature=Y9tkibC7pK5xLA2Te4d%2BVZmUMWg%3D"
		}, {
			"id": "cmnmppl1i0044c8pp5e0iymfv",
			"url": "https://little-things-app.oss-cn-shanghai.aliyuncs.com/icons/cmnmppl1i0044c8pp5e0iymfv-1775451056330.webp?OSSAccessKeyId=LTAI5tSRABgPkhdcz6K9xXp7&Expires=1776853481&Signature=kI97hvrfu69Ghu3YDpfsfp32dPE%3D"
		}, {
			"id": "cmnmpt0xo0047c8pp6nw4iqmw",
			"url": "https://little-things-app.oss-cn-shanghai.aliyuncs.com/icons/cmnmpt0xo0047c8pp6nw4iqmw-1775452610957.webp?OSSAccessKeyId=LTAI5tSRABgPkhdcz6K9xXp7&Expires=1776853481&Signature=KR3NKx3XGTcQH9ErDGBKPr6WrVw%3D"
		}, {
			"id": "cmnmptkqz0049c8ppebqualie",
			"url": "https://little-things-app.oss-cn-shanghai.aliyuncs.com/icons/cmnmptkqz0049c8ppebqualie-1775451240163.webp?OSSAccessKeyId=LTAI5tSRABgPkhdcz6K9xXp7&Expires=1776853481&Signature=eFqJU4jn%2FSTgr%2BHwVQbgeX40tZs%3D"
		}, {
			"id": "cmnmpvla7004cc8pps2pgrpp9",
			"url": "https://little-things-app.oss-cn-shanghai.aliyuncs.com/icons/cmnmpvla7004cc8pps2pgrpp9-1775451336853.webp?OSSAccessKeyId=LTAI5tSRABgPkhdcz6K9xXp7&Expires=1776853481&Signature=yqYkWIqmCKIEr6TFX3pHKg%2B1YTI%3D"
		}, {
			"id": "cmnn3k44b004lc8ppbycp50ma",
			"url": "https://little-things-app.oss-cn-shanghai.aliyuncs.com/icons/cmnn3k44b004lc8ppbycp50ma-1775475126081.webp?OSSAccessKeyId=LTAI5tSRABgPkhdcz6K9xXp7&Expires=1776853481&Signature=phukcjAiqEgJunwGaRFrmQkSvK4%3D"
		}, {
			"id": "cmnn63rnz0057c8pp3ytyu83m",
			"url": "https://little-things-app.oss-cn-shanghai.aliyuncs.com/icons/cmnn63rnz0057c8pp3ytyu83m-1775478596035.webp?OSSAccessKeyId=LTAI5tSRABgPkhdcz6K9xXp7&Expires=1776853481&Signature=c%2FB%2B5IAKDA%2BU7ikUR5yn%2FWldpDw%3D"
		}, {
			"id": "cmnn6xk8i005mc8pp725yz0il",
			"url": "https://little-things-app.oss-cn-shanghai.aliyuncs.com/icons/cmnn6xk8i005mc8pp725yz0il-1775540493901.webp?OSSAccessKeyId=LTAI5tSRABgPkhdcz6K9xXp7&Expires=1776853481&Signature=dOgs21ktvDiyVJGwaVgCxfV1USc%3D"
		}, {
			"id": "cmno5wtl0005wc8pp3dz20edb",
			"url": "https://little-things-app.oss-cn-shanghai.aliyuncs.com/icons/cmno5wtl0005wc8pp3dz20edb-1775538733512.webp?OSSAccessKeyId=LTAI5tSRABgPkhdcz6K9xXp7&Expires=1776853481&Signature=Ad0f784FIxpR05HZfGX81VeWwzo%3D"
		}, {
			"id": "cmnogxb7k0067c8pp1z6y168p",
			"url": "https://little-things-app.oss-cn-shanghai.aliyuncs.com/icons/cmnogxb7k0067c8pp1z6y168p-1775557232832.webp?OSSAccessKeyId=LTAI5tSRABgPkhdcz6K9xXp7&Expires=1776853481&Signature=9dL0FLirmFK5nRm0MiHuW%2BctCVU%3D"
		}, {
			"id": "cmnpksen9000dl7pp0uiyffww",
			"url": "https://little-things-app.oss-cn-shanghai.aliyuncs.com/icons/cmnpksen9000dl7pp0uiyffww-1775624190866.webp?OSSAccessKeyId=LTAI5tSRABgPkhdcz6K9xXp7&Expires=1776853481&Signature=tw8Pzc9wuIKVGr2s9HDxsoL5ZCg%3D"
		}, {
			"id": "cmnpyfg6o00013sppj1ey4ghx",
			"url": "https://little-things-app.oss-cn-shanghai.aliyuncs.com/icons/cmnpyfg6o00013sppj1ey4ghx-1775647099328.webp?OSSAccessKeyId=LTAI5tSRABgPkhdcz6K9xXp7&Expires=1776853481&Signature=xzuLQUErCSWg%2FaMnUEl3I8HjOg0%3D"
		}],
		"count": {
			"categories": [{
				"id": "cmglykn6l000zpp1s2cl80c9t",
				"name": "Simple Joys",
				"count": 4
			}, {
				"id": "cmglykn68000lpp1sjzq44ydt",
				"name": "Small Wins",
				"count": 3
			}, {
				"id": "cmglykn6f000tpp1sf9cu2zr5",
				"name": "Warm Hearts",
				"count": 5
			}, {
				"id": "cmglykn66000dpp1szllsmb88",
				"name": "Inner Peace",
				"count": 2
			}],
			"total": 14
		}
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


### 1.6 保存用户时区
- URL: POST /api/timezone
- 描述: 接收一个带 UTC 偏移的 ISO 8601 时间戳，解析其中的时区偏移并存储到用户记录中，用于后续按本地时间推送每日提醒（Daily Whisper）
- 认证: 需要
- 请求参数:
	``` json
	{
  		"timestamp": "2026-04-05T09:00:00+08:00"
	}
	```
	- timestamp：必填，ISO 8601 格式，必须包含 UTC 偏移（如 +08:00、-05:00、+00:00）
- 响应示例:
	``` json
		{
			"success": true,
			"data": {
				"timezone": "+08:00"
			}
		}
	```

- 错误响应:
	- timestamp 缺失：返回 400 Bad Request
	- timestamp 不含 UTC 偏移：返回 400 Bad Request




### 1.9 获取个人信息
- URL: GET /api/me
- 描述: 获取当前登录用户的个人信息
- 认证: 需要
- 响应示例:
```json
{
  "success": true,
  "data": {
    "email": "user@example.com",
    "nickname": "Yuyi",
    "qod_strategy": "RANDOM",
    "last_login_at": "2026-02-03T08:00:00.000Z",
    "has_pinned_question": true,
    "report_persona_id": "cludpersona123456789",
    "report_persona": {
      "id": "cludpersona123456789",
      "label": "Persona 1: The Soul Gardener"
    },
    "reminder_slot": "EVENING"
  }
}
```
- 说明:
  - email：用户邮箱（可能为 null）
  - nickname：用户昵称，未设置时为 null
  - qod_strategy：用户的「今日问题」策略，取值为 RANDOM、PINNED、MIXED
  - last_login_at：最后登录时间，ISO 8601 格式
  - has_pinned_question：当前用户是否至少 pin 了一道题（boolean）
  - report_persona_id：当前选中的周报 AI Persona 的 id，未选时为 null
  - report_persona：当前选中的 Persona 摘要（id、label），未选时为 null。可用于前端展示当前选中项，完整列表见 GET /api/ai-insights/personas
  - reminder_slot：每日推送提醒时段，null 表示已关闭。详见 GET /api/me/reminder

### 1.10 更新昵称
- URL: POST /api/me
- 描述: 更新当前登录用户昵称
- 认证: 需要
- 请求参数:
``` json
{
  "nickname": "Yuyi"
}
```
- 参数说明:
  - nickname：可选；string | null
  - 传字符串：保存前会去除首尾空格，空字符串会被当作 null（清空昵称）
  - 传 null：清空昵称
  - 不传该字段（如 {}）：不做修改
- 响应示例:
```json
{
  "success": true,
  "data": {
    "nickname": "Yuyi"
  }
}
```
- 错误响应:
  - nickname 类型非法（非 string 且非 null）：返回 400 Bad Request
  - nickname 长度超过 64：返回 400 Bad Request

### 1.11 获取每日提醒时段
- URL: GET /api/me/reminder
- 描述: 获取当前登录用户的每日推送提醒时段
- 认证: 需要
- 响应示例:
```json
{
  "success": true,
  "data": {
    "slot": "EVENING"
  }
}
```
- 说明:
  - slot 取值及对应推送时间（用户本地时间）：
  ```
  MORNING	10:30
  AFTERNOON	15:00
  EVENING	21:30
  null	已关闭提醒
  新用户默认为 EVENING
  ```

### 1.12 设置每日提醒时段
- URL: POST /api/me/reminder
- 描述: 设置当前登录用户的每日推送提醒时段，推送按用户本地时间（由 POST /api/timezone 设置）触发
- 认证: 需要
- 请求参数:
```json
{
  "slot": "MORNING"
}
```
- 参数说明:
  - slot：可选；取值 MORNING / AFTERNOON / EVENING / null
  - 传具体时段：更新为对应时段
  - 传 null：关闭每日提醒
  - 不传该字段（如 {}）：不做修改，仅返回当前值
- 响应示例:
```json
{
  "success": true,
  "data": {
    "slot": "MORNING"
  }
}
```
- 错误响应:
  - slot 值非法（非 MORNING、AFTERNOON、EVENING、null）：返回 400 Bad Request



### 6.1 获取 Report Persona 列表
- URL: GET /api/ai-insights/personas
- 描述: 获取所有可用的 Report Persona 选项，供前端选择
- 认证: 需要
- 响应示例:
```json
[
  {
    "id": "cludpersona123456789",
    "label": "Empathetic Friend",
    "description": "A warm and supportive tone that focuses on emotional connection"
  },
  {
    "id": "cludpersona098765432",
    "label": "Analytical Coach",
    "description": "A structured and insightful tone that focuses on patterns and growth"
  }
]
```
- 说明:
  - 按 label 字母升序排列
  - description 可能为 null
  
### 6.2 更新 Report Persona
- URL: POST /api/ai-insights/report-persona
- 描述: 更新当前用户的 Report Persona（影响周报生成风格）
- 认证: 需要
- 请求参数:
```json
{
  "report_persona_id": "cludpersona123456789"
}
```
- 响应示例:
```json
{
  "report_persona_id": "cludpersona123456789"
}
```
- 错误响应:
  - report_persona_id 未提供：返回 400 Bad Request
  - report_persona_id 无效（不存在）：返回 400 Bad Request