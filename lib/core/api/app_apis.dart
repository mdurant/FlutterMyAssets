import 'api_client.dart';
import 'auth_api.dart';
import 'terms_api.dart';
import 'properties_api.dart';
import 'favorites_api.dart';
import 'reviews_api.dart';
import 'conversations_api.dart';
import 'notifications_api.dart';
import 'bookings_api.dart';
import 'regions_api.dart';

/// Contenedor de todas las APIs de la app (para inyección en PostLoginGate / MainAppShell).
class AppApis {
  AppApis(this.client);

  final ApiClient client;

  late final AuthApi auth = AuthApi(client);
  late final TermsApi terms = TermsApi(client);
  late final PropertiesApi properties = PropertiesApi(client);
  late final FavoritesApi favorites = FavoritesApi(client);
  late final ReviewsApi reviews = ReviewsApi(client);
  late final ConversationsApi conversations = ConversationsApi(client);
  late final NotificationsApi notifications = NotificationsApi(client);
  late final BookingsApi bookings = BookingsApi(client);
  late final RegionsApi regions = RegionsApi(client);
}
