

import 'package:AccuChat/Screens/chat_module/models/response_model.dart';

class PaginatinDataModal<T extends Serializable> extends Serializable {
  List<T>? listItems;
  var page;
  var perPage;
  int? totalCount;
  int? pageCount;

  PaginatinDataModal(
      {this.listItems,
        this.page,
        this.perPage,
        this.totalCount,
        this.pageCount});

  PaginatinDataModal.fromJson(Map<String, dynamic> json,T Function(dynamic) create) {
    if (json['listItems'] != null) {
      listItems = <T>[];
      json['listItems'].forEach((v) {
        listItems!.add(


            create(v
            )
        );
      });
    }
    page = json['page'];
    perPage = json['perPage'];
    totalCount = json['totalCount'];
    pageCount = json['pageCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.listItems != null) {
      data['listItems'] = this.listItems!.map((v) => v.toJson()).toList();
    }
    data['page'] = this.page;
    data['perPage'] = this.perPage;
    data['totalCount'] = this.totalCount;
    data['pageCount'] = this.pageCount;
    return data;
  }
}