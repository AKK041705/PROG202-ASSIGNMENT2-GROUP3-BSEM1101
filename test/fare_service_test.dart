import 'package:flutter_test/flutter_test.dart';

import 'package:salone_transport_hub/data/fare_service.dart';
import 'package:salone_transport_hub/data/tariff_data.dart';

void main() {
  final tariffs = TariffData.seed();

  test('custom destination adds the default distance to its route point', () {
    final quote = FareService.quote(
      tariffs,
      'Kekeh',
      'Imatt',
      'Waterloo extension',
      destinationAnchor: 'Waterloo',
    );

    expect(quote.distanceKm, 34);
    expect(quote.amount, 49);
    expect(quote.source, 'Simulated estimate');
  });

  test(
      'custom destination uses a distance estimate instead of a listed route fare',
      () {
    final quote = FareService.quote(
      tariffs,
      'Kekeh',
      'Lumley',
      'Off Wilberforce',
      destinationAnchor: 'Wilberforce',
    );

    expect(quote.distanceKm, 6);
    expect(quote.amount, 13);
  });

  test('custom pickup and destination each add the default distance', () {
    final quote = FareService.quote(
      tariffs,
      'Taxi (shared)',
      'Custom pickup',
      'Custom destination',
      pickupAnchor: 'Imatt',
      destinationAnchor: 'Waterloo',
    );

    expect(quote.distanceKm, 37);
  });
}
