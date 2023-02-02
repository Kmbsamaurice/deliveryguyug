class Product {
  String id;
  String vendorid;
  String product;
  String price;
  String description;
  String image1;
  String image2;
  String status;

  Product({this.id, this.vendorid, this.product, this.price, this.description, this.image1, this.image2, this.status});

  Product.fromJson(Map<String, dynamic> json) {
    id = json['product_id'];
    vendorid = json['vendor_id'];
    product = json['product'];
    price = json['price'];
    description = json['description'];
    image1 = json['image1'];
    image2 = json['image2'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['product_id'] = this.id;
    data['vendor_id'] = this.vendorid;
    data['product'] = this.product;
    data['price'] = this.price;
    data['description'] = this.description;
    data['image1'] = this.image1;
    data['image2'] = this.image2;
    data['status'] = this.status;
    return data;
  }
}
