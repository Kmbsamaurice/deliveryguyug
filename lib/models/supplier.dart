class Supplier {
  String status;
  String vendorId;
  String name;
  String category;
  String thumbnailUrl;

  Supplier({this.status, this.vendorId, this.name, this.category, this.thumbnailUrl});

  Supplier.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    vendorId = json['vendor_id'];
    name = json['name'];
    category = json['category'];
    thumbnailUrl = json['thumbnail'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['vendor_id'] = this.vendorId;
    data['name'] = this.name;
    data['category'] = this.category;
    data['thumbnailUrl'] = this.thumbnailUrl;
    return data;
  }
}
