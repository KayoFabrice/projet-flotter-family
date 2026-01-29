import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projet_flutter_famille/features/settings/domain/key_location.dart';
import 'package:projet_flutter_famille/features/settings/presentation/pages/location_or_availability_page.dart';
import 'package:projet_flutter_famille/features/settings/presentation/providers/key_location_provider.dart';

void main() {
  testWidgets('LocationOrAvailabilityPage shows CTAs and explainer', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          keyLocationProvider.overrideWith(FakeKeyLocationNotifier.new),
        ],
        child: const MaterialApp(
          home: LocationOrAvailabilityPage(),
        ),
      ),
    );

    expect(find.text('Le bon moment, au bon endroit'), findsOneWidget);
    expect(find.text('Activer la localisation'), findsOneWidget);
    expect(find.text('Choisir des horaires fixes'), findsOneWidget);
  });
}

class FakeKeyLocationNotifier extends KeyLocationNotifier {
  @override
  Future<KeyLocation> build() async {
    return KeyLocation.defaultLocation;
  }
}
