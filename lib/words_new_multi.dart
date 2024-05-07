// results.dart

import 'dart:convert';
import 'dart:math';

import 'package:anagram_maker/menu.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'main.dart';

// ignore: must_be_immutable
class WordsPageNewMulti extends StatefulWidget {
  final bool isMultipleWords;
  final String lastInput;
  final int countAnagrams;
  final Map<String, dynamic> words;

  WordsPageNewMulti(
      {required this.isMultipleWords,
      required this.lastInput,
      required this.countAnagrams,
      required this.words});

  @override
  // ignore: library_private_types_in_public_api
  State<WordsPageNewMulti> createState() => WordsPageNewMultiState();
}

class WordsPageNewMultiState extends State<WordsPageNewMulti> {
  String helpText = '<strong style="font-style:italic;">:</strong><br />';
  Map<String, dynamic> words = {};

  @override
  void initState() {
    super.initState();
    for (String langKey in widget.words.keys) {
      if (widget.words[langKey] is Map<String, dynamic>) {
        words[langKey] = widget.words[langKey];
      }
    }
  }

  copyToClipboard(context, myText) {
    Clipboard.setData(ClipboardData(text: myText));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(("Text, '").toString() +
              myText.toString() +
              ("' copied to clipboard").toString())),
    );
  }

  updateSelf() {
    print("LoginPageState updateSelf called");
    setState(() {});
  }

  String getLanguage(BuildContext context, String LID) {
    dynamic myLanguage = MyHomePageState()
        .languages
        .where((lang) => lang["LID"] == LID)
        .toList()[0];
    return "${myLanguage["name1"]}(${FlutterI18n.translate(context, myLanguage["name2"])})";
  }

  @override
  Widget build(BuildContext context) {
    print("words_new_multi.dart Widget build called.");
    final theme = Theme.of(context);
    MyHomePageState().setSavedLanguage(context);
    double screenWidth = MediaQuery.of(context).size.width;
    List<String> langKeys = List<String>.from(words.keys);
    String promptFoundWords = FlutterI18n.translate(
        context, 'PROMPT_FOUND_WORDS',
        translationParams: {
          'fcwrds': (widget.countAnagrams).toString(),
          'fclangs': (langKeys.length).toString()
        });
    print("words_new_multi.dart langKeys = ${json.encode(langKeys)}");
    double big1FontSize =
        (screenWidth * 0.018 + 4) < 15 ? 15 : (screenWidth * 0.018 + 4);
    double big2FontSize =
        (screenWidth * 0.016 + 4) < 11 ? 11 : (screenWidth * 0.016 + 4);
    return Scaffold(
        appBar: AppBar(
          title: Text(FlutterI18n.translate(context, "APP_TITLE")),
          actions: <Widget>[
            Menu(context: context, page: 'main', updateParent: updateSelf)
          ],
        ),
        body: ListView(children: <Widget>[
          Visibility(
            visible: widget.lastInput.trim() != '',
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(promptFoundWords,
                  style: TextStyle(
                      fontSize: big1FontSize,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic)),
            ),
          ),
          for (var i = 0; i < langKeys.length; i++)
            Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: Text(
                        "${FlutterI18n.translate(context, "PROMPT_LANGUAGE")}: ${getLanguage(context, langKeys[i])}",
                        style: TextStyle(
                            fontSize: big2FontSize,
                            fontWeight: FontWeight.bold)),
                  ),
                  for (String anaLength
                      in (Map<String, dynamic>.from(words[langKeys[i]])).keys)
                    Flex(direction: Axis.horizontal, children: [
                      Flexible(
                          flex: 1,
                          child: Card(
                              color:
                                  theme.colorScheme.surface, // ← And also this.
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        "${anaLength.toString()}-word Anagrams: (${words[langKeys[i]][anaLength]!.length})",
                                        softWrap: true,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12.0)),
                                    if (widget
                                        .words[langKeys[i]][anaLength]!.isEmpty)
                                      Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.grey)),
                                          child: Column(children: [
                                            Text("No words found.")
                                          ]))
                                    else
                                      for (int j = 0;
                                          j <
                                              widget
                                                  .words[langKeys[i]]
                                                      [anaLength]!
                                                  .length;
                                          j++)
                                        Container(
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.grey)),
                                          child: Column(
                                            children: [
                                              Row(children: [
                                                SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      .06,
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .fromLTRB(0, 0, 5, 0),
                                                      child: Text(
                                                          ("${(j + 1)}) "),
                                                          softWrap: true,
                                                          style: TextStyle(
                                                              fontSize: 12.0)),
                                                    ),
                                                  ),
                                                ),
                                                Column(children: [
                                                  for (int k = 0;
                                                      k <
                                                          widget
                                                              .words[
                                                                  langKeys[i]][
                                                                  anaLength]![j]
                                                              .length;
                                                      k++)
                                                    Row(children: [
                                                      InkWell(
                                                        onTap: () {
                                                          // Handle the click action here
                                                          // For example, you can navigate to a new screen or perform some other action.
                                                          //print("BODY UNFOCUSSING");
                                                          //print("Copy word, '${myWords[key]![i][j]["word"]}' clicked!");
                                                          MyHomePage().copyToClipboard(
                                                              context,
                                                              words[langKeys[i]]
                                                                      [
                                                                      anaLength]![
                                                                  j][k]["word"]);
                                                        },
                                                        child: SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              .15,
                                                          child: Text(
                                                            words[langKeys[i]][
                                                                    anaLength]![
                                                                j][k]["word"],
                                                            softWrap: true,
                                                            style: TextStyle(
                                                                fontSize: 12.0),
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
                                                              words[langKeys[i]]
                                                                          [
                                                                          anaLength]![
                                                                      j][k][
                                                                  "formattedWord"]);
                                                        },
                                                        child: SizedBox(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                .15,
                                                            child: Text.rich(
                                                                TextSpan(
                                                                    children: [
                                                                  TextSpan(
                                                                      text: "(",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              10.0)),
                                                                  TextSpan(
                                                                      text: widget
                                                                          .words[langKeys[i]]
                                                                              [anaLength]![j]
                                                                              [k]
                                                                              [
                                                                              "formattedWord"]
                                                                          .toString()
                                                                          .substring(
                                                                              0,
                                                                              int.parse(words[langKeys[i]][anaLength]![j][k]["match"]
                                                                                  .toString()))
                                                                          .toString(),
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          fontSize:
                                                                              10.0)),
                                                                  TextSpan(
                                                                      text: words[langKeys[i]][anaLength]![j][k]
                                                                              [
                                                                              "formattedWord"]
                                                                          .toString()
                                                                          .substring(int.parse(words[langKeys[i]][anaLength]![j][k]["match"]
                                                                              .toString()))
                                                                          .toString(),
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              10)),
                                                                  TextSpan(
                                                                      text: ")",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              10)),
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
                                                              words[langKeys[i]]
                                                                          [
                                                                          anaLength]![
                                                                      j][k][
                                                                  "definition"]);
                                                        },
                                                        child: SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              .56,
                                                          child: Text(
                                                            words[langKeys[i]][
                                                                    anaLength]![j]
                                                                [
                                                                k]["definition"],
                                                            softWrap: true,
                                                            style: TextStyle(
                                                                fontSize: 12.0),
                                                          ),
                                                        ),
                                                      ),
                                                    ]),
                                                ])
                                              ])
                                            ],
                                          ),
                                        ),
                                  ])))
                    ])
                ])
        ]));
  }
}
