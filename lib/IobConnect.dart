import 'dart:io';
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
  
  static Future<String> run(String username, String password) async {

    http.Client client = new http.Client();

    String landingBodyWithToken = (await client.get(landingUrl)).body;
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
