import 'dart:io';
import 'package:googleapis/drive/v3.dart' as ga;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:listenmebaby71_s_application17/core/services/security_storage_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_sign_in/google_sign_in.dart';
const _scopes = [ga.DriveApi.driveFileScope];
final _clientId = Platform.isAndroid
    ? '408583851820-gcrn80s3cu2av4cqm2jhhf67ei007p8r.apps.googleusercontent.com'
    : '408583851820-6lodf34gi09t60jqm3vcfi5l8c80itpk.apps.googleusercontent.com';
final _clientSecret = Platform.isAndroid
    ? 'AIzaSyDprVPSCYx63aN6SdnSz2XeqRUrYd6TNV0'
    : 'AIzaSyCcSAMOzyDlfD0sDKZSgD_-Vs_VHLIqDaQ';


class GoogleDriveService {


  //Get Authenticated Http Client

  Future<ga.DriveApi> _getClient() async {
    final googleSignIn = GoogleSignIn.standard(scopes: [
      ga.DriveApi.driveAppdataScope,
      ga.DriveApi.driveFileScope
    ]);
    var user = await googleSignIn.signIn();


    final client = GoogleAuthClient(await user!.authHeaders);
    return ga.DriveApi(client);
  }



  Future<String> upload(File file) async {
    final drive = await _getClient();
    final driveFile = ga.File(
        name: 'rigel_psy_backup_from_' + DateTime.now().toIso8601String() +
            '.json', mimeType: 'application/json');
    final response = await drive.files.create(driveFile,
        uploadMedia: ga.Media(file.openRead(), file.lengthSync())
    );
    print(response.toJson());
    return response.id!;
  }

  Future<ga.Media?> downloadFile(String fileId, String savePath) async {
    final driveApi = await _getClient();

    final response = await driveApi.files.get(
        fileId, downloadOptions: ga.DownloadOptions.fullMedia) as ga.Media?;
    if (response != null) {
      final output = File(savePath);
      if (await output.exists()) {
        output.delete();
      }
      List<int> dataStore = [];
      response.stream.listen((event) {
        dataStore.insertAll(dataStore.length, event);
      }, onDone: () async {
        await output.create(recursive: true);
        output.writeAsBytes(dataStore);
      });
    }
  }

  Future<bool> deleteFile(String fileId) async {
    final driveApi = await _getClient();
    try {
      await driveApi.files.delete(fileId);
      return true;
    } catch (_) {
      return false;
    }
  }

}

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final _client = new http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}