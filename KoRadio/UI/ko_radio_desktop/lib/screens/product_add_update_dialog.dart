import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/svg.dart';
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

            "serviceId": widget.product?.productsServices?.map((e) => e.serviceId).whereType<int>().toSet()
      .toList()

          };
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {  
     
   
         await _getServices();

    });


 

  
   
  }
  
  
  Future<void> _getServices() async {
    try {
      var fetchedServices= await serviceProvider.get();
      setState(() {
        serviceResult = fetchedServices;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: SizedBox(
        width: 500,
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.05,
                child: SvgPicture.asset(
                  'assets/images/undraw_data-input_whqw.svg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: FormBuilder(
                  key: _formKey,
                  initialValue: _initialValue,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Podaci Proizvoda", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      FormBuilderTextField(name: "productName", decoration: const InputDecoration(labelText: "Naziv proizvoda:")),
                      const SizedBox(height: 20),
                      FormBuilderTextField(name: "productDescription", decoration: const InputDecoration(labelText: "Opis")),
                      const SizedBox(height: 20),
                     
                       FormBuilderTextField(
                name: "price",
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Cijena',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                valueTransformer: (value) => double.tryParse(value ?? ''),
              ),
                      const SizedBox(height: 20),
                     
                 

                    
 Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 0),
                            child: serviceResult?.result != null
                                ? FormBuilderFilterChip(
                                    name: "serviceId",
                                    decoration: const InputDecoration(border: InputBorder.none,label: Text("Kategorije")),
                                    options: serviceResult!.result
                                        .map((s) => FormBuilderChipOption(
                                          
                                            value: s.serviceId, 
                                             child: Text(s.serviceName ?? "")))
                                        .toList(),
                                    spacing: 6,
                                    runSpacing: 4,
                                  )
                                : const Text("Nema dostupnih usluga"),
                          ),
                          SizedBox(height: 20,),
                    
                    
                         FormBuilderField(
  name: "image",

  builder: (field) {
    return InputDecorator(
      decoration:  InputDecoration(
        labelText: "Proslijedite sliku problema",
        border: OutlineInputBorder(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.image),
            title: 
            
             _image != null
                ? Text(_image!.path.split('/').last)
                :  widget.product?.image!= null ?
            const Text('Proslijeđena slika') :
                
                 const Text("Nema proslijeđene slike"),
            trailing: ElevatedButton.icon(

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(27, 76, 125, 1),



              ),
              icon: const Icon(Icons.file_upload, color: Colors.white),
              label:widget.product?.image!= null ? Text('Promijeni sliku',style: TextStyle(color: Colors.white)): _image==null? const Text("Odaberi", style: TextStyle(color: Colors.white)): const Text("Promijeni sliku", style: TextStyle(color: Colors.white)),
              onPressed: () =>  getImage(field) 
             
            ),
          ),
          const SizedBox(height: 10),
          _image != null ?
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                _image!,
               
                fit: BoxFit.cover,
              ),
            ) :
            widget.product?.image!=null ?
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child : imageFromString(widget.product?.image ?? '',
              fit: BoxFit.cover
              ),
            ) : const SizedBox.shrink()
           
            ,
        ],
      ),
    );
  },
),
                      const SizedBox(height: 30),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.save),
                          label: const Text("Sačuvaj"),
                          onPressed: _save,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
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