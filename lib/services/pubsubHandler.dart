import 'package:gcloud/pubsub.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;

class PubsubHandler {
  static String _createJsonFormData(
      String system,
      String deviceId,
      String deviceType,
      DateTime time,
      String dataType,
      String fieldName,
      String data) {
    var jsonFormat =
        "{\"system\":\"$system\",\"device_id\":\"$deviceId\",\"device_type\":\"$deviceType\",\"data\":[{\"time\":\"${time.toString()}\",\"type\":\"$dataType\",\"fieldName\":\"$fieldName\",\"data\" :\"$data\"}]}";
    print("$jsonFormat\n");
    return jsonFormat;
  }

  static Future<http.Client> _createClient() {
    // Service account credentials retrieved from Cloud Console.
    String creds = r'''
      {
        "private_key_id": "b4ce54671e4f3f0e4b82a5715ca891ad9afb429b",
        "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDSxJR/fEnOIUrN\nXl8ayEzLivgIkN+qLsl+KQVEWNaxvhyfXKSrxig+4iYRq+xKDwDw1bgZpgeDVskh\nlnWNv1FjSLCeJmhVwHn/KZXnDsqW9YIzHvJqFGFgLjjLZ/vvIGm/Qftxj9cH6eQS\nHfuaSHlMetHBaLxPWaHudtrB/7IwjKMiDwVLbQcmc4PFX9pOmGWqpJAhhzlA6Mek\naTllO9fm+DnAfl5U4dM6qHpJeU17nh9WqqikBbQTwnGVnlZ0kjGyp1YFB+u0zdDC\n7H9+RIxhtZ77kg0xFGEp4aZSffyG40xbmgsMBqtC72UB0bPZ6ZDGhtB7l4Jn8Txz\nf3Zov6SdAgMBAAECggEAMy2Tp18dJsXTvYloS38OkrAUaTQQc2j3+T/prP5rZ25z\n0chzndg4hohwWQMnlZYOEuy6TtQPZ/dnUFYSBlDJ6PNKG6TU2dmqZeiJozjmvYAw\n1Mvzbgmz2WBv3whJVvfGZbAWZ61XN+81t6Z7JSvq9ESwcSfG7fekR9ypYsj9Uicr\nIKlocusi5+uuftAYw17ze9IQU0JcxIilhrLCCRWEbckGRbh2LXeWSM5w+KcZ1iMT\nX/zrudLJnL8AgD2Q0v9zK+qYRqb4/Ctg+awz3AZbR3/l02Xg50PLrJvCnnKKffxj\noS/0Zix4BRFamLMuS/Vx0KrOS4vvDgK5o0SARhYj0QKBgQD3On2Ny2XQ9nEhmtGg\niDEvqStDiP2NRcI9bXJy5y5YuO8VHq0Hl6Ay6fieccoC1ey+ExIDGz1M2YP5mdhb\n3GgQWQipM5GBj78+9PvfB7Yu1CvW/o41fQhrCjX976gP1bW9wI3eFgxx2wi9xnOb\nZ67AribsIqxeN+p8XqAiLxJ8+QKBgQDaPu2ODH18Y+FdxkrDhSzTXTeQxGl3Gtff\np7R2C0NnbjtE6Bshoyi2JZxGxWaWMiQ/rnUPDYhD+O3YSMO3tjf6emJ7ijOJ9Fb3\ndQpdjcISdhKQQBH8ec8GY6GJD7hAzWmZjTYe+q1NIL4H8BeYKp1dg5OB9CmCR/vA\novuBMeyBxQKBgQDPhzy/mx5zo3thzxjqnYhUTrgvb74PKaCcedQZme/wsASZgO+U\nMPZb5sU5E6GUccjR4SY8j1AMw4YiLr9MlR6Rons/tTcOQAE0sub+1/VZJ+dJCNON\nGNDJMYATEmrMKAPwLcOoym9V35xd2UlQCV/LBCVOEOkKCfv+vFvFdigZ2QKBgAH2\n+xCCUEbkZ0z+0gF8m3CzsCJfgkuONE9RJTDC3TJ7LZFrPYNKAr3RDN0ePdQwU183\nZNpj1sw1235M+WYX/90DaQuPrPMa/gVwSk2ZTxv3cCdYTFEnj5ORJg0j1RbQQpkd\nSlVxEEpXdx5/LNcz2wLSgmtzFUSU/VE4pmb9WhG5AoGASyTJLIV4NbFf/robGXmw\nSIcT4myzW2n+xv/Vhig4H0FfRT+YNC2Doh124VvYTD2sgSndjOLy1qEfUOTpHcN6\nPYhPgs6odH/HwMbfk4kDrqMezNhsRuNqlNlXEzGBbnXHbXmH3bOgSF1Vwq0Vgqa/\nGKtlSk+dF1vKIAFj9a3cmu8=\n-----END PRIVATE KEY-----\n",
        "client_email": "pubsub@iot-final-8b2e0.iam.gserviceaccount.com",
        "client_id": "112209291642929601982",
        "type": "service_account"
      }''';
    return auth.clientViaServiceAccount(
        new auth.ServiceAccountCredentials.fromJson(creds), PubSub.SCOPES);
  }

  static void sendToPubSub(String system, String deviceId, String deviceType,
      DateTime time, String dataType, String fieldName, String data) async {
    var client;
    PubSub pubsub;
    var project = 'iot-final-8b2e0';
    _createClient().then((c) {
      client = c;
      pubsub = new PubSub(client, project);
      return pubsub.lookupTopic('Test');
    }).then((Topic topic) => topic.publish(Message.withString(
        _createJsonFormData(
            system, deviceId, deviceType, time, dataType, fieldName, data))));
  }
}
