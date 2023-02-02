class District {
   String upcountryId;
   String district;
   String tariff;

  District({this.upcountryId, this.district, this.tariff});

  District.fromJson(Map<String, dynamic> json) {
    upcountryId = json['upcountry_id'];
    district = json['district'];
    tariff = json['tariff'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['upcountry_id'] = this.upcountryId;
    data['district'] = this.district;
    data['tariff'] = this.tariff;
    return data;
  }
}

class BankModel {
  final String bank_name;

  BankModel({this.bank_name});

  factory BankModel.fromJson(Map<String, dynamic> parsedJson) {
    return BankModel(
        bank_name: parsedJson['bank_name']
    );
  }
}

