# Flutter TextField 完全指南

## 📋 基础知识

### TextField 默认支持的功能

Flutter的TextField **默认就支持**以下功能，无需额外配置：

✅ **复制（Copy）** - 长按选中文字后复制  
✅ **粘贴（Paste）** - 长按显示粘贴选项  
✅ **剪切（Cut）** - 长按选中文字后剪切  
✅ **全选（Select All）** - 长按显示全选选项  
✅ **撤销/重做** - iOS自动支持，Android需要额外配置

### 如何使用粘贴功能

#### iOS
1. 长按TextField
2. 选择"粘贴"（Paste）
3. 或者双击选中文字，然后选择"粘贴"

#### Android
1. 长按TextField
2. 选择"粘贴"（Paste）图标
3. 或者点击光标位置的粘贴按钮

---

## 🎯 TextField 基础配置

### 最简单的TextField

```dart
TextField(
  // 就这样，已经支持粘贴了！
)
```

### 带Controller的TextField

```dart
final TextEditingController _controller = TextEditingController();

TextField(
  controller: _controller,
  decoration: InputDecoration(
    hintText: '输入文字',
  ),
)

// 获取文字
String text = _controller.text;

// 设置文字
_controller.text = '新文字';

// 清空文字
_controller.clear();
```

---

## 🚀 常用配置

### 1. 多行输入

```dart
TextField(
  maxLines: null,  // 无限行
  minLines: 1,     // 最少1行
  keyboardType: TextInputType.multiline,
)

// 或者固定行数
TextField(
  maxLines: 5,  // 固定5行
)
```

### 2. 键盘类型

```dart
// 文本键盘
TextField(
  keyboardType: TextInputType.text,
)

// 数字键盘
TextField(
  keyboardType: TextInputType.number,
)

// 邮箱键盘
TextField(
  keyboardType: TextInputType.emailAddress,
)

// 电话键盘
TextField(
  keyboardType: TextInputType.phone,
)

// URL键盘
TextField(
  keyboardType: TextInputType.url,
)

// 多行文本
TextField(
  keyboardType: TextInputType.multiline,
)
```

### 3. 输入动作按钮

```dart
TextField(
  textInputAction: TextInputAction.send,     // 发送
  textInputAction: TextInputAction.done,     // 完成
  textInputAction: TextInputAction.next,     // 下一个
  textInputAction: TextInputAction.search,   // 搜索
  textInputAction: TextInputAction.go,       // 前往
  onSubmitted: (value) {
    print('提交: $value');
  },
)
```

### 4. 自动更正和建议

```dart
TextField(
  autocorrect: true,        // 启用自动更正
  enableSuggestions: true,  // 启用输入建议
)

// 禁用（适用于密码、验证码等）
TextField(
  autocorrect: false,
  enableSuggestions: false,
)
```

### 5. 密码输入

```dart
TextField(
  obscureText: true,  // 隐藏文字
  enableSuggestions: false,
  autocorrect: false,
  decoration: InputDecoration(
    hintText: '输入密码',
    suffixIcon: Icon(Icons.visibility),  // 显示/隐藏图标
  ),
)
```

### 6. 输入限制

```dart
import 'package:flutter/services.dart';

TextField(
  // 最大长度
  maxLength: 100,
  
  // 输入格式限制
  inputFormatters: [
    // 只允许数字
    FilteringTextInputFormatter.digitsOnly,
    
    // 只允许字母
    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
    
    // 禁止空格
    FilteringTextInputFormatter.deny(RegExp(r'\s')),
    
    // 自定义格式（电话号码）
    TextInputFormatter.withFunction((oldValue, newValue) {
      // 自定义逻辑
      return newValue;
    }),
  ],
)
```

---

## 🎨 样式配置

### 1. 基础样式

```dart
TextField(
  style: TextStyle(
    fontSize: 16,
    color: Colors.black,
    fontWeight: FontWeight.normal,
  ),
  decoration: InputDecoration(
    hintText: '提示文字',
    hintStyle: TextStyle(
      color: Colors.grey,
      fontSize: 14,
    ),
  ),
)
```

### 2. 边框样式

```dart
// 无边框
TextField(
  decoration: InputDecoration(
    border: InputBorder.none,
  ),
)

// 下划线边框
TextField(
  decoration: InputDecoration(
    border: UnderlineInputBorder(),
  ),
)

// 圆角边框
TextField(
  decoration: InputDecoration(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
)

// 自定义边框颜色
TextField(
  decoration: InputDecoration(
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.blue, width: 2),
    ),
  ),
)
```

### 3. 填充背景

```dart
TextField(
  decoration: InputDecoration(
    filled: true,
    fillColor: Colors.grey[100],
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: BorderSide.none,
    ),
  ),
)
```

### 4. 前缀和后缀图标

```dart
TextField(
  decoration: InputDecoration(
    // 前缀图标
    prefixIcon: Icon(Icons.search),
    
    // 后缀图标
    suffixIcon: IconButton(
      icon: Icon(Icons.clear),
      onPressed: () {
        _controller.clear();
      },
    ),
    
    // 前缀文字
    prefix: Text('¥ '),
    
    // 后缀文字
    suffix: Text('.00'),
  ),
)
```

---

## 🔧 高级功能

### 1. 自定义粘贴行为

```dart
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  
  const CustomTextField({required this.controller});
  
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      // 自定义工具栏
      contextMenuBuilder: (context, editableTextState) {
        return AdaptiveTextSelectionToolbar.buttonItems(
          anchors: editableTextState.contextMenuAnchors,
          buttonItems: [
            // 自定义粘贴按钮
            ContextMenuButtonItem(
              onPressed: () async {
                // 获取剪贴板内容
                final data = await Clipboard.getData(Clipboard.kTextPlain);
                if (data != null && data.text != null) {
                  // 自定义处理逻辑
                  final processedText = data.text!.toUpperCase();
                  controller.text = processedText;
                }
                ContextMenuController.removeAny();
              },
              type: ContextMenuButtonType.paste,
            ),
            // 添加其他按钮
            ContextMenuButtonItem(
              onPressed: () {
                // 自定义操作
                ContextMenuController.removeAny();
              },
              type: ContextMenuButtonType.custom,
              label: '自定义',
            ),
          ],
        );
      },
    );
  }
}
```

### 2. 监听文字变化

```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final TextEditingController _controller = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    
    // 方法1：使用addListener
    _controller.addListener(() {
      print('文字变化: ${_controller.text}');
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      // 方法2：使用onChanged
      onChanged: (value) {
        print('文字变化: $value');
      },
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

### 3. 焦点控制

```dart
class FocusExample extends StatefulWidget {
  @override
  State<FocusExample> createState() => _FocusExampleState();
}

class _FocusExampleState extends State<FocusExample> {
  final FocusNode _focusNode = FocusNode();
  
  @override
  void initState() {
    super.initState();
    
    // 监听焦点变化
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        print('获得焦点');
      } else {
        print('失去焦点');
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          focusNode: _focusNode,
        ),
        ElevatedButton(
          onPressed: () {
            // 请求焦点
            _focusNode.requestFocus();
          },
          child: Text('获取焦点'),
        ),
        ElevatedButton(
          onPressed: () {
            // 取消焦点
            _focusNode.unfocus();
          },
          child: Text('失去焦点'),
        ),
      ],
    );
  }
  
  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
}
```

### 4. 表单验证

```dart
class FormExample extends StatefulWidget {
  @override
  State<FormExample> createState() => _FormExampleState();
}

class _FormExampleState extends State<FormExample> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: '邮箱',
              hintText: '请输入邮箱',
            ),
            // 验证器
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入邮箱';
              }
              if (!value.contains('@')) {
                return '邮箱格式不正确';
              }
              return null;  // 验证通过
            },
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                print('验证通过: ${_emailController.text}');
              }
            },
            child: Text('提交'),
          ),
        ],
      ),
    );
  }
}
```

---

## 💡 实战案例

### 案例1：聊天输入框

```dart
class ChatInputField extends StatefulWidget {
  final Function(String) onSend;
  
  const ChatInputField({required this.onSend});
  
  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;
  
  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _hasText = _controller.text.isNotEmpty;
      });
    });
  }
  
  void _handleSend() {
    if (_controller.text.trim().isNotEmpty) {
      widget.onSend(_controller.text);
      _controller.clear();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              maxLines: null,
              minLines: 1,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.send,
              decoration: InputDecoration(
                hintText: '输入消息...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => _handleSend(),
            ),
          ),
          SizedBox(width: 8),
          FloatingActionButton(
            onPressed: _hasText ? _handleSend : null,
            backgroundColor: _hasText ? Colors.blue : Colors.grey,
            child: Icon(Icons.send),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

### 案例2：搜索框

```dart
class SearchField extends StatefulWidget {
  final Function(String) onSearch;
  
  const SearchField({required this.onSearch});
  
  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final TextEditingController _controller = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: '搜索...',
        prefixIcon: Icon(Icons.search),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  _controller.clear();
                  widget.onSearch('');
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onChanged: widget.onSearch,
    );
  }
}
```

### 案例3：密码输入框（带显示/隐藏）

```dart
class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  
  const PasswordField({required this.controller});
  
  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;
  
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscureText,
      enableSuggestions: false,
      autocorrect: false,
      decoration: InputDecoration(
        labelText: '密码',
        hintText: '请输入密码',
        prefixIcon: Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
        border: OutlineInputBorder(),
      ),
    );
  }
}
```

---

## 🐛 常见问题

### 问题1：粘贴功能不工作

**可能原因：**
1. 剪贴板没有内容
2. 应用没有剪贴板权限（iOS需要在Info.plist中配置）
3. TextField被禁用（`enabled: false`）
4. 使用了自定义的`contextMenuBuilder`但没有实现粘贴

**解决方案：**
```dart
// 确保TextField是启用的
TextField(
  enabled: true,  // 默认就是true
)

// iOS权限配置（ios/Runner/Info.plist）
<key>NSPhotoLibraryUsageDescription</key>
<string>需要访问相册以粘贴图片</string>
```

### 问题2：无法粘贴特殊字符

**解决方案：**
```dart
// 移除inputFormatters限制
TextField(
  // 不要使用过于严格的inputFormatters
  inputFormatters: [],  // 或者不设置
)
```

### 问题3：多行输入时高度不自动调整

**解决方案：**
```dart
TextField(
  maxLines: null,  // 关键！设置为null
  minLines: 1,
  keyboardType: TextInputType.multiline,
)
```

---

## 📚 最佳实践

### 1. 始终使用Controller

```dart
// ✅ 推荐
final _controller = TextEditingController();

TextField(
  controller: _controller,
)

// 记得dispose
@override
void dispose() {
  _controller.dispose();
  super.dispose();
}
```

### 2. 使用const优化性能

```dart
const TextField(
  decoration: InputDecoration(
    hintText: '输入文字',  // const字符串
  ),
)
```

### 3. 合理使用FocusNode

```dart
// 需要控制焦点时才使用
final _focusNode = FocusNode();

TextField(
  focusNode: _focusNode,
)

// 记得dispose
@override
void dispose() {
  _focusNode.dispose();
  super.dispose();
}
```

### 4. 表单验证使用TextFormField

```dart
// 在Form中使用TextFormField而不是TextField
Form(
  child: TextFormField(
    validator: (value) {
      // 验证逻辑
    },
  ),
)
```

---

## ✅ 检查清单

- [ ] TextField默认就支持粘贴，无需额外配置
- [ ] 使用TextEditingController管理文本
- [ ] 根据需求设置keyboardType
- [ ] 多行输入设置maxLines: null
- [ ] 记得dispose Controller和FocusNode
- [ ] 使用const优化性能
- [ ] 表单验证使用TextFormField

---

## 🎓 关键要点

1. **TextField默认支持粘贴** - 长按即可显示粘贴选项
2. **使用Controller管理文本** - 方便获取和设置文本
3. **合理配置键盘类型** - 提升用户体验
4. **多行输入设置maxLines: null** - 自动调整高度
5. **记得dispose资源** - 避免内存泄漏

这些都是Flutter开发的基础知识，掌握好TextField的使用对于构建良好的用户界面至关重要！
