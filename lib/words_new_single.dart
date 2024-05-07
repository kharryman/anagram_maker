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
class WordsPageNewSingle extends StatefulWidget {
  final bool isMultipleWords;
  final String lastInput;
  final int countAnagrams;
  final Map<String, List<dynamic>> words;

  WordsPageNewSingle(
      {required this.isMultipleWords,
      required this.lastInput,
      required this.countAnagrams,
      required this.words});
  @override
  // ignore: library_private_types_in_public_api
  State<WordsPageNewSingle> createState() => WordsPageNewSingleState();
}

class WordsPageNewSingleState extends State<WordsPageNewSingle> {
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
    print("WordsPageNewState updateSelf called");
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
    MyHomePageState().setSavedLanguage(context);
    double screenWidth = MediaQuery.of(context).size.width;
    double tabFontSize =
        (screenWidth * 0.020 + 4) < 15 ? 15 : (screenWidth * 0.020 + 4);
    double big1FontSize =
        (screenWidth * 0.018 + 4) < 15 ? 15 : (screenWidth * 0.018 + 4);
    double big2FontSize =
        (screenWidth * 0.016 + 4) < 11 ? 11 : (screenWidth * 0.016 + 4);
    final theme = Theme.of(context); // ← Add this.
    List<String> wordKeys = List<String>.from(widget.words.keys);
    return WillPopScope(
        onWillPop: () async {
          print("HOME PAGE GOING BACK TO MY APP!");
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => MyApp()));
          return true; // Return false to prevent popping the route
        },
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.grey,
              title: Text(
                  "${FlutterI18n.translate(context, "PROMPT_ANAGRAMS")}(${widget.countAnagrams})",
                  style: TextStyle(fontSize: tabFontSize)),
              actions: <Widget>[
                Menu(context: context, page: 'main', updateParent: updateSelf)
              ],
            ),
            body: ListView(children: <Widget>[
              for (var i = 0; i < wordKeys.length; i++)
                Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                        child: Text(
                            "${FlutterI18n.translate(context, "PROMPT_LANGUAGE")}: ${getLanguage(context, wordKeys[i])}",
                            style: TextStyle(
                                fontSize: big2FontSize,
                                fontWeight: FontWeight.bold)),
                      ),
                      for (var j = 0;
                          j < widget.words[wordKeys[i]]!.length;
                          j++)
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * .06,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 0, 5, 0),
                                  child: Text("${j + 1})",
                                      softWrap: true,
                                      style: TextStyle(fontSize: 12.0)),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                // Handle the click action here
                                // For example, you can navigate to a new screen or perform some other action.
                                print("BODY UNFOCUSSING");
                                print(
                                    "Copy word, '${widget.words[wordKeys[i]]![j]["word"]}' clicked!");
                                copyToClipboard(context,
                                    widget.words[wordKeys[i]]![j]["word"]);
                              },
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * .15,
                                child: Text(
                                    widget.words[wordKeys[i]]![j]["word"],
                                    softWrap: true,
                                    style: TextStyle(fontSize: 12.0)),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                // Handle the click action here
                                // For example, you can navigate to a new screen or perform some other action.
                                print("BODY UNFOCUSSING");
                                print(
                                    "Copy formatted word, '${widget.words[wordKeys[i]]![j]["formattedWord"]}' clicked!");
                                copyToClipboard(
                                    context,
                                    widget.words[wordKeys[i]]![j]
                                        ["formattedWord"]);
                              },
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * .15,
                                child: Text(
                                  "( ${widget.words[wordKeys[i]]![j]["formattedWord"]} )",
                                  softWrap: true,
                                  style: TextStyle(fontSize: 10.0),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                // Handle the click action here
                                // For example, you can navigate to a new screen or perform some other action.
                                print("BODY UNFOCUSSING");
                                print(
                                    "Definition for '${widget.words[wordKeys[i]]![j]["word"]}', copy '${widget.words[wordKeys[i]]![j]["definition"]}'' clicked!");
                                copyToClipboard(
                                    context,
                                    widget.words[wordKeys[i]]![j]
                                        ["definition"]);
                              },
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * .56,
                                child: Text(
                                  widget.words[wordKeys[i]]![j]["definition"],
                                  softWrap: true,
                                  style: TextStyle(fontSize: 12.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ])
            ])));
  }
}
