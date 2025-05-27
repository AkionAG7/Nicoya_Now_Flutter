import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get_it/get_it.dart';
import 'package:nicoya_now/app/features/products/data/datasources/products_data_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nicoya_now/app/features/products/domain/entities/products.dart';

class EditProductPage extends StatefulWidget {
  final Product product;

  const EditProductPage({Key? key, required this.product}) : super(key: key);

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _priceCtrl;

  String? _categoriaId;
  PlatformFile? _newImage;
  bool _loading = false;

  final supabase = Supabase.instance.client;
  final ProductsDataSource productsDataSource = GetIt.I<ProductsDataSource>();
  List<Map<String, dynamic>> _categorias = [];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.product.name);
    _descCtrl = TextEditingController(text: widget.product.description);
    _priceCtrl = TextEditingController(text: widget.product.price.toString());
    _categoriaId = widget.product.category_id;
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
      setState(() => _newImage = res.files.first);
    }
  }

 Future<void> _actualizarProducto() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _loading = true);
  String imageUrl = widget.product.image_url ?? '';

  try {
    if (_newImage != null) {
      final imagePath = 'merchant-assets/${widget.product.merchant_id}/${widget.product.product_id}-${_newImage!.name}';
      await supabase.storage
          .from('merchant-assets')
          .upload(imagePath, File(_newImage!.path!), fileOptions: const FileOptions(upsert: true));
      imageUrl = supabase.storage.from('merchant-assets').getPublicUrl(imagePath);
    }

    final updatedProduct = Product(
      product_id: widget.product.product_id,
      merchant_id: widget.product.merchant_id,
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      price: double.parse(_priceCtrl.text),
      image_url: imageUrl,
      is_activate: true,
      created_at: widget.product.created_at,
      category_id: _categoriaId!,
    );

    await productsDataSource.updateProduct(updatedProduct);

    if (!mounted) return;

    Navigator.pop(context); // ✅ Cierra la pantalla correctamente
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Producto actualizado exitosamente')),
    );
  } catch (e) {
    print('Error al actualizar producto: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar: $e')),
      );
    }
  } finally {
    if (mounted) {
      setState(() => _loading = false);
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Producto')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildField(_nameCtrl, 'Nombre del producto'),
              const SizedBox(height: 10),
              _buildField(_descCtrl, 'Descripción'),
              const SizedBox(height: 10),
              _buildField(_priceCtrl, 'Precio', keyboardType: TextInputType.number),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _categoriaId,
                items: _categorias.map((cat) {
                  return DropdownMenuItem<String>(
                    value: cat['category_id'],
                    child: Text(cat['name']),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _categoriaId = v),
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _seleccionarImagen,
                child: Text(_newImage != null ? _newImage!.name : 'Cambiar imagen'),
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
                      onPressed: _loading ? null : _actualizarProducto,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xffd72a23)),
                      child: _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Actualizar', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, {TextInputType? keyboardType}) {
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
