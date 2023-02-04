import 'package:bishop/bishop.dart';

part 'promo_adapters.dart';
part 'type_adapter.dart';

class BishopSerialisation {
  static List<BishopTypeAdapter> get baseAdapters {
    _baseAdapters ??= [
      ...basePromoAdapters,
    ];
    return _baseAdapters!;
  }

  static List<BishopTypeAdapter>? _baseAdapters;

  static List<BishopTypeAdapter> get basePromoAdapters => [
        NoPromotionAdapter(),
        StandardPromotionAdapter(),
        OptionalPromotionAdapter(),
      ];

  static List<T> buildMany<T>({
    required List input,
    List<BishopTypeAdapter> adapters = const [],
    bool strict = true,
  }) =>
      input
          .map((e) => build<T>(input: e, adapters: adapters, strict: strict))
          .where((e) => e != null)
          .map((e) => e as T)
          .toList();

  static T? build<T>({
    List<BishopTypeAdapter> adapters = const [],
    dynamic input,
    bool strict = true,
  }) {
    adapters = [...baseAdapters, ...adapters];
    String? id;
    Map<String, dynamic>? params;
    if (input is String) id = input;
    if (input is Map<String, dynamic>) {
      id = input['id'];
      params = input;
    }
    if (id == null) {
      throw BishopException('Invalid adapter ($input)');
    }
    final adapter = adapters.firstWhereOrNull((e) => e.id == id);
    if (adapter == null) {
      if (strict) {
        throw BishopException('Adapter not found ($id)');
      }
      return null;
    }
    final object = adapter.build(params);
    if (object is! T) {
      if (strict) {
        throw BishopException('Adapter ($id) of invalid type (not $T)');
      }
      return null;
    }
    return object;
  }

  static List exportMany<T>({
    required List<T> objects,
    List<BishopTypeAdapter> adapters = const [],
    bool strict = true,
  }) =>
      objects
          .map((e) => export<T>(object: e, adapters: adapters, strict: strict))
          .where((e) => e != null)
          .toList();

  static dynamic export<T>({
    required T object,
    List<BishopTypeAdapter> adapters = const [],
    bool strict = true,
  }) {
    adapters = [...baseAdapters, ...adapters];
    final adapter =
        adapters.firstWhereOrNull((e) => e.type == object.runtimeType);
    if (adapter == null) {
      if (strict) {
        throw BishopException('Adapter not found (${object.runtimeType})');
      }
      return null;
    }
    final params = adapter.export(object);
    if (params == null || params.isEmpty) {
      return adapter.id;
    }
    return {
      'id': adapter.id,
      ...params,
    };
  }
}
