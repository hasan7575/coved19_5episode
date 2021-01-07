import 'package:covid19app/countryPersianName.dart';
import 'package:covid19app/screens/showSingleCountry.dart';
import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ShowCountries extends StatefulWidget {
  @override
  _ShowCountriesState createState() => _ShowCountriesState();
}

class _ShowCountriesState extends State<ShowCountries> {
  List countries = new List();
  List items = new List();
  bool loading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _setData();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  title: new Text('لیست تمام کشور ها'),
                  backgroundColor: Colors.indigo,
                )
              ];
            },
            body: _buildBody()),
      ),
    );
  }

  Widget _buildBody() {
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
            padding: EdgeInsets.only(top: 15, left: 8, right: 8),
            child: TextField(
              onChanged: (String value) {
                items.clear();
                if (value.isEmpty) {
                  items.addAll(countries);
                } else {
                  countries.forEach((element) {
                    if (element['Country']
                            .toLowerCase()
                            .contains(value.toLowerCase()) ||
                        element['persianName']
                            .toLowerCase()
                            .contains(value.toLowerCase())) {
                      items.add(element);
                    }
                  });
                }

                setState(() {});
              },
              decoration: new InputDecoration(
                  labelText: "جستجو",
                  hintText: "جستجو",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25))),
            ),
          ),
          new Expanded(
            child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: items.length,
                itemBuilder: (BuildContext context, int index) {
                  var country = items[index];
                  return Container(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: new Material(
                      elevation: 3,
                      child: new ListTile(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return new ShowSingleCountry(
                              county: country,
                            );
                          }));
                        },
                        title: new Text('${country['persianName']}'),
                        subtitle: new Text('${country['Slug']}'),
                        trailing: new Container(
                          child: Image.asset(
                            "assets/flags/${country['ISO2'].toLowerCase()}.png",
                            width: 60,
                            height: 60,
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

    // https://developers.google.com/books/docs/overview
    var url = 'https://api.covid19api.com/countries';

    // Await the http get response, then decode the json-formatted response.
    var response = await http.get(url);
    if (response.statusCode == 200) {
      List jsonResponse = convert.jsonDecode(response.body);
      jsonResponse.forEach((element) {
        element['persianName'] =
            convertCountryISO2ToPersianName[element['ISO2']];
      });
      countries = jsonResponse;
      items.addAll(countries);
      setState(() {
        loading = false;
      });
    } else {}
  }
}
