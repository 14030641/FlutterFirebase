class ProductDAO {
  String model;
  String description;
  String image;

  ProductDAO({this.model, this.description, this.image});
  Map<String, dynamic> toMap() {
    return {'model': model, 'description': description, 'image': image};
  }
}
