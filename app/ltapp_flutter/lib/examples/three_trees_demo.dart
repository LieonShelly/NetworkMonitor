import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// 三棵树演示应用
///
/// 这个例子展示了Flutter的三棵树（Widget树、Element树、RenderObject树）
/// 如何协作工作。运行这个例子并观察控制台输出。
void main() {
  // 开启调试模式，显示rebuild信息
  debugPrintRebuildDirtyWidgets = true;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter三棵树演示',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ThreeTreesDemo(),
    );
  }
}

class ThreeTreesDemo extends StatefulWidget {
  const ThreeTreesDemo({Key? key}) : super(key: key);

  @override
  State<ThreeTreesDemo> createState() => _ThreeTreesDemoState();
}

class _ThreeTreesDemoState extends State<ThreeTreesDemo> {
  int _counter = 0;
  Color _boxColor = Colors.blue;

  @override
  Widget build(BuildContext context) {
    print('🔵 Widget.build() called - 创建新的Widget树');

    return Scaffold(
      appBar: AppBar(title: const Text('Flutter三棵树演示')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('点击次数:', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 8),
            Text(
              '$_counter',
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _counter++;
                });
              },
              child: const Text('增加计数'),
            ),
            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 20),
            const Text('颜色变化演示:', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                setState(() {
                  _boxColor = _boxColor == Colors.blue
                      ? Colors.red
                      : Colors.blue;
                });
              },
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: _boxColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    '点击\n改变颜色',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            const TreeInspectorButton(),
            const SizedBox(height: 20),
            const Text(
              '💡 提示：查看控制台输出',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 用于检查三棵树的按钮
class TreeInspectorButton extends StatelessWidget {
  const TreeInspectorButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        _inspectTrees(context);
      },
      icon: const Icon(Icons.search),
      label: const Text('检查三棵树'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }

  void _inspectTrees(BuildContext context) {
    print('\n${'=' * 50}');
    print('三棵树检查');
    print('=' * 50);

    // 1. Widget（通过context可以访问）
    print('\n📦 Widget信息:');
    print('   类型: ${context.widget.runtimeType}');
    print('   hashCode: ${context.widget.hashCode}');

    // 2. Element（BuildContext就是Element）
    final element = context as Element;
    print('\n🔗 Element信息:');
    print('   类型: ${element.runtimeType}');
    print('   hashCode: ${element.hashCode}');
    print('   深度: ${element.depth}');
    print('   是否mounted: ${element.mounted}');

    // 3. RenderObject（如果有）
    final renderObject = context.findRenderObject();
    print('\n🎨 RenderObject信息:');
    if (renderObject != null) {
      print('   类型: ${renderObject.runtimeType}');
      print('   hashCode: ${renderObject.hashCode}');

      if (renderObject is RenderBox) {
        print('   大小: ${renderObject.size}');
        print('   约束: ${renderObject.constraints}');
        print('   是否需要布局: ${renderObject.debugNeedsLayout}');
        print('   是否需要绘制: ${renderObject.debugNeedsPaint}');
      }
    } else {
      print('   null (这个Widget没有对应的RenderObject)');
    }

    // 4. 遍历Widget树
    print('\n🌳 Widget树结构:');
    _printWidgetTree(context, 0);

    print('\n${'=' * 50}\n');
  }

  void _printWidgetTree(BuildContext context, int depth) {
    final indent = '  ' * depth;
    print('$indent└─ ${context.widget.runtimeType}');

    // 只遍历前3层，避免输出太多
    if (depth < 3) {
      context.visitChildElements((child) {
        _printWidgetTree(child, depth + 1);
      });
    }
  }
}

/// 自定义Widget示例 - 展示Widget的不可变性
class ImmutableWidgetExample extends StatelessWidget {
  final String title;
  final int value;

  // 所有字段都是final - 不可变
  const ImmutableWidgetExample({
    Key? key,
    required this.title,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Value: $value', style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

/// Key的使用示例
class KeyExample extends StatefulWidget {
  const KeyExample({Key? key}) : super(key: key);

  @override
  State<KeyExample> createState() => _KeyExampleState();
}

class _KeyExampleState extends State<KeyExample> {
  List<String> items = ['Item 1', 'Item 2', 'Item 3'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('列表项（使用Key）:'),
        ...items.map(
          (item) => ListTile(
            key: ValueKey(item), // 使用Key确保Element正确复用
            title: Text(item),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                setState(() {
                  items.remove(item);
                });
              },
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              items.shuffle(); // 打乱顺序
            });
          },
          child: const Text('打乱顺序'),
        ),
      ],
    );
  }
}
