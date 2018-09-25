import 'dart:async';
import 'package:http/http.dart' as http;


/// URLs
String landingUrl =
    'https://fltops.omanair.com/mlt/filter.jsp?window=filter&loggedin=false';
String loginFormUrl = 'https://fltops.omanair.com/mlt/loginpostaction.do';
String checkinListUrl = 'https://fltops.omanair.com/mlt/checkinlist.jsp';

/// RegExp's
RegExp tokenRegExp = new RegExp(
    r'<input type="hidden" name="token" value="(\S+)">');
RegExp cookieRegExp = new RegExp(r'(JSESSIONID=\w+);');


class IobConnect {
  
  /// Returns the check-in list in a String to be parsed (see Parsers.dart)
  /// In the case of any failure, returns an empty string.
  static Future<String> run(String username, String password) async {

    http.Client client = new http.Client();

    http.Response iobResponse;

    try {
      iobResponse = await client.get(landingUrl);
    } on Exception catch (e) {
      print('OFFLINE');
      return "";
    }

    // TODO: Check response integrity using Status Code or anything!

    String landingBodyWithToken = iobResponse.body;
    String token = tokenRegExp.firstMatch(landingBodyWithToken).group(1);

    String loginHeaders = (
        await client.post(
            loginFormUrl,
            body: {"username": username, "password": password, "token": token}
        )
    ).headers.toString();
    String cookie = cookieRegExp.firstMatch(loginHeaders).group(1);

    String checkinList = (
        await client.get(checkinListUrl, headers: {"Cookie": cookie})
    ).body;

    return checkinList;
  }
}
