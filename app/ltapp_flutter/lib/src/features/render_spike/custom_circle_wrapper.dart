import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class CustomCircleWrapper extends SingleChildRenderObjectWidget {
  final double radius;
  final Color color;

  const CustomCircleWrapper({
    super.key,
    required this.radius,
    required this.color,
    super.child,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderCustomCircle(radius: radius, color: color);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderObject renderObject,
  ) {
    // TODO: implement updateRenderObject
    super.updateRenderObject(context, renderObject);
  }
}

class RenderCustomCircle extends RenderBox
    with RenderObjectWithChildMixin<RenderBox> {
  double _radius;
  Color _color;

  RenderCustomCircle({required double radius, required Color color})
    : _radius = radius,
      _color = color;

  set radius(double value) {
    if (_radius == value) return;
    _radius = value;
    markNeedsLayout();
  }

  set color(Color value) {
    if (_color == value) return;
    _color = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    final double diameter = _radius * 2;
    size = constraints.constrain(Size(diameter, diameter));
    if (child != null) {
      child!.layout(constraints.loosen(), parentUsesSize: true);
      final BoxParentData childParentData = child!.parentData as BoxParentData;
      childParentData.offset = Offset(
        (size.width - child!.size.width) / 2,
        (size.height - child!.size.height) / 2,
      );
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Paint paint = Paint()
      ..color = _color
      ..style = PaintingStyle.fill;

    final Offset center = offset + Offset(size.width / 2, size.height / 2);
    context.canvas.drawCircle(center, _radius, paint);

    if (child != null) {
      final BoxParentData childParentData = child!.parentData as BoxParentData;
      context.paintChild(child!, offset + childParentData.offset);
    }
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (!size.contains(position)) {
      return false;
    }

    final Offset center = Offset(size.width / 2, size.height / 2);
    final double distance = (position - center).distance;

    if (distance > _radius) {
      return false;
    }
    if (child != null) {
      final BoxParentData childParentData = child!.parentData as BoxParentData;
      final bool isChildHit = result.addWithPaintOffset(
        offset: childParentData.offset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          return child!.hitTest(result, position: position);
        },
      );
      if (isChildHit) {
        return true;
      }
    }
    result.add(BoxHitTestEntry(this, position));
    return true;
  }
}

class DemoPage extends StatelessWidget {
  const DemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("RenderObject Demo")),
      body: Center(
        child: Column(
          children: [
            const Text("Custom circle with RenderObject"),
            const SizedBox(height: 20),
            CustomCircleWrapper(
              radius: 80,
              color: Colors.blue.withOpacity(0.2),
              child: const Icon(Icons.star, size: 50, color: Colors.orange),
            ),
          ],
        ),
      ),
    );
  }
}
