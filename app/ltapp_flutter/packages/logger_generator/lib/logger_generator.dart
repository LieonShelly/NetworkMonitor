import 'package:analyzer/dart/element/element2.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:logger_annotation/logger.dart';

Builder loggerBuilder(BuilderOptions options) {
  return SharedPartBuilder([LogGenerator()], 'logger_generator');
}

class LogGenerator extends GeneratorForAnnotation<Log> {
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
