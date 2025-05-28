import '../models/merchant_model.dart';

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
  final dynamic supabase; // Replace with actual Supabase client type
  
  MerchantRemoteDataSourceImpl({required this.supabase});
  
  @override
  Future<List<MerchantModel>> getAllMerchants() async {
    try {
      final response = await supabase.from('merchant').select('*');
      return (response as List).map((json) => MerchantModel.fromJson(json)).toList();
    } catch (e) {
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
