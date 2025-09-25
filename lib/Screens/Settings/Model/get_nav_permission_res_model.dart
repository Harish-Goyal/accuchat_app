import 'get_company_roles_res_moel.dart';

class NavPermissionResModel {
  bool? success;
  int? code;
  String? message;
  List<NavigationItem>? data;

  NavPermissionResModel({this.success, this.code, this.message, this.data});

  NavPermissionResModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    code = json['code'];
    message = json['message'];
    if (json['data'] != null) {
      data = <NavigationItem>[];
      json['data'].forEach((v) {
        data!.add(new NavigationItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['code'] = this.code;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class NavigationItem {
  int? navigationItemId;
  String? navigationItem;
  String? navigationPlace;
  int? sortingOrder;
  int? isActive;

  NavigationItem(
      {this.navigationItemId,
        this.navigationItem,
        this.navigationPlace,
        this.sortingOrder,
        this.isActive});

  NavigationItem.fromJson(Map<String, dynamic> json) {
    navigationItemId = json['navigation_item_id'];
    navigationItem = json['navigation_item'];
    navigationPlace = json['navigation_place'];
    sortingOrder = json['sorting_order'];
    isActive = json['is_active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['navigation_item_id'] = this.navigationItemId;
    data['navigation_item'] = this.navigationItem;
    data['navigation_place'] = this.navigationPlace;
    data['sorting_order'] = this.sortingOrder;
    data['is_active'] = this.isActive;
    return data;
  }
}
