import 'package:flutter/material.dart';
import 'package:flutter_dropdown_search/flutter_dropdown_search.dart';

void main() {
  runApp(MyApp());
}

const mockResults = [
  'John Doe',
  'Paul',
  'Fred',
  'Brian',
  'John',
  'Thomas',
  'Nelly',
  'Marie',
];

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController textEditingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              OptionsInput(
                initOptions: mockResults,
                focusNode: _focusNode,
                textEditingController: textEditingController,
                inputDecoration:
                    InputDecoration(border: UnderlineInputBorder()),
                onChanged: (data) {
                  setState(() {
                    textEditingController.text = data;
                    textEditingController.selection =
                        TextSelection.fromPosition(TextPosition(
                            offset: textEditingController.text.length));
                    FocusScope.of(context).requestFocus(FocusNode());
                  });
                },
                suggestionsBoxMaxHeight: 160,
                findSuggestions: (String query) {
                  if (query.isNotEmpty) {
                    var lowercaseQuery = query.toLowerCase();
                    return mockResults.where((profile) {
                      return profile
                              .toLowerCase()
                              .contains(query.toLowerCase()) ||
                          profile.toLowerCase().contains(query.toLowerCase());
                    }).toList(growable: false)
                      ..sort((a, b) => a
                          .toLowerCase()
                          .indexOf(lowercaseQuery)
                          .compareTo(b.toLowerCase().indexOf(lowercaseQuery)));
                  }
                  return mockResults;
                },
                borderRadius: 8,
                suggestionBuilder: (context, state, profile) {
                  return ListTile(
                    key: ObjectKey(profile),
                    title: Text(profile),
                    onTap: () => state.selectSuggestion(profile),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
