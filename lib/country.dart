import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:CovidApp/model/country_model.dart';

class CountryPage extends StatefulWidget {
  @override
  _CountryPageState createState() => _CountryPageState();
}

class _CountryPageState extends State<CountryPage> {
  Dio dio = Dio();
  Response response;
  List<CountryData> listCountries = [];
  List<CountryData> searchList = [];
  var tempList;
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    getData();

    initValue();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: TextField(
              controller: controller,
              onChanged: (value) {
                searchCountry(value);
              },
              style: TextStyle(color: Colors.grey),
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Colors.white),
                  hintText: 'Search',
                  hintStyle: TextStyle(color: Colors.grey),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xff1a1b1e), width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 1))),
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: getData(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.none &&
                    snap.data == null) {
                  return Container(
                    child: Text('No connection'),
                  );
                } else if (snap.connectionState == ConnectionState.waiting) {
                  return Container(
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(),
                  );
                } else if (snap.connectionState == ConnectionState.done) {
                  return createListCountries();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Column createListCountries() {
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView.builder(
            itemCount: searchList.length,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: InkWell(
                  onTap: () async {
                    var res = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: Text(
                                  '${searchList[index].country.toUpperCase()}'),
                              content: Text(
                                  'Cases per one million: ${searchList[index].casesPerOneMillion}\n'
                                  'Deaths per one million: ${searchList[index].deathsPerOneMillion}\n'
                                  'Total tests: ${searchList[index].totalTests}'),
                            ));
                  },
                  child: Container(
                    color: Color(0xff1a1b1e),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          child: Text(
                            '${searchList[index].country}',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          'Cases: ${searchList[index].cases} | Today: ${searchList[index].todayCases} | Active: ${searchList[index].active}',
                          style: TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                        Text(
                          'Deaths: ${searchList[index].deaths} | Today: ${searchList[index].todayDeaths}',
                          style: TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                        Text(
                          'Recovered: ${searchList[index].recovered} | Critical: ${searchList[index].critical}',
                          style: TextStyle(color: Colors.grey, fontSize: 15),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  initValue() async {
    var res = await getData();
    if (res != null) {
      searchList = listCountries;
    }
  }

  getData() async {
    try {
      response =
          await dio.get('https://coronavirus-19-api.herokuapp.com/countries');
      if (response.data != null) {
        listCountries = [];
        tempList = response.data;
        tempList.forEach((element) {
          CountryData newCountries = CountryData.fromJson(element);
          listCountries.add(newCountries);
        });
        print('list country: ${listCountries.length}');
        return response.data;
      }
    } catch (e) {
      return null;
    }
  }

  searchCountry(String text) {
    if (text == '') {
      setState(() {
        searchList = listCountries;
      });
    } else {
      setState(() {
        searchList = [];
      });
      listCountries.forEach((element) {
        if (element.country.toLowerCase().contains(text.toLowerCase())) {
          searchList.add(element);
        }
      });
      setState(() {});
    }
  }
}
