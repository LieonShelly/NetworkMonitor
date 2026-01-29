import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:lt_annotation/ltdeserialization.dart';

Builder jsonDeserializationBuilder(BuilderOptions options) {
  return SharedPartBuilder([
    LtDeserializationGenerator(),
  ], 'json_model_generator');
}

class LtDeserializationGenerator
    extends GeneratorForAnnotation<LtDeserialization> {
  static const _jsonKeyChecker = TypeChecker.typeNamed(JsonKey);
  @override
  generateForAnnotatedElement(
    Element2 element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement2) {
      throw InvalidGenerationSourceError(
        "@LtJsonSerialization can only be appied to classes",
      );
    }
    final className = element.displayName;
    final buffer = StringBuffer();
    buffer.writeln(
      '$className _\$${className}FromJson(Map<String, dynamic> json) {',
    );
    buffer.writeln('  return $className(');
    for (var field in element.fields2) {
      if (field.isStatic) continue;

      final fieldName = field.displayName;
      final fieldType = field.type;
      final jsonKey =
          _getJsonKeyFromAnnotatiin(field) ?? _camelToSnake(fieldName);

      buffer.writeln(
        " $fieldName: ${_generateDeserialization(fieldType, jsonKey)},",
      );
    }

    buffer.writeln("  );");
    buffer.writeln("}");
    return buffer.toString();
  }

  String _generateDeserialization(DartType type, String jsonKey) {
    if (type.isDartCoreList) {
      final geneicType = (type as InterfaceType).typeArguments.first;
      return "(json['$jsonKey'] as List).map((e) => ${geneicType.element3!.name3}.fromJson(e)).toList()";
    }
    if (type.isDartCoreString ||
        type.isDartCoreInt ||
        type.isDartCoreDouble ||
        type.isDartCoreBool) {
      return "json['$jsonKey'] as ${type.getDisplayString()}";
    }
    final typeName = type.element3!.name3;
    if (type.nullabilitySuffix == NullabilitySuffix.question) {
      return "json['$jsonKey'] == null ? null : $typeName.fromJson(json['$jsonKey'])";
    } else {
      return "$typeName.fromJson(json['$jsonKey'])";
    }
  }

  String _camelToSnake(String input) {
    return input.replaceAllMapped(RegExp(r'[A-Z]'), (match) {
      return '_${match.group(0)!.toLowerCase()}';
    });
  }

  String? _getJsonKeyFromAnnotatiin(FieldElement2 field) {
    for (final metadata in field.metadata2.annotations) {
      final DartObject? object = metadata.computeConstantValue();
      if (object != null && _jsonKeyChecker.isExactlyType(object.type!)) {
        return ConstantReader(object).read('name').stringValue;
      }
    }
    return null;
  }
}
