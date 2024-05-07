// ignore_for_file: use_build_context_synchronously, must_be_immutable
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';

import 'main.dart';

class Menu extends StatefulWidget {
  final BuildContext context;
  final String page;
  final Function updateParent;
  Menu({required this.context, required this.page, required this.updateParent});

  @override
  // ignore: library_private_types_in_public_api
  MenuState createState() => MenuState();
}

class MenuState extends State<Menu> {
  late BuildContext mainContext;
  String helpText = '';
  @override
  void initState() {
    mainContext = widget.context;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    MyHomePageState().setSavedLanguage(context);
    return PopupMenuButton<dynamic>(
        padding: EdgeInsets.all(0),
        color: Colors.white,
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width,
        ),
        icon: Icon(Icons.menu),
        onSelected: (value) {
          print("menu selected value = $value");
          //focusNode.unfocus();
          FocusScope.of(context).unfocus();
          //MyHomePageState().showInterstitialAd((){});
        },
        onOpened: () {
          print("menu opened.");
          setState(() {
            context.read<AppData>().setMenuOpen(true);
          });
          widget.updateParent();
        },
        onCanceled: () {
          setState(() {
            context.read<AppData>().setMenuOpen(false);
          });
          widget.updateParent();
        },
        itemBuilder: (BuildContext context) {
          return [
            PopupMenuItem<dynamic>(
                value: 'MY POPUP',
                child: MenuList(
                    context: context,
                    page: widget.page,
                    updateParent: widget.updateParent)),
          ];
        });
  }
}

class MenuList extends StatefulWidget {
  BuildContext context;
  String page;
  Function updateParent;
  MenuList(
      {required this.context, required this.page, required this.updateParent});

  @override
  // ignore: library_private_types_in_public_api
  MenuListState createState() => MenuListState();
}

class MenuListState extends State<MenuList> {
  List<dynamic> languages = [];
  @override
  void initState() {
    super.initState();
    languages = MyHomePageState().languages;
    print(
        "MenuListState initState called languages.length = ${languages.length}");
  }

  Future<void> changeLanguage(String languageCode) async {
    print("changeLanguage called, languageCode = $languageCode");

    FlutterI18n.refresh(widget.context, Locale(languageCode));
    await Future.delayed(Duration(milliseconds: 400));
    setState(() {
      //Future.delayed(Duration(milliseconds: 3000), () {
      dynamic myLanguage = (languages.where(
          (dynamic language) => language["value"] == languageCode)).toList()[0];
      context.read<AppData>().setLanguage(myLanguage!);
      print("SELECTED LANGUAGE = $myLanguage");
    });
    widget.updateParent();
  }

  @override
  Widget build(BuildContext context) {
    MyHomePageState().setSavedLanguage(context);
    double screenWidth = MediaQuery.of(context).size.width;
    double promptFontSize =
        (screenWidth * 0.05 - 3) > 15 ? 15 : (screenWidth * 0.05 - 3);
    String helpText = "";
    helpText +=
        '<strong style="font-style:">${FlutterI18n.translate(context, "HELP1")}:</strong><br />';
    helpText +=
        '<span style="font-style:italic;">${FlutterI18n.translate(context, "HELP2")}</span><br />';
    helpText +=
        '<br /><strong style="font-size: 16pt;font-style:italic;"><u>${FlutterI18n.translate(context, "PROMPT_HELP")}:</u></strong><ul style="padding:0px;">';
    helpText +=
        '<li><b>Option <i>"${FlutterI18n.translate(context, "PROMPT_EXACT_WORD_LENGTHS")}"</i></b><br />${FlutterI18n.translate(context, "HELP3")}<br />For example, If checked :<br />';
    helpText +=
        '<div style="margin-left: 10px;"><i>"LISTEN"</i> ${FlutterI18n.translate(context, "HELP4")}:</div><div style="margin-left: 15px;">1)ENLIST<br />2)SILENT';
    helpText +=
        '</div>${FlutterI18n.translate(context, "HELP5")}: "ENLISTed", "LISTENing"';
    helpText +=
        '</li><li><b>${FlutterI18n.translate(context, "PROMPT_OPTION")} <i>"${FlutterI18n.translate(context, "PROMPT_MULTIPLE_WORDS")}"</i></b><br />${FlutterI18n.translate(context, "HELP6")}<br />${FlutterI18n.translate(context, "HELP7")}<br />';
    helpText +=
        '<div style="margin-left: 10px;"><i>"WELDON"</i> ${FlutterI18n.translate(context, "HELP8")}:</div><div style="margin-left: 15px;">1)ENLightened DOWdiness<br />2)ENWrapped OLDish';
    helpText +=
        '<br />→ <b>${FlutterI18n.translate(context, "PROMPT_OPTION")} <i>"# ${FlutterI18n.translate(context, "HELP9")}"</i></b>';
    helpText += '<br />${FlutterI18n.translate(context, "HELP10")}';
    helpText += '</ul>';

    List<DropdownMenuItem<String>> languageItems =
        languages.map<DropdownMenuItem<String>>((dynamic lang) {
      return DropdownMenuItem<String>(
        value: lang["value"],
        child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.40,
            child: Text(
                "${lang["name1"]}(${FlutterI18n.translate(context, lang["name2"])})",
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: promptFontSize))),
      );
    }).toList();

    return languages.isEmpty
        ? Center(child: CircularProgressIndicator())
        : Container(
            width: screenWidth,
            decoration: BoxDecoration(color: Colors.white),
            child: Column(
              children: [
                Container(
                  width: screenWidth,
                  height: 50,
                  decoration: BoxDecoration(color: Colors.white),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(color: Colors.white),
                        width: screenWidth * 0.25,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                          child: Text(
                              '${FlutterI18n.translate(context, "PROMPT_LANGUAGE")}:',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: promptFontSize)),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(color: Colors.white),
                        width: (screenWidth * 0.75) - 60,
                        child: DropdownButton<String>(
                          alignment: Alignment.centerRight,
                          isExpanded: true,
                          //{"name1": "Afrikaans", "name2": "LANGUAGE_AFRIKAANS", "value": "af"},
                          value: Provider.of<AppData>(context)
                              .selectedLanguage["value"],
                          onChanged: (newLanguage) {
                            changeLanguage(newLanguage!);
                          },
                          items: languageItems,
                        ),
                      ),
                    ],
                  ),
                ),
                Html(data: helpText),
              ],
            ),
          );
  }
}
