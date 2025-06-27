import 'dart:convert';

import 'package:digital_asset_flutter/features/asset/domain/entities/entities.dart';
import 'package:digital_asset_flutter/features/asset/domain/repositories/asset_repositories.dart';
import 'package:http/http.dart' as http;

import '../../../../../core/constants/api_constans.dart';
import '../../../../../core/network/result.dart';

class AssetRepositoriesImpl implements AssetRepository {
  @override
  Future<Map<String, AssetInfo>?> getListAssetByNetwork(String networkName) async {
    String url = '${ApiEndpoints.walletCoreBaseUrl}/$networkName/assets';
    Map<String, String> headers = {"Content-type": "application/json"};
    http.Response res = await http.Client().get(Uri.parse(url), headers: headers);
    // print("Get valuation response ${res.body}");
    if (res.statusCode == 200) {
      final Map<String, dynamic> decoded = json.decode(res.body);

      final dynamic data = decoded['data'];
      Map<String, AssetInfo> result = {};
      if (data != null) {
        final List<dynamic> listAssetInfos = data['assets'];
        List<AssetInfo> listAssetInfo = listAssetInfos.map((asset) => AssetInfo.fromJson(asset)).toList();
        for (var assetInfo in listAssetInfo) {
          result[assetInfo.assetId] = assetInfo;
        }
        return result;
      }
      return null;
    } else {
      final json = jsonDecode(res.body);
      final state = json['state'] ?? {};
      return null;
    }
  }
}
