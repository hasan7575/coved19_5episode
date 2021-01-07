import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linear_datepicker/flutter_datepicker.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:persian_date/persian_date.dart';

class ShowSingleCountry extends StatefulWidget {
  final Map county;

  ShowSingleCountry({this.county});

  @override
  _ShowSingleCountryState createState() => _ShowSingleCountryState();
}

class _ShowSingleCountryState extends State<ShowSingleCountry> {
  List countries = new List();
  List items = new List();
  bool loading = true;
  var toDate;
  DateTime date = DateTime.now();
  var from;
  PersianDate persianDate = PersianDate();
  String selectedUserDate;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    toDate = DateTime.now().toString().split(" ")[0].toString();
    from = new DateTime(date.year, date.month - 1, date.day)
        .toString()
        .split(" ")[0];
    _setData();
  }

  @override
  Widget build(BuildContext context) {
    print(from);
    print(toDate);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: _buildBody(),
        appBar: AppBar(
            title: new Text('${widget.county['persianName']}'),
            backgroundColor: Colors.indigo,
            actions: [
              new Container(
                padding: EdgeInsets.only(left: 10),
                child: Image.asset(
                  "assets/flags/${widget.county['ISO2'].toLowerCase()}.png",
                  width: 60,
                  height: 60,
                ),
              ),
            ]),
      ),
    );
  }

  Widget _buildBody() {
//    print(items.last);
    if (loading) {
      return SpinKitRotatingCircle(
        color: Colors.indigo,
        size: 60.0,
      );
    }
    return new Container(
      child: new Column(
        children: [
          new Container(
            color: Color(0xff483F97),
            child: new Column(
              children: [
                new Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      new GestureDetector(
                        onTap: () {
                          showDateDialog(type: "from");
                        },
                        child: Row(
                          children: [
                            new Text(
                              '${persianDate.gregorianToJalali("${from}T00:19:54.000Z", "yyyy-m-d")}',
                              style: new TextStyle(color: Colors.white),
                            ),
                            new Icon(
                              Icons.arrow_drop_down,
                              color: Colors.white,
                            )
                          ],
                        ),
                      ),
                      new GestureDetector(
                        onTap: () {
                          showDateDialog(type: "to");
                        },
                        child: Row(
                          children: [
                            new Text(
                              '${persianDate.gregorianToJalali("${toDate}T00:19:54.000Z", "yyyy-m-d")}',
                              style: new TextStyle(color: Colors.white),
                            ),
                            new Icon(
                              Icons.arrow_drop_down,
                              color: Colors.white,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                new Container(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  height: 75,
                  child: new Row(
                    children: [
                      ShowDetailsCard(
                        title: 'Active',
                        number: items.last['Active'],
                        color: Color(0xffFFB259),
                      ),
                      ShowDetailsCard(
                        title: 'Deaths',
                        number: items.last['Deaths'],
                        color: Color(0xffFF5958),
                      ),
                    ],
                  ),
                ),
                new Container(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  height: 75,
                  child: new Row(
                    children: [
                      ShowDetailsCard(
                        title: 'Confirmed',
                        number: items.last['Confirmed'],
                        color: Color(0xff4AD97A),
                      ),
                      ShowDetailsCard(
                        title: 'Recovered',
                        number: items.last['Recovered'],
                        color: Color(0xff4CB5FF),
                      ),
                      ShowDetailsCard(
                        title: 'Lat',
                        number: items.last['Lat'],
                        color: Color(0xff8F59FF),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          new Expanded(
            child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: items.length,
                itemBuilder: (BuildContext context, int index) {
                  var country = items[index];
                  if (index == 0) {
                    return Container();
                  }
                  String dayDeaths;
                  String dayConfirmed;
                  dayDeaths = (country['Deaths'] - items[index - 1]['Deaths'])
                      .toString();
                  dayConfirmed =
                      (country['Confirmed'] - items[index - 1]['Confirmed'])
                          .toString();
                  return Container(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: new Material(
                      elevation: 3,
                      shadowColor: Colors.indigo.withOpacity(0.3),
                      child: new ListTile(
                        title: new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            new Text(
                              'مبتلایان‌جدید: $dayConfirmed',
                              style: new TextStyle(fontSize: 13),
                            ),
                            new Text(
                              'بیماران‌فعال: ${country['Active']}',
                              style: new TextStyle(fontSize: 13),
                            ),
                            new Text(
                              'جان‌باختگان: $dayDeaths',
                              style: new TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                        subtitle: new Text(
                          'تاریخ: ${persianDate.gregorianToJalali(country['Date'], "d-mm-yyyy")}',
                          style: new TextStyle(
                            height: 1.8,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
          )
        ],
      ),
    );
  }

  void _setData() async {
    setState(() {
      loading=true;
    });
    // https://developers.google.com/books/docs/overview
//    var url = 'https://api.covid19api.com/total/dayone/country/${widget.county['Country']}';
    var url =
        "https://api.covid19api.com/country/iran?from=${from}T00:00:00Z&to=${toDate}T00:00:00Z";

    // Await the http get response, then decode the json-formatted response.
    print(url);
    items.clear();
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      countries = jsonResponse;
      items.addAll(jsonResponse);
      setState(() {
        loading = false;
      });
    } else {}
  }

  void showDateDialog({@required String type}) {
    showDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: new Text(
              type == "from"
                  ? 'انتخاب شروع بازه زمانی'
                  : 'انتخاب انتهای بازه زمانی',
              style: TextStyle(fontSize: 14, fontFamily: 'Yekan'),
            ),
            content: new Container(
              margin: EdgeInsets.only(top: 13),
              child: LinearDatePicker(
                  startDate: "1398/12/10",
                  //yyyy/mm/dd
                  endDate:
                      "${persianDate.gregorianToJalali(DateTime.now().toString(), "yyyy/m/d")}",
                  initialDate: persianDate.gregorianToJalali(type=="from"?from:toDate,'yyyy/m/d'),
                  dateChangeListener: (String selectedDate) {
                    selectedUserDate = selectedDate;
                  },
                  showDay: true,
                  //false -> only select year & month
                  fontFamily: 'Yekan',
                  showLabels: true,
                  // to show column captions, eg. year, month, etc.
                  textColor: Colors.black,
                  selectedColor: Colors.deepOrange,
                  unselectedColor: Colors.blueGrey,
                  yearText: "سال",
                  monthText: "ماه",
                  dayText: "روز",
                  columnWidth: 60,
                  isJalaali: true // false -> Gregorian
                  ),
            ),
            actions: [
              FlatButton(
                  onPressed: () {
                    print(
                        'selected date is $selectedUserDate  ${selectedUserDate.split("/")}');
                    int selectedYear =
                        int.parse(selectedUserDate.split("/")[0]);
                    int selectedMonth =
                        int.parse(selectedUserDate.split("/")[1]);
                    int selectedDay = int.parse(selectedUserDate.split("/")[2]);
                    if (type == 'from') {
                      from = persianDate
                          .jalaliToGregorian(
                              DateTime(selectedYear, selectedMonth, selectedDay)
                                  .toString())
                          .toString()
                          .split(" ")[0];
                    } else {
                      toDate = persianDate
                          .jalaliToGregorian(
                              DateTime(selectedYear, selectedMonth, selectedDay)
                                  .toString())
                          .toString()
                          .split(" ")[0];
                    }
//                    setState(() {});
                  _setData();
                    Navigator.pop(context);

                  },
                  child: new Text('ادامه')),
              FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: new Text('لغو')),
            ],
          );
        });
  }
}

// ignore: must_be_immutable
class ShowDetailsCard extends StatelessWidget {
  final Color color;
  String title;
  var number;

  ShowDetailsCard({@required this.color, this.number, this.title});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Expanded(
        child: new Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      decoration: new BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(10)),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          new Text(
            '$title',
            style: new TextStyle(color: Colors.white),
          ),
          new Text(
            '${FlutterMoneyFormatter(amount: double.parse("$number")).output.nonSymbol}',
            style: new TextStyle(color: Colors.white),
          )
        ],
      ),
    ));
  }
}
