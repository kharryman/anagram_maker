// results.dart

//import 'dart:convert';
//import 'dart:math';

//import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
//import 'package:flutter_html/flutter_html.dart';
import 'main.dart';

// ignore: must_be_immutable
class WordsPage extends StatelessWidget {
  final bool isMultipleWords;
  final String lastInput;
  final List<dynamic> words;

  WordsPage(
      {required this.isMultipleWords,
      required this.lastInput,
      required this.words});
  String helpText = '<strong style="font-style:italic;">:</strong><br />';

  @override
  Widget build(BuildContext context) {
    //print("WordsPage isMultipleWords = $isMultipleWords");
    int numberAnagrams = 0;
    if (isMultipleWords == true) {
      Map<int, List<List<dynamic>>> myMap =
          Map<int, List<List<dynamic>>>.from(words[0]);
      for (int key in myMap.keys) {
        numberAnagrams += myMap[key]!.length;
      }
    } else {
      numberAnagrams = words.length;
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Anagram Maker'),
          actions: <Widget>[MyPopup()],
        ),
        body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Visibility(
                visible: lastInput.trim() != '',
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                      "Found $numberAnagrams anagrams for input '$lastInput (${lastInput.length} letters)':"),
                ),
              ),
              Expanded(
                  child: GestureDetector(
                onTap: () {
                  //print("BODY UNFOCUSSING");
                },
                child: SizedBox(
                  width: double.infinity,
                  child: isMultipleWords == true
                      ? ListMultiple(words: words)
                      : ListSingle(words: words),
                ),
              ))
            ]));
  }
}

class ListSingle extends StatelessWidget {
  final List<dynamic> words;
  ListSingle({required this.words});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    //print("ListSingle words = $words");
    return ListView(children: <Widget>[
      for (var i = 0; i < words.length; i++)
        Flex(
          direction: Axis.horizontal,
          children: [
            Flexible(
              flex: 1,
              child: Card(
                color: theme.colorScheme.surface, // ← And also this.
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .06,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                          child: Text("${i + 1})",
                              softWrap: true, style: TextStyle(fontSize: 12.0)),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        // Handle the click action here
                        // For example, you can navigate to a new screen or perform some other action.
                        //print("BODY UNFOCUSSING");
                        //print("Copy word, '${words[i]["word"]}' clicked!");
                        MyHomePage().copyToClipboard(context, words[i]["word"]);
                      },
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * .15,
                        child: Text(words[i]["word"],
                            softWrap: true, style: TextStyle(fontSize: 12.0)),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        // Handle the click action here
                        // For example, you can navigate to a new screen or perform some other action.
                        //print("BODY UNFOCUSSING");
                        //print("Copy formatted word, '${words[i]["formattedWord"]}' clicked!");
                        MyHomePage().copyToClipboard(
                            context, words[i]["formattedWord"]);
                      },
                      child: SizedBox(
                          width: MediaQuery.of(context).size.width * .15,
                          child: Text.rich(TextSpan(children: [
                            TextSpan(
                                text: "(", style: TextStyle(fontSize: 10.0)),
                            TextSpan(
                                text: words[i]["formattedWord"]
                                    .toString()
                                    .substring(
                                        0, words[i]["word"].toString().length)
                                    .toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10.0)),
                            TextSpan(
                                text: words[i]["formattedWord"]
                                    .toString()
                                    .substring(
                                        words[i]["word"].toString().length)
                                    .toString(),
                                style: TextStyle(fontSize: 10)),
                            TextSpan(text: ")", style: TextStyle(fontSize: 10)),
                          ]))),
                    ),
                    InkWell(
                      onTap: () {
                        // Handle the click action here
                        // For example, you can navigate to a new screen or perform some other action.
                        //print("BODY UNFOCUSSING");
                        //print("Definition for '${words[i]["word"]}', copy '${words[i]["definition"]}'' clicked!");
                        MyHomePage()
                            .copyToClipboard(context, words[i]["definition"]);
                      },
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * .56,
                        child: Text(
                          words[i]["definition"],
                          softWrap: true,
                          style: TextStyle(fontSize: 12.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
    ]);
  }
}

class ListMultiple extends StatelessWidget {
  final List<dynamic> words;
  ListMultiple({required this.words});
  @override
  Widget build(BuildContext context) {
    //print("ListMultiple words = $words");
    //ADDED AS FIRST ARRAY OF List<dynamic> TO BE COMPATIBLE WITH ListSingle:
    Map<int, List<List<dynamic>>> myWords =
        (List<Map<int, List<List<dynamic>>>>.from(words))[0];
    final theme = Theme.of(context);
    return ListView(children: <Widget>[
      for (int key in myWords.keys)
        Flex(direction: Axis.horizontal, children: [
          Flexible(
              flex: 1,
              child: Card(
                  color: theme.colorScheme.surface, // ← And also this.
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("$key-word Anagrams: (${myWords[key]!.length})",
                            softWrap: true,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12.0)),
                        if (myWords[key]!.isEmpty)
                          Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)),
                              child:
                                  Column(children: [Text("No words found.")]))
                        else
                          for (int i = 0; i < myWords[key]!.length; i++)
                            Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)),
                              child: Column(
                                children: [
                                  for (int j = 0;
                                      j < myWords[key]![i].length;
                                      j++)
                                    Row(children: [
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .06,
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 0, 5, 0),
                                            child: Text(
                                                (j == 0
                                                    ? (i + 1).toString() +
                                                        (") ").toString()
                                                    : ""),
                                                softWrap: true,
                                                style:
                                                    TextStyle(fontSize: 12.0)),
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          // Handle the click action here
                                          // For example, you can navigate to a new screen or perform some other action.
                                          //print("BODY UNFOCUSSING");
                                          //print("Copy word, '${myWords[key]![i][j]["word"]}' clicked!");
                                          MyHomePage().copyToClipboard(context,
                                              myWords[key]![i][j]["word"]);
                                        },
                                        child: SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .15,
                                          child: Text(
                                            myWords[key]![i][j]["word"],
                                            softWrap: true,
                                            style: TextStyle(fontSize: 12.0),
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          // Handle the click action here
                                          // For example, you can navigate to a new screen or perform some other action.
                                          //print("BODY UNFOCUSSING");
                                          //print("Copy formatted word, '${myWords[key]![i][j]["formattedWord"]}' clicked!");
                                          MyHomePage().copyToClipboard(
                                              context,
                                              myWords[key]![i][j]
                                                  ["formattedWord"]);
                                        },
                                        child: SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .15,
                                            child:
                                                Text.rich(TextSpan(children: [
                                              TextSpan(
                                                  text: "(",
                                                  style: TextStyle(
                                                      fontSize: 10.0)),
                                              TextSpan(
                                                  text: myWords[key]![i][j]
                                                          ["formattedWord"]
                                                      .toString()
                                                      .substring(
                                                          0,
                                                          int.parse(
                                                              myWords[key]![i]
                                                                  [j]["match"]))
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 10.0)),
                                              TextSpan(
                                                  text: myWords[key]![i][j]
                                                          ["formattedWord"]
                                                      .toString()
                                                      .substring(int.parse(
                                                          myWords[key]![i][j]
                                                              ["match"]))
                                                      .toString(),
                                                  style:
                                                      TextStyle(fontSize: 10)),
                                              TextSpan(
                                                  text: ")",
                                                  style:
                                                      TextStyle(fontSize: 10)),
                                            ]))),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          // Handle the click action here
                                          // For example, you can navigate to a new screen or perform some other action.
                                          //print("BODY UNFOCUSSING");
                                          //print("Definition for '${myWords[key]![i][j]["word"]}', copy '${myWords[key]![i][j]["definition"]}'' clicked!");
                                          MyHomePage().copyToClipboard(
                                              context,
                                              myWords[key]![i][j]
                                                  ["definition"]);
                                        },
                                        child: SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .56,
                                          child: Text(
                                            myWords[key]![i][j]["definition"],
                                            softWrap: true,
                                            style: TextStyle(fontSize: 12.0),
                                          ),
                                        ),
                                      ),
                                    ]),
                                ],
                              ),
                            ),
                      ])))
        ])
    ]);
  }
}
