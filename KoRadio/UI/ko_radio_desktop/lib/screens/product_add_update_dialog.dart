import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:ko_radio_desktop/models/product.dart';
import 'package:ko_radio_desktop/models/search_result.dart';
import 'package:ko_radio_desktop/models/service.dart';
import 'package:ko_radio_desktop/providers/auth_provider.dart';
import 'package:ko_radio_desktop/providers/product_provider.dart';
import 'package:ko_radio_desktop/providers/service_provider.dart';
import 'package:ko_radio_desktop/providers/utils.dart';
import 'package:provider/provider.dart';

class ProductDetailsDialog extends StatefulWidget {
  const ProductDetailsDialog({this.product,super.key});
  final Product? product;

  @override
  State<ProductDetailsDialog> createState() => _ProductDetailsDialogState();
}

class _ProductDetailsDialogState extends State<ProductDetailsDialog> {
  final _formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  late ProductProvider productProvider;
  late ServiceProvider serviceProvider;
  SearchResult<Service>? serviceResult;
  File? _image;
  String? _base64Image;
  Uint8List? _decodedImage;
  
  @override
  void initState() {
    super.initState();  
      productProvider = context.read<ProductProvider>();
      serviceProvider = context.read<ServiceProvider>();
      _initialValue = {
            "productName": widget.product?.productName,
            "productDescription": widget.product?.productDescription,
            "price": widget.product?.price.toString(),
            "image": widget.product?.image,
            "stockQuantity": widget.product?.stockQuantity.toString(),
            "isOnSale": widget.product?.isOnSale,
            "salePrice": widget.product?.salePrice.toString(),
            "serviceId": widget.product?.productsServices?.map((e) => e.serviceId).whereType<int>().toSet()
      .toList()

          };
          if (widget.product?.image != null) {
            try {
              _decodedImage = base64Decode(widget.product!.image!);
            } catch (_) {
              _decodedImage = null;
            }
          }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {  
     
   
         await _getServices();

    });


 

  
   
  }
  
    Future<void> _pickImage() async {
  var result = await FilePicker.platform.pickFiles(type: FileType.image);

  if (result != null && result.files.single.path != null) {
    setState(() {
      _image = File(result.files.single.path!);
      _base64Image = base64Encode(_image!.readAsBytesSync());
      _decodedImage = null; 
    });
  }
}

  Future<void> _getServices() async {
    try {
      var fetchedServices= await serviceProvider.get();
      setState(() {
        serviceResult = fetchedServices;
      });
    } catch (e) {
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
    
    surfaceTintColor: Colors.white,
    child: SizedBox(
      width: MediaQuery.of(context).size.width * 0.25,
      height: MediaQuery.of(context).size.height * 1,
      child:  ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: 
            SingleChildScrollView(
              child: FormBuilder(
                key: _formKey,
                initialValue: _initialValue,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if(widget.product==null)
            
                    Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF4A90E2), Color.fromRGBO(27, 76, 125, 1)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Dodaj proizvod',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                          splashRadius: 20,
                        ),
                      ],
                    ),
                  ),
                    if(widget.product!=null)
                     Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF4A90E2), Color.fromRGBO(27, 76, 125, 1)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Detalji prozivoda',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                          splashRadius: 20,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                             const Text(
                              'Informacije o proizvodu',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 12),
                      const SizedBox(height: 20),
                      FormBuilderTextField(name: "productName", decoration: const InputDecoration(labelText: "Naziv proizvoda:", border: OutlineInputBorder()),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(errorText: 'Obavezno polje'),
                        FormBuilderValidators.maxLength(20, errorText: 'Maksimalno 20 znakova'),
                        FormBuilderValidators.minLength(2, errorText: 'Minimalno 2 znaka'),
                        FormBuilderValidators.match(r'^[A-ZĆČĐŠŽ][A-Za-zĆČĐŠŽćčđšž0-9 ]+$', errorText: 'Dozvoljena su samo slova i brojevi sa prvim velikim.'),
                      ]),
                      ),
                      const SizedBox(height: 20),
                      FormBuilderTextField(name: "productDescription", decoration:  InputDecoration(
                        labelText: "Opis", border: OutlineInputBorder(),
                       helperText: "Maksimalno 100 znakova",
                       filled: true,
                       fillColor: Colors.grey[100],
                      ),
                      maxLines: 3,
                      
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(errorText: 'Obavezno polje'),
                        FormBuilderValidators.maxLength(100, errorText: 'Maksimalno 100 znakova'),
                        FormBuilderValidators.minLength(10, errorText: 'Minimalno 10 znaka'),
                        FormBuilderValidators.match(r'^[A-ZĆČĐŠŽ][A-Za-zĆČĐŠŽćčđšž0-9 .,-]+$', errorText: 'Dozvoljena su samo slova i brojevi sa prvim velikim i osnovnim znakovima.'),
                      ]),
                      ),
                      const SizedBox(height: 20),
                     
                       FormBuilderTextField(
                                  name: "price",
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: const InputDecoration(
                                    labelText: 'Cijena',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.attach_money),
                                  ),
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.required(errorText: 'Obavezno polje'),
                                    FormBuilderValidators.numeric(errorText: 'Mora biti broj, npr. 10.00'),
                                  ]),
                                  valueTransformer: (value) => double.tryParse(value ?? ''),
                                ),
                      const SizedBox(height: 20),
                      FormBuilderTextField(name: 'stockQuantity', decoration: const InputDecoration(labelText: 'Na lageru', border: OutlineInputBorder()),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(errorText: 'Obavezno polje'),
                        FormBuilderValidators.integer(errorText: 'Mora biti broj, npr. 10'),
                      ]),
                      ),
                      if(widget.product!=null)
                      const SizedBox(height: 20),
                      if(widget.product!=null)
                                
                    
                      const SizedBox(height: 20),
                      if(widget.product?.isOnSale==true)
                      FormBuilderCheckbox(title:Text('Akcija?'),name: 'isOnSale', initialValue: widget.product?.isOnSale ?? false, 
                      
                      ),
                      const SizedBox(height: 20),
                     
                                   
                                  const Text(
                              'Tip proizvoda',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                    
                                serviceResult?.result.isNotEmpty == true
                                ? FormBuilderFilterChip<int>(
                                    name: "serviceId",
                                    options: serviceResult!.result
                                        .map((s) => FormBuilderChipOption(
                                              value: s.serviceId,
                                              child: Text(s.serviceName ?? ""),
                                            ))
                                        .toList(),
                                    spacing: 6,
                                    runSpacing: 4,
                                    validator: FormBuilderValidators.required(
                                        errorText: "Odaberite bar jednu uslugu."),
                                  )
                                : const Text("Nema dostupnih usluga"),
                      
                            const SizedBox(height: 16),
                        
                                  const Text(
                              'Slika proizvoda',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 16),

                    
                         FormBuilderField(
                                  name: "image",
                                  builder: (field) {
                                    return InputDecorator(
                    decoration: const InputDecoration(
                      labelText: "Slika proizvoda",
                      border: OutlineInputBorder(),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.image),
                          title: _image != null
                                  ? Text(_image!.path.split('/').last)
                                  : widget.product?.image != null
                    ? const Text('Proslijeđena slika')
                    : const Text("Nema proslijeđene slike"),
                          trailing: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromRGBO(27, 76, 125, 1),
                                ),
                                icon: const Icon(Icons.file_upload, color: Colors.white),
                                label: _image == null && widget.product?.image == null
                                    ? const Text("Odaberi", style: TextStyle(color: Colors.white))
                                    : const Text("Promijeni sliku", style: TextStyle(color: Colors.white)),
                                onPressed: () => _pickImage(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (_image != null)
                          ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  _image!,
                                  fit: BoxFit.cover,
                                ),
                          )
                        else if (_decodedImage != null)
                          ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  _decodedImage!,
                                  fit: BoxFit.cover,
                                ),
                          )
                        else
                          const SizedBox.shrink(),
                      ],
                    ),
                                    );
                                  },
                                ),
                      ],
                    ),
                  ),
                  
                  
                     const SizedBox(height: 24),
                      
                                         
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                              
                                  icon: const Icon(Icons.save, color: Colors.white),
                                  label: const Text("Sačuvaj", style: TextStyle(color: Colors.white)),
                                  onPressed: _save,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    backgroundColor: const Color.fromRGBO(27, 76, 125, 1),
                                  ),
                                ),
                              ),
                            ),
                  ],
                ),
              ),
            ),
       
      ),
    ),
    );
  }
void getImage(FormFieldState field) async {
  var result = await FilePicker.platform.pickFiles(type: FileType.image);

  if (result != null && result.files.single.path != null) {
    setState(() {
      _image = File(result.files.single.path!);
      _base64Image = base64Encode(_image!.readAsBytesSync());
    });

 
    field.didChange(_image);
  }
}
  Future<void> _save() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final request = Map<String, dynamic>.from(_formKey.currentState!.value);
      request['storeId']=AuthProvider.selectedStoreId;
      request['isDeleted'] = false;
      request['stockQuantity'] = request['stockQuantity'];
       if (request["price"] != null) {
      request["price"] = (request["price"] as double).toString();
    } else {
      request["price"] = null;
    }
    if(_image!=null)
    {
      request['image'] = _base64Image;
    }
    else{
      request['image'] = widget.product?.image;
    }
    
    request['serviceId'] = (request['serviceId'] as List).map((e) => int.tryParse(e.toString()) ?? 0).toList();
    
    
      if(widget.product!=null){
      try {
        await productProvider.update(widget.product?.productId ?? 0, request);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Podaci uspješno uređeni!")),
        );
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Greška: ${e.toString()}")),
        );
      }
      }
       else{
      try {
        await productProvider.insert(request);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Proizvod uspješno dodan!")),
        );
        Navigator.pop(context, true);
      } 
       catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Greška: ${e.toString()}")),
        );
      }
      }
    }
  }
}