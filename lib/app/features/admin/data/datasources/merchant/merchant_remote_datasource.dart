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
      print('MerchantRemoteDataSourceImpl: Fetching merchants from Supabase');
      final response = await supabase.from('merchant').select('*');
      print('MerchantRemoteDataSourceImpl: Raw Supabase response: $response');
        // Response cannot be null in modern Dart
      
      if (response is! List) {
        print('MerchantRemoteDataSourceImpl: Response is not a List, type: ${response.runtimeType}');
        return [];
      }
        final merchants = <MerchantModel>[];
      for (var item in response) {
        try {
          print('MerchantRemoteDataSourceImpl: Converting JSON to model: $item');
          
          // Print each field to debug
          print('merchant_id: ${item['merchant_id']}');
          print('business_name: ${item['business_name']}');
          print('business_category: ${item['business_category']}');
          print('created_at: ${item['created_at']}');
          print('is_verified: ${item['is_verified']}');
          
          merchants.add(MerchantModel.fromJson(item));
        } catch (e) {
          print('MerchantRemoteDataSourceImpl: Error converting JSON to model: $e');
          // Continue instead of throwing to process as many records as possible
          print('Skipping record due to error');
        }
      }
      
      print('MerchantRemoteDataSourceImpl: Returning ${merchants.length} merchant models');
      return merchants;
    } catch (e) {
      print('MerchantRemoteDataSourceImpl: Error getting merchants: $e');
      throw Exception('Failed to get merchants: $e');
    }
  }
  
  @override
  Future<MerchantModel> getMerchantById(String merchantId) async {
    try {
      final response = await supabase
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
      final response = await supabase
          .from('merchant')
          .update({'is_verified': true})
          .eq('merchant_id', merchantId)
          .select()
          .single();
      return MerchantModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to approve merchant: $e');
    }
  }
  
  @override
  Future<MerchantModel> rejectMerchant(String merchantId) async {
    try {
      final response = await supabase
          .from('merchant')
          .update({'is_verified': false})
          .eq('merchant_id', merchantId)
          .select()
          .single();
      return MerchantModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to reject merchant: $e');
    }
  }
  
  @override
  Future<MerchantModel> createMerchant(MerchantModel merchant) async {
    try {
      final response = await supabase
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
      final response = await supabase
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
      await supabase
          .from('merchant')
          .delete()
          .eq('merchant_id', merchantId);
      return true;
    } catch (e) {
      throw Exception('Failed to delete merchant: $e');
    }
  }
}
