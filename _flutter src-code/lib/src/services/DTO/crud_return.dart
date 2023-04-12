class CRUDReturn {
  bool success;
  dynamic data;
  
  CRUDReturn({required this.success, required this.data});
  
  factory CRUDReturn.fromJson(Map<String, dynamic> json) {
    return CRUDReturn(
      success: json['success'],
      data: json['data']
    );
  }
  
  Map<String, dynamic> toJson() => {
    'success': success,
    'data': data,
  };
}