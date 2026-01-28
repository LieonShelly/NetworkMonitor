import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/element2.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:logger_annotation/logger.dart';

class MyLogGenerator extends GeneratorForAnnotation<MyLog> {
  @override
  generateForAnnotatedElement(
    Element2 element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    final className = element.displayName;
    final prefix = annotation.read('prefix').stringValue;
    return '''
      void print${className}Log() {
        print("[$prefix] This is class $className");
      }
    ''';
  }
}
