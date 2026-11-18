// lib/screens/admin/add_edit_product_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../services/admin_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

class AddEditProductScreen extends StatefulWidget {
  final Product? product; // null if adding new product

  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey      = GlobalKey<FormState>();
  final _nameCtrl     = TextEditingController();
  final _descCtrl     = TextEditingController();
  final _priceCtrl    = TextEditingController();
  final _discCtrl     = TextEditingController();
  final _stockCtrl    = TextEditingController();
  final _imageCtrl    = TextEditingController();

  final _adminSvc     = AdminService();
  final _picker       = ImagePicker();

  String?    _selectedCategoryId;
  String     _selectedUnit = 'piece';
  bool       _isFeatured   = false;
  bool       _isActive     = true;
  bool       _isSaving     = false;

  Uint8List? _pickedImageBytes;
  String?    _pickedImageName;

  final List<String> _units = [
    'piece',
    'kg',
    'gram',
    'litre',
    'ml',
    'dozen',
    'pack',
    'bundle',
  ];

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final p = widget.product!;
      _nameCtrl.text       = p.name;
      _descCtrl.text       = p.description;
      _priceCtrl.text      = p.price.toStringAsFixed(0);
      _discCtrl.text       = p.discountPrice?.toStringAsFixed(0) ?? '';
      _stockCtrl.text      = p.stock.toString();
      _imageCtrl.text      = p.imageUrl;
      _selectedCategoryId = p.categoryId;
      _selectedUnit        = _units.contains(p.unit) ? p.unit : 'piece';
      _isFeatured          = p.isFeatured;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _discCtrl.dispose();
    _stockCtrl.dispose();
    _imageCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source:       source,
        imageQuality: 85,
        maxWidth:     1024,
      );
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      setState(() {
        _pickedImageBytes = bytes;
        _pickedImageName  = picked.name;
      });
    } catch (e) {
      if (!mounted) return;
      Helpers.showSnack(context, 'Failed to pick image: $e', error: true);
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Product Photo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppTheme.primaryLight,
                  child: Icon(Icons.photo_library, color: Colors.white),
                ),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppTheme.primary,
                  child: Icon(Icons.camera_alt, color: Colors.white),
                ),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategoryId == null || _selectedCategoryId!.isEmpty) {
      Helpers.showSnack(context, 'Please select a product category', error: true);
      return;
    }

    if (_pickedImageBytes == null && _imageCtrl.text.trim().isEmpty) {
      Helpers.showSnack(context, 'Please upload an image or provide an image URL', error: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      String finalImageUrl = _imageCtrl.text.trim();

      // 1. Upload local image if picked
      if (_pickedImageBytes != null) {
        finalImageUrl = await _adminSvc.uploadProductImage(
          bytes:    _pickedImageBytes!,
          fileName: _pickedImageName ?? 'item.jpg',
        );
      }

      final price         = double.parse(_priceCtrl.text.trim());
      final discountPrice = _discCtrl.text.trim().isNotEmpty
          ? double.parse(_discCtrl.text.trim())
          : null;
      final stock         = int.tryParse(_stockCtrl.text.trim()) ?? 0;

      if (_isEditing) {
        await _adminSvc.updateProduct(
          id:            widget.product!.id,
          name:          _nameCtrl.text.trim(),
          description:   _descCtrl.text.trim(),
          price:         price,
          discountPrice: discountPrice,
          imageUrl:      finalImageUrl,
          categoryId:    _selectedCategoryId!,
          stock:         stock,
          unit:          _selectedUnit,
          isFeatured:    _isFeatured,
          isActive:      _isActive,
        );
      } else {
        await _adminSvc.createProduct(
          name:          _nameCtrl.text.trim(),
          description:   _descCtrl.text.trim(),
          price:         price,
          discountPrice: discountPrice,
          imageUrl:      finalImageUrl,
          categoryId:    _selectedCategoryId!,
          stock:         stock,
          unit:          _selectedUnit,
          isFeatured:    _isFeatured,
        );
      }

      // Immediately refresh ProductProvider so customer dashboard updates live
      if (mounted) {
        await context.read<ProductProvider>().refresh();
      }

      if (!mounted) return;
      Helpers.showSnack(
        context,
        _isEditing
            ? 'Grocery item updated successfully!'
            : 'New grocery item added to store!',
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      Helpers.showSnack(context, 'Error saving product: $e', error: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<ProductProvider>().categories;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Grocery Item' : 'Add New Grocery Item'),
        actions: [
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check_rounded, size: 28),
              tooltip: 'Save Item',
              onPressed: _saveProduct,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Image preview & picker ─────────────────────
            _buildImagePickerCard(),
            const SizedBox(height: 16),

            // ── Basic Info Card ────────────────────────────
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Basic Information',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 14),

                    // Product Name
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Item Name *',
                        hintText:  'e.g. Fresh Red Tomatoes',
                        prefixIcon: Icon(Icons.shopping_bag_outlined),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Please enter product name'
                          : null,
                    ),
                    const SizedBox(height: 14),

                    // Category Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedCategoryId,
                      decoration: const InputDecoration(
                        labelText: 'Category *',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: categories
                          .map((c) => DropdownMenuItem(
                                value: c.id,
                                child: Text(c.name),
                              ))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedCategoryId = val),
                      validator: (v) => v == null ? 'Please select category' : null,
                    ),
                    const SizedBox(height: 14),

                    // Description
                    TextFormField(
                      controller: _descCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Fresh, organic produce from local farms...',
                        prefixIcon: Icon(Icons.notes_outlined),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Pricing & Stock Card ───────────────────────
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pricing & Inventory',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 14),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Price
                        Expanded(
                          child: TextFormField(
                            controller: _priceCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: InputDecoration(
                              labelText: 'Price (${AppText.currencySymbol}) *',
                              prefixText: '${AppText.currencySymbol} ',
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Required'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Discount Price
                        Expanded(
                          child: TextFormField(
                            controller: _discCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: InputDecoration(
                              labelText: 'Discount (${AppText.currencySymbol})',
                              prefixText: '${AppText.currencySymbol} ',
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Stock
                        Expanded(
                          child: TextFormField(
                            controller: _stockCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: const InputDecoration(
                              labelText: 'Stock Qty *',
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Required'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Unit
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedUnit,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Unit *',
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                            ),
                            items: _units
                                .map((u) => DropdownMenuItem(
                                      value: u,
                                      child: Text(u, overflow: TextOverflow.ellipsis),
                                    ))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedUnit = val);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Visibility & Featured Options ──────────────
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Featured Grocery Item'),
                    subtitle: const Text('Highlight in customer dashboard banner carousel'),
                    activeColor: AppTheme.primary,
                    value: _isFeatured,
                    onChanged: (val) => setState(() => _isFeatured = val),
                  ),
                  if (_isEditing)
                    SwitchListTile(
                      title: const Text('Active in Store'),
                      subtitle: const Text('Disable to temporarily hide from customer search'),
                      activeColor: AppTheme.primary,
                      value: _isActive,
                      onChanged: (val) => setState(() => _isActive = val),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Save Button ────────────────────────────────
            ElevatedButton(
              onPressed: _isSaving ? null : _saveProduct,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSaving
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text('Saving to Store...'),
                      ],
                    )
                  : Text(_isEditing ? 'Update Grocery Item' : 'Publish Grocery Item'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Display
          Container(
            height: 190,
            width: double.infinity,
            color: Colors.grey.shade100,
            child: _pickedImageBytes != null
                ? Image.memory(_pickedImageBytes!, fit: BoxFit.cover)
                : (_imageCtrl.text.trim().isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: _imageCtrl.text.trim(),
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => const Center(
                          child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined,
                              size: 52, color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          Text(
                            'No photo selected',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      )),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.cloud_upload_outlined),
                    label: const Text('Pick Image'),
                    onPressed: _showImageSourceDialog,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.link),
                    label: const Text('Use URL'),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Paste Image URL'),
                          content: TextField(
                            controller: _imageCtrl,
                            decoration: const InputDecoration(
                              hintText: 'https://example.com/item.jpg',
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                setState(() => _pickedImageBytes = null);
                                Navigator.pop(context);
                              },
                              child: const Text('Apply'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
