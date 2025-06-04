import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:nicoya_now/app/features/products/domain/entities/products.dart';
import 'package:nicoya_now/app/features/products/data/datasources/products_data_source.dart';

class AddProductPage extends StatefulWidget {
  final String merchantId;
  const AddProductPage({super.key, required this.merchantId});

  @override
  State<AddProductPage> createState() => _AgregarProductoPageState();
}

class _AgregarProductoPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();
  String? _categoriaId;
  PlatformFile? _imagen;
  bool _loading = false;

  final supabase = Supabase.instance.client;
  final ProductsDataSource productsDataSource = GetIt.I<ProductsDataSource>();

  List<Map<String, dynamic>> _categorias = [];

  @override
  void initState() {
    super.initState();
    _loadCategorias();
  }

  Future<void> _loadCategorias() async {
    final data = await supabase.from('category').select('category_id, name');
    setState(() {
      _categorias = List<Map<String, dynamic>>.from(data);
    });
  }

  Future<void> _seleccionarImagen() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (res != null && res.files.isNotEmpty) {
      setState(() => _imagen = res.files.first);
    }
  }

  Future<void> _guardarProducto() async {
    if (!_formKey.currentState!.validate() ||
        _categoriaId == null ||
        _imagen == null) {
      return;
    }

    setState(() => _loading = true);

    try {
      final uuid = const Uuid().v4();
      final imagePath =
          'merchant-assets/${widget.merchantId}/$uuid-${_imagen!.name}';

      await supabase.storage
          .from('merchant-assets')
          .upload(
            imagePath,
            File(_imagen!.path!),
            fileOptions: const FileOptions(upsert: true),
          );

      final imageUrl = supabase.storage
          .from('merchant-assets')
          .getPublicUrl(imagePath);

      final product = Product(
        product_id: uuid,
        merchant_id: widget.merchantId,
        name: _nombreCtrl.text.trim(),
        description: _descripcionCtrl.text.trim(),
        price: double.parse(_precioCtrl.text),
        image_url: imageUrl,
        is_activate: true,
        created_at: DateTime.now(),
        category_id: _categoriaId!,
      );

      await productsDataSource.addProduct(product);

      if (mounted) Navigator.pop(context);
    } catch (e) {
      //ignore: avoid_print
      print('Error al guardar producto: $e');
      ScaffoldMessenger.of(
        //ignore: use_build_context_synchronously
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar Producto')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(_nombreCtrl, 'Nombre del producto'),
              const SizedBox(height: 10),
              _buildTextField(_descripcionCtrl, 'Descripción'),
              const SizedBox(height: 10),
              _buildTextField(
                _precioCtrl,
                'Precio',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _categoriaId,
                items:
                    _categorias
                        .map(
                          (cat) => DropdownMenuItem<String>(
                            value: cat['category_id'].toString(),
                            child: Text(cat['name'].toString()),
                          ),
                        )
                        .toList(),
                onChanged: (v) => setState(() => _categoriaId = v),
                decoration: const InputDecoration(
                  labelText: 'Categoría de producto',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _seleccionarImagen,
                child: Text(
                  _imagen != null ? _imagen!.name : 'Seleccionar imagen',
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _loading ? null : _guardarProducto,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffd72a23),
                      ),
                      child:
                          _loading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Text(
                                'Confirmar',
                                style: TextStyle(color: Colors.white),
                              ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: (val) => val == null || val.isEmpty ? 'Campo requerido' : null,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
