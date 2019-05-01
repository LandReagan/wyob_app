import 'dart:async';
import 'package:intl/intl.dart' show DateFormat;
import 'package:http/http.dart' as http;
import 'package:wyob/WyobException.dart';


/// URLs
String landingUrl =
    'https://fltops.omanair.com/mlt/filter.jsp?window=filter&loggedin=false';
String loginFormUrl = 'https://fltops.omanair.com/mlt/loginpostaction.do';
String checkinListUrl = 'https://fltops.omanair.com/mlt/checkinlist.jsp';
String crewSelectUrl = "https://fltops.omanair.com/mlt/crewselectpostaction.do";
String crewGanttUrl = "https://fltops.omanair.com/mlt/crewganttnavigator.jsp?persons=";
String ganttUrl = "https://fltops.omanair.com/mlt/ganttsvg.jsp";
String ganttDutyTripUrl  =
    "https://fltops.omanair.com/mlt/crewacytripdetails.do?"
    "personId=REPLACEPERSONID"
    "&persAllocId=REPLACEPERSALLOCID"
    "&tan=DatedTripAlloc&utcLocal=";
String ganttDutyAcyUrl  =
    "https://fltops.omanair.com/mlt/crewacytripdetails.do?"
    "personId=REPLACEPERSONID"
    "&persAllocId=REPLACEPERSALLOCID"
    "&tan=DatedAcyAlloc&utcLocal=";
String fromToGanttUrl = "https://fltops.omanair.com/mlt/crewganttpreaction.do?";

/// RegExp's
RegExp tokenRegExp = new RegExp(
    r'<input type="hidden" name="token" value="(\S+)">');
RegExp cookieRegExp = new RegExp(r'(JSESSIONID=\w+);');

enum TIME_ZONE {
  Local,
  Utc
}

enum DUTY_TYPE {
  Trip,
  Acy
}

class IobConnector {

  final String username;
  final String password;
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
    "crewId": "",
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

  IobConnector(this.username, this.password);
  
  /// Used for initial connection, set token and cookie for the session.
  /// Returns the check-in list in a String to be parsed (see Parsers.dart)
  /// In the case of any failure, throws a WyobException subclass.
  Future<String> init() async {
    print("Connecting to IOB...");
    client = new http.Client();
    http.Response iobResponse;

    if (username == '' || password == '' || username == null || password == null)
      throw WyobExceptionCredentials('Credentials not set in IobConnector');

    try {
      iobResponse = await client.get(landingUrl);
    } on Exception catch (e) {
      throw WyobExceptionOffline(
          'OFFLINE mode. For info, error: ' + e.toString());
    }

    print("Connected with status code: " + iobResponse.statusCode.toString());
    String landingBodyWithToken = iobResponse.body;
    this.token = tokenRegExp.firstMatch(landingBodyWithToken).group(1);
    print('Token: ' + token);


    String loginHeaders;
    try {
      loginHeaders = (
        await client.post(
          loginFormUrl,
          body: {"username": username, "password": password, "token": token}
        )
      ).headers.toString();
      this.cookie = cookieRegExp.firstMatch(loginHeaders).group(1);
    } on Exception catch (e) {
      throw WyobExceptionLogIn('IobConnector failed to log in');
    }

    print('Cookie: ' + this.cookie);

    http.Response checkinListResponse =
      await client.get(checkinListUrl, headers: {"Cookie": cookie});
    this.bigCookie = checkinListResponse.headers["set-cookie"];

    print('Big Cookie: ' + this.bigCookie);

    String checkinList = checkinListResponse.body;

    return checkinList;
  }

  Future<String> getGanttMainTable() async {
    /// gets the GANTT  main table data and change it into a String to be parsed.

    crewSelectForm['org.apache.struts.taglib.html.TOKEN'] = this.token;
    crewSelectForm['action'] = 'fastcrewonly';
    crewSelectForm['crewId'] = this.username;

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

  Future<String> getFromToGanttDuties(DateTime from, DateTime to) async {
    // Gets the Gantt duties references between [from] and [to],
    // MAX 30 DAYS !!!
    if (this.cookie == null || this.bigCookie == null) {
      await this.init();
    }

    if (this.personId == null) {
      await this.getGanttMainTable();
    }

    String today = DateFormat('dMMMy').format(DateTime.now());
    String fromdtm = DateFormat('dMMMy').format(from);
    String todtm = DateFormat('dMMMy').format(to);

    String url = "https://fltops.omanair.com/mlt/crewganttpreaction.do?" +
      "oldfromdtm=" + fromdtm +
      "&oldtodtm=" + todtm +
      "&persons=" + personId + ","
      "&mlt.baseStation=MCT"
      "&mlt.utcLocal=Utc"
      "&crwSelectToDate=" + today +
      "&crwFltToDate=" + today +
      "&crwStnToDate=" + today +
      "&crwStnToTime=23:59"
      "&fromdtm=" + fromdtm +
      "&todtm=" + todtm +
      "&command=Go";

    String oldurl = fromToGanttUrl + 'fromdtm=' + fromdtm + '&todtm=' + todtm +
        '&persons=' + personId + ',&mlt.baseStation=MCT&mlt.utcLocal=Utc';

    http.Response response = await client.get(
        url, headers: {"Cookie": cookie + ";" + bigCookie});

    response = await client.get(
        ganttUrl, headers: {"Cookie": cookie + ";" + bigCookie, "referer": url});

    return response.body;
  }

  Future<String> getGanttDutyTripLocal(String personId, String persAllocId) {
    return _getGanttDuty(personId, persAllocId, TIME_ZONE.Local, DUTY_TYPE.Trip);
  }

  Future<String> getGanttDutyTripUtc(String personId, String persAllocId) {
    return _getGanttDuty(personId, persAllocId, TIME_ZONE.Utc, DUTY_TYPE.Trip);
  }

  Future<String> getGanttDutyAcyLocal(String personId, String persAllocId) {
    return _getGanttDuty(personId, persAllocId, TIME_ZONE.Local, DUTY_TYPE.Acy);
  }

  Future<String> getGanttDutyAcyUtc(String personId, String persAllocId) {
    return _getGanttDuty(personId, persAllocId, TIME_ZONE.Utc, DUTY_TYPE.Acy);
  }

  Future<String> _getGanttDuty(String personId, String persAllocId,
      TIME_ZONE tz, DUTY_TYPE dt) async {

    String url = (dt == DUTY_TYPE.Trip ? ganttDutyTripUrl : ganttDutyAcyUrl)
        .replaceAll("REPLACEPERSONID", personId)
        .replaceAll("REPLACEPERSALLOCID", persAllocId);

    url += (tz == TIME_ZONE.Local ? 'Local' : 'Utc');

    http.Response response = await client.get(
        url, headers: {"Cookie": cookie + ";" + bigCookie});

    return response.body;
  }
}
