class Cart {
  int id;
  String product_id;
  String vendor_id;
  String product;
  String image;
  String price;
  int sold_quantity;
 
Cart({this.id, this.product_id, this.vendor_id, this.product, this.image, this.price, this.sold_quantity});
  Map<String, dynamic> toMap() {
    return {'id': id, 'product_id': product_id, 'vendor_id': vendor_id, 'product': product, 'image': image, 'price': price, 'sold_quantity': sold_quantity};
  }
}