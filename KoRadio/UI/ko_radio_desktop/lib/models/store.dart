
import 'package:json_annotation/json_annotation.dart';
import 'package:ko_radio_desktop/models/location.dart';
import 'package:ko_radio_desktop/models/user.dart';

part 'store.g.dart';

@JsonSerializable()
class Store{
  int storeId;
  String? storeName;
  User? user;
  String? description;
  bool? isDeleted;
  bool? isApplicant;
  Location? location;

  Store({
    required this.storeId,
    
  });
  
 factory Store.fromJson(Map<String, dynamic> json) => _$StoreFromJson(json);

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$StoreToJson(this);
  }

