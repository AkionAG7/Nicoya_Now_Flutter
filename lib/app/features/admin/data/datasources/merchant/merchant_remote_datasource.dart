import '../../models/merchant_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Abstract class for merchant remote data source
abstract class MerchantRemoteDataSource {
  /// Get all merchants from the remote source
  Future<List<MerchantModel>> getAllMerchants();

  /// Get a merchant by ID from the remote source
  Future<MerchantModel> getMerchantById(String merchantId);

  /// Set a merchant's verification status to true
  Future<MerchantModel> approveMerchant(String merchantId);

  /// Set a merchant's verification status to false
  Future<MerchantModel> rejectMerchant(String merchantId);

  /// Create a new merchant in the remote source
  Future<MerchantModel> createMerchant(MerchantModel merchant);

  /// Update an existing merchant in the remote source
  Future<MerchantModel> updateMerchant(MerchantModel merchant);

  /// Delete a merchant from the remote source
  Future<bool> deleteMerchant(String merchantId);
}

/// Implementation of [MerchantRemoteDataSource] that uses Supabase
class MerchantRemoteDataSourceImpl implements MerchantRemoteDataSource {
  final SupabaseClient supabase;

  MerchantRemoteDataSourceImpl({required this.supabase});
  @override
  Future<List<MerchantModel>> getAllMerchants() async {
    try {
      //ignore: avoid_print
      print('MerchantRemoteDataSourceImpl: Fetching merchants from Supabase');
      final response = await supabase.from('merchant').select('*');
      //ignore: avoid_print
      print('MerchantRemoteDataSourceImpl: Raw Supabase response: $response');
      // Response cannot be null in modern Dart

      final merchants = <MerchantModel>[];
      for (var item in response) {
        try {
          //ignore: avoid_print
          print(
            'MerchantRemoteDataSourceImpl: Converting JSON to model: $item',
          );

          // Print each field to debug
          //ignore: avoid_print
          print('merchant_id: ${item['merchant_id']}');
          //ignore: avoid_print
          print('business_name: ${item['business_name']}');
          //ignore: avoid_print
          print('business_category: ${item['business_category']}');
          //ignore: avoid_print
          print('created_at: ${item['created_at']}');
          //ignore: avoid_print
          print('is_active: ${item['is_active']}');

          final merchant = MerchantModel.fromJson(item);
          //ignore: avoid_print
          print('MerchantModel created with ID: ${merchant.merchantId}');
          merchants.add(merchant);
        } catch (e) {
          //ignore: avoid_print
          print(
            'MerchantRemoteDataSourceImpl: Error converting JSON to model: $e',
          );
          // Continue instead of throwing to process as many records as possible
          //ignore: avoid_print
          print('Skipping record due to error');
        }
      }
      //ignore: avoid_print
      print(
        'MerchantRemoteDataSourceImpl: Returning ${merchants.length} merchant models',
      );
      return merchants;
    } catch (e) {
      //ignore: avoid_print
      print('MerchantRemoteDataSourceImpl: Error getting merchants: $e');
      throw Exception('Failed to get merchants: $e');
    }
  }

  @override
  Future<MerchantModel> getMerchantById(String merchantId) async {
    try {
      final response =
          await supabase
              .from('merchant')
              .select('*')
              .eq('merchant_id', merchantId)
              .single();
      return MerchantModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get merchant: $e');
    }
  }

  @override
  Future<MerchantModel> approveMerchant(String merchantId) async {
    try {
      //ignore: avoid_print
      print('DataSource: Starting approval for merchant ID: $merchantId');

      // Direct table update - RLS policies will handle permissions
      final response =
          await supabase
              .from('merchant')
              .update({'is_active': true})
              .eq('merchant_id', merchantId)
              .select('*')
              .single();
      //ignore: avoid_print
      print('DataSource: Supabase response: $response');

      final approvedMerchant = MerchantModel.fromJson(response);
      //ignore: avoid_print
      print(
        'DataSource: Approval successful for merchant: ${approvedMerchant.businessName}',
      );
      //ignore: avoid_print
      print(
        'DataSource: Merchant isVerified status: ${approvedMerchant.isVerified}',
      );

      return approvedMerchant;
    } catch (e) {
      //ignore: avoid_print
      print('DataSource: Error approving merchant: $e');
      if (e is PostgrestException) {
        //ignore: avoid_print
        print('DataSource: PostgrestException details:');
        //ignore: avoid_print
        print('  Code: ${e.code}');
        //ignore: avoid_print
        print('  Message: ${e.message}');
        //ignore: avoid_print
        print('  Details: ${e.details}');
        //ignore: avoid_print
        print('  Hint: ${e.hint}');
      }
      throw Exception('Failed to approve merchant: $e');
    }
  }

  @override
  Future<MerchantModel> rejectMerchant(String merchantId) async {
    try {
      //ignore: avoid_print
      print('DataSource: Starting rejection for merchant ID: $merchantId');

      // Direct table update - RLS policies will handle permissions
      final response =
          await supabase
              .from('merchant')
              .update({'is_active': false})
              .eq('merchant_id', merchantId)
              .select('*')
              .single();
//ignore: avoid_print
      print('DataSource: Supabase response for rejection: $response');

      final rejectedMerchant = MerchantModel.fromJson(response);
      //ignore: avoid_print
      print(
        'DataSource: Rejection successful for merchant: ${rejectedMerchant.businessName}',
      );

      return rejectedMerchant;
    } catch (e) {
      //ignore: avoid_print
      print('DataSource: Error rejecting merchant: $e');
      if (e is PostgrestException) {
        //ignore: avoid_print
        print('DataSource: PostgrestException details:');
        //ignore: avoid_print
        print('  Code: ${e.code}');
        //ignore: avoid_print
        print('  Message: ${e.message}');
        //ignore: avoid_print
        print('  Details: ${e.details}');
        //ignore: avoid_print
        print('  Hint: ${e.hint}');
      }
      throw Exception('Failed to reject merchant: $e');
    }
  }

  @override
  Future<MerchantModel> createMerchant(MerchantModel merchant) async {
    try {
      final response =
          await supabase
              .from('merchant')
              .insert(merchant.toJson())
              .select()
              .single();
      return MerchantModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create merchant: $e');
    }
  }

  @override
  Future<MerchantModel> updateMerchant(MerchantModel merchant) async {
    try {
      final response =
          await supabase
              .from('merchant')
              .update(merchant.toJson())
              .eq('merchant_id', merchant.merchantId)
              .select()
              .single();
      return MerchantModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update merchant: $e');
    }
  }

  @override
  Future<bool> deleteMerchant(String merchantId) async {
    try {
      await supabase.from('merchant').delete().eq('merchant_id', merchantId);
      return true;
    } catch (e) {
      throw Exception('Failed to delete merchant: $e');
    }
  }
}
