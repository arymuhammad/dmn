class QualityModel {
  final String id;
  final String quality;
  final String playlist;
  final int? bandwidth;
  final int? width;
  final int? height;


  QualityModel({
    required this.id,
    required this.quality,
    required this.playlist,
    this.bandwidth,
    this.width,
    this.height,
  });



  factory QualityModel.fromJson(Map<String, dynamic> json) {

    return QualityModel(

      id: json['id'] ?? '',
      quality: json['quality'] ?? '',

      playlist: json['playlist'] ?? '',

      bandwidth: json['bandwidth'] != null
          ? int.tryParse(
              json['bandwidth'].toString()
            )
          : null,

      width: json['width'] != null
          ? int.tryParse(
              json['width'].toString()
            )
          : null,

      height: json['height'] != null
          ? int.tryParse(
              json['height'].toString()
            )
          : null,

    );
  }



  Map<String, dynamic> toJson() {

    return {

      'quality': quality,

      'playlist': playlist,

      'bandwidth': bandwidth,

      'width': width,

      'height': height,

    };
  }
}