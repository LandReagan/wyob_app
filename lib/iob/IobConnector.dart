import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart' as http_io;
import 'package:logger/logger.dart';

import 'package:wyob/WyobException.dart';
import 'package:wyob/iob/IobDutyFactory.dart';
import 'package:wyob/iob/IobConnectorData.dart';


/// URLs
String landingUrl =
    'https://fltops.omanair.com/mlt/filter.jsp?window=filter&loggedin=false';
String loginFormUrl = 'https://fltops.omanair.com/mlt/loginpostaction.do';
String checkinListUrl = 'https://fltops.omanair.com/mlt/checkinlist.jsp';
String mltCrewMainUrl = 'https://fltops.omanair.com/mlt/mltcrewmain.jsp';
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

  String username;
  String password;

  DateTime sessionStart;
  String token;
  String cookie;
  String bigCookie;
  String personId;
  http.Client client;
  CONNECTOR_STATUS status;
  ValueNotifier<IobConnectorData> onDataChange;

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

  List<String> acknowledgeDutyIds = [];

  IobConnector() : status = CONNECTOR_STATUS.OFF {
    onDataChange =
        ValueNotifier<IobConnectorData>(IobConnectorData(CONNECTOR_STATUS.OFF));
  }

  /// Boolean to check if reinitialization of connection is required
  bool get resetRequired {
    if (sessionStart == null) return false;
    return DateTime.now().difference(sessionStart) > Duration(minutes: 10);
  }
  
  /// Used for initial connection, set token and cookie for the session.
  /// Returns the check-in list in a String to be parsed (see Parsers.dart)
  /// In the case of any failure, throws a WyobException subclass.
  Future<String> init() async {

    Logger().i("Connecting to IOB...");
    this.changeStatus(CONNECTOR_STATUS.CONNECTING);
    client = this.getBadClient();
    http.Response iobResponse;

    if (username == '' || password == '' || username == null ||
        password == null) {
      this.changeStatus(CONNECTOR_STATUS.ERROR);
      throw WyobExceptionCredentials('Credentials not set in IobConnector');
    }

    try {
      iobResponse = await client.get(landingUrl);
    } on Exception catch (e) {
      this.changeStatus(CONNECTOR_STATUS.OFFLINE);
      throw WyobExceptionOffline(
          'OFFLINE mode. For info, error: ' + e.toString());
    }

    this.changeStatus(CONNECTOR_STATUS.CONNECTED);
    Logger().d("Connected with status code: " + iobResponse.statusCode.toString());
    String landingBodyWithToken = iobResponse.body;
    this.token = tokenRegExp.firstMatch(landingBodyWithToken).group(1);
    Logger().d('Token: ' + token);


    String loginHeaders;
    try {
      loginHeaders = (
        await client.post(
          loginFormUrl,
          body: {"username": username, "password": password, "token": token}
        )
      ).headers.toString();
      this.cookie = cookieRegExp.firstMatch(loginHeaders).group(1);
    } on Exception {
      this.changeStatus(CONNECTOR_STATUS.LOGIN_FAILED);
      throw WyobExceptionLogIn('IobConnector failed to log in');
    }

    Logger().d('Cookie: ' + this.cookie);

    http.Response checkinListResponse =
      await client.get(checkinListUrl, headers: {"Cookie": cookie});
    this.bigCookie = checkinListResponse.headers["set-cookie"];

    this.changeStatus(CONNECTOR_STATUS.AUTHENTIFIED);

    Logger().d('Big Cookie: ' + this.bigCookie);

    sessionStart = DateTime.now();

    String checkinList = checkinListResponse.body;

    this.acknowledgeDutyIds = IobDutyFactory.getAcknowledgeDutyIds(checkinList);

    return checkinList;
  }

  void setCredentials(String username, String password) {
    this.username = username;
    this.password = password;
  }

  Future<String> getGanttMainTable() async {



    /// gets the GANTT  main table data and change it into a String to be parsed.

    this.changeStatus(CONNECTOR_STATUS.FETCHING_GANTT_TABLE);

    Map<String, String> form = Map.from(crewSelectForm);

    form['org.apache.struts.taglib.html.TOKEN'] = this.token;
    form['action'] = 'fastcrewonly';
    form['crewId'] = this.username;

    http.Response response = await client.post(
        crewSelectUrl,
        headers: {"Cookie": cookie + ";" + bigCookie},
        body: form
    );

    String crewSelectBody = response.body;
    RegExp personRE = RegExp(r"crewganttnavigator\.jsp\?persons=(\d+)");
    Match personM = personRE.firstMatch(crewSelectBody);

    if (personM == null || personM[1] == null) {
      this.changeStatus(CONNECTOR_STATUS.LOGIN_FAILED);
      throw WyobExceptionLogIn("Login problem, password may be wrong!");
    } else {
      personId = personM[1];
    }

    response = await client.get(
        ganttUrl,
        headers: {"Cookie": cookie + ";" + bigCookie}
    );

    return response.body;
  }

  // Gets the Gantt duties references between [from] and [to],
  // MAX 30 DAYS !!!
  Future<String> getFromToGanttDuties(DateTime from, DateTime to) async {

    if (resetRequired || cookie == null || bigCookie == null) {
      try {
        await this.init();
      } on WyobExceptionOffline {
        Logger().i("OFFLINE request for crew information");
        this.changeStatus(CONNECTOR_STATUS.OFFLINE);
        return null;
      } on WyobException {
        Logger().w("Unhandled internal WYOB Exception");
        this.changeStatus(CONNECTOR_STATUS.ERROR);
        return null;
      } on Exception {
        this.changeStatus(CONNECTOR_STATUS.ERROR);
        Logger().w("Unhandled Exception, unknown from WYOB!");
        return null;
      }
    }

    if (this.personId == null) {
      await getGanttMainTable();
    } else {
      changeStatus(CONNECTOR_STATUS.FETCHING_GANTT_TABLE);
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

    http.Response response = await client.get(
        url, headers: {"Cookie": cookie + ";" + bigCookie});

    response = await client.get(
        ganttUrl, headers: {"Cookie": cookie + ";" + bigCookie, "referer": url});

    changeStatus(CONNECTOR_STATUS.OFF);

    return response.body;
  }

  Future<String> getGanttDutyTripLocal(
      int dutyIndex,
      int dutyTotalNumber,
      String personId,
      String persAllocId) {

    this.onDataChange.value = IobConnectorData(
        CONNECTOR_STATUS.FETCHING_DUTY, dutyIndex, dutyTotalNumber);

    Logger().i("Duty: " + dutyIndex.toString() + "/" + dutyTotalNumber.toString());

    return _getGanttDuty(personId, persAllocId, TIME_ZONE.Local, DUTY_TYPE.Trip);
  }

  Future<String> getGanttDutyTripUtc(String personId, String persAllocId) {
    return _getGanttDuty(personId, persAllocId, TIME_ZONE.Utc, DUTY_TYPE.Trip);
  }

  Future<String> getGanttDutyAcyLocal(
      int dutyIndex,
      int dutyTotalNumber,
      String personId,
      String persAllocId) {

    this.onDataChange.value = IobConnectorData(
        CONNECTOR_STATUS.FETCHING_DUTY, dutyIndex, dutyTotalNumber);

    Logger().i("Duty: " + dutyIndex.toString() + "/" + dutyTotalNumber.toString());

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

    //changeStatus(CONNECTOR_STATUS.OFF);

    return response.body;
  }

  Future<String> getCrew(DateTime day, String flightNumber) async {

    if (resetRequired || cookie == null || bigCookie == null) {
      try {
        await this.init();
      } on WyobExceptionOffline {
        Logger().i("OFFLINE request for crew information");
        this.changeStatus(CONNECTOR_STATUS.OFFLINE);
        return null;
      } on WyobException {
        Logger().w("Unhandled internal WYOB Exception");
        this.changeStatus(CONNECTOR_STATUS.ERROR);
        return null;
      } on Exception {
        this.changeStatus(CONNECTOR_STATUS.ERROR);
        Logger().w("Unhandled Exception, unknown from WYOB!");
        return null;
      }
    }

    var flightNumberRegexp = RegExp(r'\d+');
    flightNumber = flightNumberRegexp.firstMatch(flightNumber)[0];

    Map<String, String> form = Map.from(crewSelectForm);

    form['org.apache.struts.taglib.html.TOKEN'] = this.token;
    form['action'] = 'addflight';
    form['crewId'] = this.username;

    form['addflight'] = 'Add';
    form['fltDate'] = DateFormat("ddMMMyyyy").format(day);
    form['fltToDate'] = DateFormat("ddMMMyyyy").format(day);
    form['tripAcyFromDt'] = DateFormat("ddMMMyyyy").format(day);
    form['tripAcyToDt'] = DateFormat("ddMMMyyyy").format(day);
    form['fromDate'] = DateFormat("ddMMMyyyy").format(day);
    form['toDate'] = DateFormat("ddMMMyyyy").format(day);
    form['cxCd'] = "WY";
    form['fltNo'] = flightNumber;

    String crewSelectBody;
    http.Response response;
    try {
      this.changeStatus(CONNECTOR_STATUS.FETCHING_CREW);
      response = await client.post(
          crewSelectUrl,
          headers: {"Cookie": cookie + ";" + bigCookie},
          body: form
      );
      crewSelectBody = response.body;
    } on WyobExceptionOffline {
      this.changeStatus(CONNECTOR_STATUS.OFFLINE);
      Logger().i("Offline attempt to get crew information");
    } on Exception {
      this.changeStatus(CONNECTOR_STATUS.ERROR);
      Logger().w("Unknown exception happened while fetching Crew information...");
    }

    // Clear the page
    form['noOfRows'] = '12';
    form['currentRow'] = '0';
    form['startOfPageRow'] = '0';
    form['endOfPageRow'] = '12';
    form['remove1'] = 'keep';
    form['action'] = 'Clear';
    form['ganttSelectionType'] = 'Specified Dates';
    form['ganttStartDate'] = DateFormat("ddMMMyyyy").format(day);
    form['ganttEndDate'] = DateFormat("ddMMMyyyy").format(day);
    form['mlt.baseStation'] = 'MCT';
    form['mlt.utcLocal'] = 'Local';
    form['mlt.baseAction'] = 'addflight';
    form['baseFormAction'] = 'addflight';
    form['crwSelectToDate'] = DateFormat("ddMMMyyyy").format(day);
    form['crwFltToDate'] = DateFormat("ddMMMyyyy").format(day);
    form['crwStnToDate'] = DateFormat("ddMMMyyyy").format(day);
    form['crwStnToTime'] = '23:59';

    try {
      response = await client.post(
          crewSelectUrl,
          headers: {"Cookie": cookie + ";" + bigCookie},
          body: form
      );
    } on WyobExceptionOffline {
      this.changeStatus(CONNECTOR_STATUS.OFFLINE);
      Logger().i("Offline attempt to get crew information");
    } on Exception {
      this.changeStatus(CONNECTOR_STATUS.ERROR);
      Logger().w("Unknown exception happened while fetching Crew information...");
    }

    this.changeStatus(CONNECTOR_STATUS.OFF);

    return crewSelectBody;
  }

  void changeStatus(CONNECTOR_STATUS newStatus) {
    if (newStatus != null) {
      this.status = newStatus;
      if (onDataChange != null) {
        onDataChange.value = IobConnectorData(newStatus);
      }
    }
    Logger().i(newStatus);
  }

  bool _certificateCheck(X509Certificate cert, String host, int port) =>
    host == 'fltops.omanair.com';

  // Bad certificate client
  http.Client getBadClient() {
    var ioClient = new HttpClient()
        ..badCertificateCallback = _certificateCheck;
    return new http_io.IOClient(ioClient);
  }
}
