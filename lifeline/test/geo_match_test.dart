import 'package:flutter_test/flutter_test.dart';
import 'package:lifeline/services/geo_data_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final geo = GeoDataService.instance;

  setUpAll(() async {
    await geo.init();
  });

  test('State matching supports Lagos with or without suffix', () {
    final lagos = geo.matchStateByName('Lagos');
    expect(lagos, isNotNull);
    expect(lagos!.displayName, 'Lagos State');

    final lagosWithSuffix = geo.matchStateByName('Lagos State');
    expect(lagosWithSuffix, isNotNull);
    expect(lagosWithSuffix!.displayName, 'Lagos State');
  });

  test('State matching supports FCT aliases', () {
    final fct = geo.matchStateByName('Federal Capital Territory');
    final fctAlias = geo.matchStateByName('FCT');

    expect(fct, isNotNull);
    expect(fctAlias, isNotNull);
    expect(fct!.id, fctAlias!.id);
  });

  test('LGA matching works for Municipal Area Council', () {
    final fct = geo.matchStateByName('FCT');
    expect(fct, isNotNull);

    final lga = geo.matchLgaByName(fct!.id, 'Municipal Area Council');
    expect(lga, isNotNull);
    expect(lga!.name, 'Municipal Area Council');
  });
}
