import 'package:tcc_yoji/core/contants/api_constants.dart';

class ItensRotesServices {
  static const String listarEquipamentos =
      '${ApiConstants.apiUrl}/equipamentos';
  static String buscarEquipamento(int id) =>
      '${ApiConstants.apiUrl}/equipamentos/$id';
}
