import 'dart:async';
import 'package:http/http.dart' as http;


/// URLs
String landingUrl =
    'https://fltops.omanair.com/mlt/filter.jsp?window=filter&loggedin=false';
String loginFormUrl = 'https://fltops.omanair.com/mlt/loginpostaction.do';
String checkinListUrl = 'https://fltops.omanair.com/mlt/checkinlist.jsp';
String crewSelectUrl = "https://fltops.omanair.com/mlt/crewselectpostaction.do";
String crewGanttUrl = "https://fltops.omanair.com/mlt/crewganttnavigator.jsp?persons=";
String ganttUrl = "https://fltops.omanair.com/mlt/ganttsvg.jsp";
String ganttDutyUrl  = 
    "https://fltops.omanair.com/mlt/crewacytripdetails.do?"
    "personId=REPLACEPERSONID"
    "&persAllocId=REPLACEPERSALLOCID"
    "&tan=DatedTripAlloc&utcLocal=Utc";

/// RegExp's
RegExp tokenRegExp = new RegExp(
    r'<input type="hidden" name="token" value="(\S+)">');
RegExp cookieRegExp = new RegExp(r'(JSESSIONID=\w+);');


class IobConnector {

  String username;
  String password;
  String token;
  String cookie;
  String bigCookie;
  String personId;
  http.Client client;

  Map<String, String> crewSelectForm = {
    "org.apache.struts.taglib.html.TOKEN": "", // <= set token here
    "baseStationMain": "MCT",
    "pairingLabelName": "Pairing",
    "viewType": "crew",
    "action": "addcrewonly",
    "colourSwitch": "0",
    "apntCode": "",
    "userId": "",
    "isAdmin": "0",
    "crewTypeCode": "" ,
    "rankCode": "",
    "fleetCode": "",
    "crewBaseStation": "",
    "crewId": "93429",
    "crewName": "",
    "addcrewonly": "Add",
    "tripRefNumber": "",
    "acyGroupCode": "",
    "apntSysId": "",
    "tripAcyFromDt": "07Apr2019",
    "tripAcyToDt": "07Apr2019",
    "cxCd": "WY",
    "fltNo": "",
    "fltDate": "07Apr2019",
    "fltToDate": "07Apr2019",
    "depStn": "",
    "station": "",
    "fromDate": "07Apr2019",
    "fromTime": "00:00",
    "toDate": "07Apr2019",
    "toTime": "23:59",
    "baseStation": "MCT",
    "utcLocal": "Local",
    "hidActivity": "",
  };
  
  /// Used for initial connection, set token and cookie for the session.
  /// Returns the check-in list in a String to be parsed (see Parsers.dart)
  /// In the case of any failure, returns an empty string.
  Future<String> run(String username, String password) async {

    print("Connectiong to IOB...");

    this.username = username;
    this.password = password;

    client = new http.Client();

    http.Response iobResponse;

    try {
      iobResponse = await client.get(landingUrl);
    } on Exception catch (e) {
      print('OFFLINE! Exception: ' + e.toString());
      return "";
    }

    print("Connected with status code: " + iobResponse.statusCode.toString());

    // TODO: Check response integrity using Status Code or anything!

    String landingBodyWithToken = iobResponse.body;
    this.token = tokenRegExp.firstMatch(landingBodyWithToken).group(1);

    print('Token: ' + token);

    String loginHeaders = (
        await client.post(
            loginFormUrl,
            body: {"username": username, "password": password, "token": token}
        )
    ).headers.toString();
    cookie = cookieRegExp.firstMatch(loginHeaders).group(1);

    print('Cookie: ' + cookie);

    http.Response checkinListResponse =
      await client.get(checkinListUrl, headers: {"Cookie": cookie});
    this.bigCookie = checkinListResponse.headers["set-cookie"];

    String checkinList = checkinListResponse.body;

    return checkinList;
  }

  Future<String> getGanttMainTable() async {
    /// gets the GANTT  main table data and change it into a String to be parsed.
    // todo: add 2 datetimes as parameters to define the time frame.

    crewSelectForm['org.apache.struts.taglib.html.TOKEN'] = this.token;
    crewSelectForm['action'] = 'fastcrewonly';

    http.Response response = await client.post(
        crewSelectUrl,
        headers: {"Cookie": cookie + ";" + bigCookie},
        body: crewSelectForm
    );
    
    String crewSelectBody = response.body;
    RegExp personRE = RegExp(r"crewganttnavigator\.jsp\?persons=(\d+)");
    Match personM = personRE.firstMatch(crewSelectBody);
    personId = personM[1];

    response = await client.get(
        ganttUrl,
        headers: {"Cookie": cookie + ";" + bigCookie}
    );

    return response.body;
  }
  
  Future<String> getGanttDuty(String personId, String persAllocId) async {

    String url = ganttDutyUrl.replaceAll("REPLACEPERSONID", personId);
    url = url.replaceAll("REPLACEPERSALLOCID", persAllocId);

    http.Response response = await client.get(
        url, headers: {"Cookie": cookie + ";" + bigCookie});


  }
}
