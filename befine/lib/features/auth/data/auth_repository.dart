import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/app_user.dart';
import '../../../../core/error/exceptions.dart' hide AuthException;

class AuthRepository {
  final SupabaseClient _supabase;

  AuthRepository(this._supabase);

  // Get current user from the session and DB
  Future<AppUser?> getCurrentUser() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final response = await _supabase
          .from('users')
          .select()
          .eq('id', user.id)
          .single();

      return AppUser.fromJson(response);
    } catch (e) {
      throw ServerException('Failed to get user profile: $e');
    }
  }

  Future<AppUser> signIn(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw AuthException('Login failed: user is null');
      }

      final profileResponse = await _supabase
          .from('users')
          .select()
          .eq('id', response.user!.id)
          .single();

      return AppUser.fromJson(profileResponse);
    } on AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw ServerException('Failed to sign in: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw ServerException('Failed to sign out: $e');
    }
  }
}
