class Farmer {
  int farmerId;
  String project;
  String group;
  String name;
  String district;
  String village;
  String sector;
  String subVillage;

  Farmer(
      {this.farmerId,
      this.project,
      this.group,
      this.name,
      this.district,
      this.village,
      this.sector,
      this.subVillage});

  factory Farmer.fromMap(Map<String, dynamic> map) {
    return Farmer(
      farmerId: map['Farmer_ID'],
      project: map['Project'],
      group: map['Group'],
      name: map['Name'],
      district: map['District'],
      village: map['Village'],
      sector: map['Sector'],
      subVillage: map['Subvillage'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'Farmer_ID': farmerId,
      'Project': project,
      'Group': group,
      'Name': name,
      'District': district,
      'Village': village,
      'Sector': sector,
      'Subvillage': subVillage,
    };
  }
}
