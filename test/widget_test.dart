import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:miraiku/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';


class MockSupabase extends Mock implements Supabase {}
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}

void main() {
  setUpAll(() async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
    
    // Mock Supabase
    final mockSupabase = MockSupabase();
    final mockClient = MockSupabaseClient();
    final mockAuth = MockGoTrueClient();
    
    when(() => mockSupabase.client).thenReturn(mockClient);
    when(() => mockClient.auth).thenReturn(mockAuth);
    // Use an empty stream instead of throwing
    when(() => mockAuth.onAuthStateChange).thenAnswer((_) => const Stream.empty());
    
    // We can't easily mock the static Supabase.instance without a wrapper or using a package like get_it,
    // but we can try to initialize it with dummy values if possible, 
    // or we modify the app to allow dependency injection.
    // For now, let's try to initialize it with dummy values since it's a singleton.
    try {
      await Supabase.initialize(
        url: 'https://placeholder.supabase.co',
        anonKey: 'placeholder',
      );
    } catch (e) {
      // Already initialized or failed
    }
  });

  testWidgets('App renders without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // We use a simplified version or the real app if initialization permits
    await tester.pumpWidget(const MiraikuApp());

    // Basic check to see if the app started (should show AuthScreen or Loading)
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
