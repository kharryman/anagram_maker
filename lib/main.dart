//import 'dart:collection';
//import 'dart:js_interop';

// ignore_for_file: must_be_immutable, use_build_context_synchronously

//import 'dart:convert';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

//kIsWeb : SIMILIAR TO NOT isApp() FUNCTION====>
//import 'package:anagram_maker/dictionary.dart';
import 'package:anagram_maker/dict_big.dart';
import 'package:anagram_maker/menu.dart';
import 'package:anagram_maker/words_new_single.dart';
import 'package:anagram_maker/words_new_multi.dart';
import 'package:anagram_maker/words_old.dart';
import 'package:flutter/foundation.dart';

//import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
//import 'package:anagram_maker/words.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/loaders/decoders/base_decode_strategy.dart';
import 'package:flutter_i18n/loaders/decoders/json_decode_strategy.dart';
//import 'package:provider/provider.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:multiselect/multiselect.dart';
import 'package:multiselect_dropdown_flutter/multiselect_dropdown_flutter.dart';

import 'package:connectivity/connectivity.dart';

const String testDevice = '974550CBC7D4EA4718A67165E2E3B868';
const String myIpad = '00008020-0014301102D1002E';
const String myIphone11 = 'A8EC231A-DCFC-405C-8A0D-62E9F5BA1918';
const int maxFailedLoadAttempts = 3;
InterstitialAd? interstitialAd;
int numInterstitialLoadAttempts = 0;

dynamic selectedAnagramLanguage;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //print("main RETURNING $kIsWeb");
  if (kIsWeb == false) {
    var testDevices = <String>[];
    if (Platform.isAndroid) {
      testDevices = [testDevice];
    } else if (Platform.isIOS) {
      testDevices = [myIpad, myIphone11];
    }
    MobileAds.instance
      ..initialize()
      ..updateRequestConfiguration(RequestConfiguration(
        testDeviceIds: testDevices,
      ));
  } else {
    //print("main NOT SHOWING AD");
  }
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
          create: (context) => AppData(),
          child: MyApp()) // Other providers if needed
    ],
    child: MyApp(),
  ));
}

class AppData extends ChangeNotifier {
  dynamic selectedLanguage = {
    "LID": "8",
    "name1": "English",
    "name2": "LANGUAGE_ENGLISH",
    "value": "en"
  };
  Future<void> setLanguage(dynamic myLanguage) async {
    selectedLanguage = myLanguage;
    selectedAnagramLanguage = selectedLanguage;
    await MyHomePageState().setData("LANGUAGE", selectedLanguage["value"]);
  }

  bool menuOpen = false;
  void setMenuOpen(bool isOpen) {
    menuOpen = isOpen;
  }
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final int ofThousandShowAds = 350;
  List<BaseDecodeStrategy> decodeStrategies = [JsonDecodeStrategy()];
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  @override
  Widget build(BuildContext context) {
    MyHomePageState().setSavedLanguage(context);
    return MaterialApp(
      title: 'Anagram Maker',
      navigatorKey: navigatorKey,
      localizationsDelegates: [
        FlutterI18nDelegate(
          translationLoader: FileTranslationLoader(
              decodeStrategies: decodeStrategies,
              basePath: "assets/i18n",
              fallbackFile: "en",
              useCountryCode: false),
          missingTranslationHandler: (key, locale) {
            print(
                "--- Missing Key: $key, languageCode: ${locale?.languageCode}");
          },
        ),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        fontFamilyFallback: const ["Roboto"],
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromRGBO(255, 255, 255, 1)),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final myDic = {
    "a": [dicA1, dicA2],
    "b": [dicB1, dicB2],
    "c": [dicC1, dicC1, dicC3],
    "d": [dicD1, dicD2],
    "e": [dicE1],
    "f": [dicF1],
    "g": [dicG1],
    "h": [dicH1],
    "i": [dicI1],
    "j": [dicJ1],
    "k": [dicK1],
    "l": [dicL1],
    "m": [dicM1, dicM2],
    "n": [dicN1],
    "o": [dicO1],
    "p": [dicP1, dicP2],
    "q": [dicQ1],
    "r": [dicR1, dicR2],
    "s": [dicS1, dicS2, dicS3],
    "t": [dicT1, dicT2],
    "u": [dicU1],
    "v": [dicV1],
    "w": [dicW1],
    "x": [dicX1],
    "y": [dicY1],
    "z": [dicZ1],
  };
  copyToClipboard(context, myText) {
    Clipboard.setData(ClipboardData(text: myText));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(("Text, '").toString() +
              myText.toString() +
              ("' copied to clipboard").toString())),
    );
  }

  @override
  State<MyHomePage> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0; // ← Add this property.
  bool isMakeAnagrams = true;
  List<dynamic> foundWords = [];
  String appTitle = 'Anagram Maker';
  static String helpText = '';

  FocusNode focusNode = FocusNode();
  final RegExp onlyLetters = RegExp(r'^[a-zA-Z]+$');
  final TextEditingController inputController = TextEditingController();
  String lastInput = "";
  bool isLoading = false;
  bool isMultipleWords = false;
  List<int> searchTimes = [
    5,
    10,
    20,
    30,
    40,
    50,
    60,
    70,
    80,
    90,
    100,
    200,
    300,
    400,
    500,
    1000,
  ];
  int selectedSearchTime = 5;
  bool isExactWordLengths = false;

  List<dynamic> languages = [
    {
      "LID": "1",
      "name1": "Afrikaans",
      "name2": "LANGUAGE_AFRIKAANS",
      "value": "af"
    },
    {"LID": "2", "name1": "Euskara", "name2": "LANGUAGE_BASQUE", "value": "eu"},
    {
      "LID": "3",
      "name1": "Bosanski",
      "name2": "LANGUAGE_BOSNIAN",
      "value": "bs"
    },
    {
      "LID": "4",
      "name1": "Hrvatski",
      "name2": "LANGUAGE_CROATIAN",
      "value": "hr"
    },
    {"LID": "5", "name1": "čeština", "name2": "LANGUAGE_CZECH", "value": "cs"},
    {"LID": "6", "name1": "Dansk", "name2": "LANGUAGE_DANISH", "value": "da"},
    {
      "LID": "8",
      "name1": "English",
      "name2": "LANGUAGE_ENGLISH",
      "value": "en"
    },
    {
      "LID": "9",
      "name1": "Eesti keel",
      "name2": "LANGUAGE_ESTONIAN",
      "value": "et"
    },
    {
      "LID": "11",
      "name1": "Suomalainen",
      "name2": "LANGUAGE_FINNISH",
      "value": "fi"
    },
    {
      "LID": "12",
      "name1": "Français",
      "name2": "LANGUAGE_FRENCH",
      "value": "fr"
    },
    {
      "LID": "13",
      "name1": "Deutsch",
      "name2": "LANGUAGE_GERMAN",
      "value": "de"
    },
    {
      "LID": "14",
      "name1": "Kreyòl ayisyen",
      "name2": "LANGUAGE_HAITIAN_CREOLE",
      "value": "ht"
    },
    {
      "LID": "15",
      "name1": "ʻŌlelo Hawaiʻi",
      "name2": "LANGUAGE_HAWAIIAN",
      "value": "haw"
    },
    {"LID": "16", "name1": "Hmoob", "name2": "LANGUAGE_HMONG", "value": "hmn"},
    {
      "LID": "17",
      "name1": "Magyar",
      "name2": "LANGUAGE_HUNGARIAN",
      "value": "hu"
    },
    {
      "LID": "18",
      "name1": "Bahasa Indonesia",
      "name2": "LANGUAGE_INDONESIAN",
      "value": "id"
    },
    {"LID": "19", "name1": "Gaeilge", "name2": "LANGUAGE_IRISH", "value": "ga"},
    {
      "LID": "20",
      "name1": "Italiano",
      "name2": "LANGUAGE_ITALIAN",
      "value": "it"
    },
    {
      "LID": "22",
      "name1": "Lëtzebuergesch",
      "name2": "LANGUAGE_LUXEMBOURGISH",
      "value": "lb"
    },
    {"LID": "23", "name1": "Melayu", "name2": "LANGUAGE_MALAY", "value": "ms"},
    {"LID": "24", "name1": "Malti", "name2": "LANGUAGE_MALTESE", "value": "mt"},
    {"LID": "25", "name1": "Maori", "name2": "LANGUAGE_MAORI", "value": "mi"},
    {"LID": "27", "name1": "Polski", "name2": "LANGUAGE_POLISH", "value": "pl"},
    {
      "LID": "28",
      "name1": "Português",
      "name2": "LANGUAGE_PORTUGUESE",
      "value": "pt"
    },
    {
      "LID": "29",
      "name1": "Română",
      "name2": "LANGUAGE_ROMANIAN",
      "value": "ro"
    },
    {"LID": "30", "name1": "Samoa", "name2": "LANGUAGE_SAMOAN", "value": "sm"},
    {
      "LID": "31",
      "name1": "Slovensko",
      "name2": "LANGUAGE_SLOVAK",
      "value": "sk"
    },
    {
      "LID": "32",
      "name1": "Slovenščina",
      "name2": "LANGUAGE_SLOVENIAN",
      "value": "sl"
    },
    {
      "LID": "33",
      "name1": "Soomaali",
      "name2": "LANGUAGE_SOMALI",
      "value": "so"
    },
    {
      "LID": "34",
      "name1": "Español",
      "name2": "LANGUAGE_SPANISH",
      "value": "es"
    },
    {
      "LID": "35",
      "name1": "Svenska",
      "name2": "LANGUAGE_SWEDISH",
      "value": "sv"
    },
    {"LID": "39", "name1": "Cymraeg", "name2": "LANGUAGE_WELSH", "value": "cy"}
  ];

  List<dynamic> availLanguages = [];
  bool isLanguagesLoading = true;
  List<String> myFilteredLanguages = [];
  bool isAllLanguages = true;
  List<String> myList = ["..."];

  @override
  void initState() {
    super.initState();
    isLanguagesLoading = true;
    dynamic selectedLanguage = {
      "LID": "8",
      "name1": "English",
      "name2": "LANGUAGE_ENGLISH",
      "value": "en"
    };
    selectedAnagramLanguage = selectedLanguage;
    if (kIsWeb == false) {
      createInterstitialAd();
    }
    setSavedLanguage(null);
    //setAvailLanguages();
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      print("Main initState onConnectivityChanged ConnectivityResult $result");
      bool isOnline = result != ConnectivityResult.none;
      doNetworkChange(isOnline);
    });
    Connectivity().checkConnectivity().then((ConnectivityResult result) {
      print("Main initState checkConnectivity RESOLVED result = $result");
      bool isOnline = result != ConnectivityResult.none;
      doNetworkChange(isOnline);
    });
  }

  doNetworkChange(bool isOnline) {
    if (isOnline == false) {
      setState(() {
        print("OFFLINE...");
        dynamic selectedLanguage = {
          "LID": "8",
          "name1": "English",
          "name2": "LANGUAGE_ENGLISH",
          "value": "en"
        };
        selectedAnagramLanguage = selectedLanguage;
        isLanguagesLoading = false;
        myList = ["English(English)"];
        myFilteredLanguages = ["English(English)"];
      });
    } else {
      setAvailLanguages();
    }
  }

/*
  @override
  void didChangeDependencies() {
    print("didChangeDependencies called");
    super.didChangeDependencies();
    doChangeDependencies();
    //FlutterI18n.refresh(context,Locale(Provider.of<AppData>(context).selectedLanguage["value"]));
  }

  doChangeDependencies() {
    //if (context == null)
    //BuildContext? context = scaffoldKey.currentContext;
    //if (context != null) {
    print("MyHomePageState doChangeDependencies called CONTEXT NOT NULL!");
    setState(() {
      resetMyList();
    });
  }
  */

  setSavedLanguage(BuildContext? context) async {
    print("setSavedLanguage called");
    String savedLanguage = (await getData("LANGUAGE")) ?? "";
    print("savedLanguage = ${json.encode(savedLanguage)}");
    if (savedLanguage != "") {
      print("setSavedLanguage savedLanguage SET = $savedLanguage");
      List<dynamic> selectedLanguages = List<dynamic>.from(languages
          .where((dynamic lang) => lang["value"] == savedLanguage)
          .toList());
      if (selectedLanguages.isNotEmpty) {
        selectedAnagramLanguage = selectedLanguages[0];
      }
      try {
        if (context != null) {
          FlutterI18n.refresh(context, Locale(savedLanguage));
        }
      } catch (e) {
        print("Error refreshing saved language");
      }
    } else {
      //FlutterI18n.refresh(context, Locale('en'));
    }
  }

  void showProgress(BuildContext context, message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white, // Background color
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
                SizedBox(height: 16.0),
                Text(
                  message,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18.0,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void hideProgress(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
    isLoading = false;
  }

  Future<void> showPopup(BuildContext context, String message) async {
    //print("showPopup called");
    return showDialog<void>(
      context: context,
      barrierDismissible:
          false, // Prevent dismissing by tapping outside the popup
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alert'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the popup
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  updateSelf() {
    print("HomePageState updateSelf called");
    setState(() {
      resetMyList();
    });
  }

  setLanguages(BuildContext context, List<String> newList) {
    print(
        "setLanguages called, newList = ${json.encode(newList)}, myFilteredLanguages = ${json.encode(myFilteredLanguages)}");
    Future.delayed(Duration(microseconds: 10), () {
      setState(() {
        myFilteredLanguages = newList;
      });
    });
  }

  resetMyList() {
    print("resetMyList called");

    myList = [];
    myList.addAll(List<String>.from(availLanguages.map((dynamic value) {
      return getTransLangValue(value);
    }).toList()));
    Set<String> uniqueMyList = myList.toSet();
    myList = uniqueMyList.toList();
    dynamic myLanguage = List<dynamic>.from(languages
        .where(
            (dynamic lang) => lang["value"] == selectedAnagramLanguage["value"])
        .toList())[0];
    List<String> foundMyListEles = List<String>.from(myList
        .where((String myEle) => myEle.contains(myLanguage["name1"]))
        .toList());
    if (foundMyListEles.isNotEmpty) {
      String myListElement = foundMyListEles[0];
      myFilteredLanguages = [myListElement];
    } else {
      myFilteredLanguages = [];
    }
  }

  setAvailLanguages() async {
    //showProgress(
    //    context, FlutterI18n.translate(context, "PROGRESS_ADD_COMMENT"));
    dynamic data = {"SUCCESS": false};
    bool isRequestSuccess = true;
    bool isSuccess = true;
    List<dynamic> gotLanguages = [];
    //Response response = {} as Response;
    Response response = http.Response("", 200);
    try {
      response = await http.get(Uri.parse(
          'https://www.learnfactsquick.com/lfq_app_php/get_languages.php'));
    } catch (e) {
      isRequestSuccess = false;
    }
    if (isRequestSuccess == false) {
      await showPopup(
          context, "${FlutterI18n.translate(context, "NETWORK_ERROR")}!");
      doNetworkChange(false);
    } else {
      //hideProgress(context);
      if (response.statusCode == 200) {
        data = Map<String, dynamic>.from(json.decode(response.body));
        print("GET AVAIL LANGUAGES data = ${json.encode(data)}");
        if (data["SUCCESS"] == true) {
          print("GOT LANGUAGES = ${json.encode(data)}");
          gotLanguages = data["LANGUAGES"];
        } else {
          print("GET LANGUAGES ERROR: ${data["ERROR"]}");
          isSuccess = false;
          //showPopup(context, data["ERROR"]);
        }
      } else {
        showPopup(context, FlutterI18n.translate(context, "NETWORK_ERROR"));
      }
      setState(() {
        isLanguagesLoading = false;
        if (isSuccess == true) {
          dynamic availLang;
          for (int i = 0; i < gotLanguages.length; i++) {
            availLang = (MyHomePageState().languages.where((dynamic language) =>
                language["value"] == gotLanguages[i]["Code"])).toList()[0];
            availLanguages.add(availLang);
          }
          resetMyList();
        }
      });
    }
  }

  void setSelectedSearchTime(int searchTime) {
    setState(() {
      selectedSearchTime = searchTime;
    });
  }

  List<dynamic> getWords(String inputWord) {
    print("getWords called");
    List<String> uniqueLetters =
        (Set<String>.from(inputWord.toLowerCase().split("").toList())).toList();
    uniqueLetters.sort();
    foundWords = [];
    String formattedWord = "";
    Map<String, String> dicWords = {};
    List<String> findWordSplit = [];
    List<String> getLetters = [];
    List<String> lastInputSplit = inputWord.toLowerCase().split("");
    bool isFound = true;
    //print("uniqueLetters = ${json.encode(uniqueLetters)}");
    for (int i = 0; i < uniqueLetters.length; i++) {
      dicWords = {};
      for (var array in MyHomePage().myDic[uniqueLetters[i]]!) {
        dicWords.addAll(array);
      }
      print("dicWords.keys.length = ${dicWords.keys}");
      for (String word in dicWords.keys) {
        if (word.length >= inputWord.length &&
            (isExactWordLengths == false || word.length == inputWord.length)) {
          getLetters = [];
          for (int k = 0; k < lastInputSplit.length; k++) {
            getLetters.add(lastInputSplit[k]);
          }
          //print("getLetters = ${json.encode(getLetters)}");
          isFound = true;
          findWordSplit = word.toLowerCase().split("");
          for (var j = 0; j < inputWord.length; j++) {
            if (!getLetters.contains(findWordSplit[j])) {
              isFound = false;
              break;
            } else {
              getLetters.remove(findWordSplit[j]);
            }
          }
          if (isFound == true) {
            //print("IS FOUND!");
          }
          if (isFound == true && getLetters.isEmpty) {
            formattedWord = word.substring(0, inputWord.length).toUpperCase() +
                word.substring(inputWord.length).toLowerCase();
            foundWords.add({
              "word": word,
              "formattedWord": formattedWord,
              "definition": dicWords[word]
            });
          }
        }
      }
    }
    return foundWords;
  }

  List<List<int>> generateCombinations<T>(List<int> inputList, int chooseN) {
    List<List<int>> result = [];
    void combine(List<int> current, int start, int chooseN) {
      if (chooseN == 0) {
        result.add(List.from(current));
        return;
      }
      for (int i = start; i <= inputList.length - chooseN; i++) {
        current.add(inputList[i]);
        combine(current, i + 1, chooseN - 1);
        current.removeLast();
      }
    }

    combine([], 0, chooseN);
    return result;
  }

  Future<void> doMakeAnagrams(
      BuildContext context, String targetLanguage) async {
    if (inputController.text.trim() == '') {
      showPopup(context, "Please enter letters to make anagrams of.");
      return;
    }
    print(
        "doMakeAnagrams called, targetLanguage = $targetLanguage, myFilteredLanguages.length = ${myFilteredLanguages.length}, myFilteredLanguages[0] = ${myFilteredLanguages[0]}");
    if (targetLanguage == "en" &&
        myFilteredLanguages.length == 1 &&
        myFilteredLanguages[0] == "English(English)") {
      makeAnagramsOld(context);
    } else {
      makeAnagramsNew(context, targetLanguage);
    }
  }

  Future<void> makeAnagramsOld(context) async {
    print("makeAnagramsOld called");
    MyHomePageState().showInterstitialAd(() async {
      isLoading = true;
      showProgress(context, 'Making anagrams..');
      await Future.delayed(Duration(milliseconds: 300));
      //print("makeAnagrams called inpt = ${inputController.text}");
      //print(inputController.text);
      lastInput = inputController.text;
      //print("isMultipleWords = $isMultipleWords");
      List<dynamic> foundWords = [];
      int countAnagrams = 0;
      if (isMultipleWords == false) {
        foundWords = getWords(lastInput);
        countAnagrams = foundWords.length;
      } else {
        Map<int, List<dynamic>> numsList = {};
        int numLetsMin = 2;
        int numLetsMax = 2;
        int countMatch = 0;
        int numLetters = lastInput.length;
        int countMaxDiv = 0;
        int countMinDiv = 0;
        int rem = 0;
        Map<int, List<List<dynamic>>> wordsMatched = {};
        int countRemoveA = 0;
        int countRemoveB = 0;
        List<int> combosDone = [];
        bool isDo = true;
        int maxWords = (numLetters / 2).floor();
        List<dynamic> wordsAdd = [];
        int countWhile = 0;
        List<int> numberCombos = [numLetters];
        int minDiv = 0;
        int maxDiv = 0;
        int minLetters = numLetters;
        for (int n = 2; n <= maxWords; n++) {
          minDiv = (numLetters / n).floor();
          maxDiv = (numLetters / n).ceil();
          if (minDiv < minLetters) {
            minLetters = minDiv;
          }
          if (!numberCombos.contains(minDiv)) {
            numberCombos.add(minDiv);
          }
          if (!numberCombos.contains(maxDiv)) {
            numberCombos.add(maxDiv);
          }
        }
        for (int n = 0; n < numberCombos.length; n++) {
          numsList[numberCombos[n]] = [];
        }
        //print("numsList = ${json.encode(numsList)}");

        List<String> uniqueLetters =
            (Set<String>.from(lastInput.toLowerCase().split("").toList()))
                .toList();
        uniqueLetters.sort();
        foundWords = [];
        Map<String, String> dicWords = {};
        List<String> findWordSplit = [];
        List<String> getLetters = [];
        List<String> lastInputSplit = lastInput.toLowerCase().split("");
        //print("lastInputSplit = $lastInputSplit");
        bool isFound = true;
        bool isFoundAll = true;
        String formattedWord = "";
        print("makeAnagramsOld uniqueLetters = ${json.encode(uniqueLetters)}");

        for (int i = 0; i < uniqueLetters.length; i++) {
          dicWords = {};
          for (var letArr in MyHomePage().myDic[uniqueLetters[i]]!) {
            dicWords.addAll(letArr);

            //print("makeAnagramsOld dicWords.keys.length = ${dicWords.keys.length}");
            for (String word in dicWords.keys) {
              if (word.length >= minLetters) {
                //print("makeAnagramsOld DOING WORD: $word");
                getLetters = [];
                for (int k = 0; k < lastInputSplit.length; k++) {
                  getLetters.add(lastInputSplit[k]);
                }
                //print("getLetters = ${json.encode(getLetters)}");
                isFound = true;
                findWordSplit = word.toLowerCase().split("");
                countMatch = 0;
                for (var j = 0; j < findWordSplit.length; j++) {
                  if (getLetters.contains(findWordSplit[j])) {
                    getLetters.remove(findWordSplit[j]);
                    countMatch++;
                  } else {
                    break;
                  }
                }
                if (numberCombos.contains(countMatch) &&
                    (isExactWordLengths == false ||
                        word.length == countMatch)) {
                  formattedWord = word.substring(0, countMatch).toUpperCase() +
                      word.substring(countMatch).toLowerCase();
                  numsList[countMatch]?.add({
                    "word": word,
                    "formattedWord": formattedWord,
                    "definition": dicWords[word]
                  });
                }
              }
            }
          }
        }
        final stopwatch = Stopwatch();
        for (int i = 1; i <= maxWords; i++) {
          numLetsMax = (numLetters / i).ceil();
          numLetsMin = (numLetters / i).floor();
          countMaxDiv = numLetters % i;
          countMinDiv = i - countMaxDiv;
          //print("LOOP numLetters = $numLetters, #words = $i, countMaxDiv = $countMaxDiv, countMinDiv = $countMaxDiv, combosDone = $combosDone");
          isDo = true;
          if (combosDone.contains(i) || combosDone.contains(rem)) {
            isDo = false;
          }
          //print("LOOP isDo = $isDo, i = $i, combosDone = $combosDone");
          if (isDo == true) {
            //print("LOOP DOING REM = $rem");
            combosDone.add(i);
            if (rem != 0) {
              combosDone.add(rem);
            }
            countWhile = 0;
            //while (countRemoveA == 0 || countRemoveB == 0) {
            wordsMatched[i] = [];
            stopwatch.start();
            while (countWhile < selectedSearchTime) {
              countWhile++;
              getLetters = [];
              for (int k = 0; k < lastInputSplit.length; k++) {
                getLetters.add(lastInputSplit[k]);
              }
              //print("LOOP i=$i, getLetters = $getLetters");

              isFound = true;
              isFoundAll = true;

              wordsAdd = [];
              if (countMaxDiv > 0) {
                countRemoveA = numLetsMax * countMaxDiv;
                //print("countRemoveA = $countRemoveA");
                for (int j = 0; j < countMaxDiv; j++) {
                  //print("LOOP countMaxDiv = $countMaxDiv, numsList[i]!.length = ${numsList[numLetsMax]!.length}");
                  for (int k = 0; k < numsList[numLetsMax]!.length; k++) {
                    //LOOP WORDS(LENGTH i)
                    findWordSplit = numsList[numLetsMax]![k]["word"]
                        .toLowerCase()
                        .split("");
                    //print("findWordSplit = $findWordSplit");
                    isFound = true;
                    for (int f = 0; f < numLetsMax; f++) {
                      if (!getLetters.contains(findWordSplit[f])) {
                        isFound = false;
                        break;
                      }
                    }
                    if (isFound == true) {
                      for (int f = 0; f < numLetsMax; f++) {
                        getLetters.remove(findWordSplit[f]);
                        countRemoveA--;
                      }
                      numsList[numLetsMax]![k]["match"] = numLetsMax.toString();
                      wordsAdd.add(numsList[numLetsMax]![k]);
                    }
                    if (countRemoveA == 0) {
                      break;
                    }
                  }
                }
                if (countRemoveA > 0) {
                  isFoundAll = false;
                }
              }
              //print("LOOP DOING REMAINDER, getLetters = $getLetters, numLetsMax = $numLetsMax, numLetsMin = $numLetsMin");
              if (isFoundAll == true && countMinDiv > 0) {
                countRemoveB = numLetsMin * countMinDiv;
                for (int j = 0; j < countMinDiv; j++) {
                  //print("LOOP countMaxDiv = $countMinDiv, numsList[numLetsMin]!.length = ${numsList[numLetsMin]!.length}");
                  for (int r = 0; r < numsList[numLetsMin]!.length; r++) {
                    findWordSplit = numsList[numLetsMin]![r]["word"]
                        .toLowerCase()
                        .split("");
                    //print("LOOP REMAINDER findWordSplit = $findWordSplit");
                    isFound = true;
                    for (int f = 0; f < numLetsMin; f++) {
                      if (!getLetters.contains(findWordSplit[f])) {
                        isFound = false;
                        break;
                      }
                    }
                    if (isFound == true) {
                      //print("LOOP isFound TRUE!");
                      for (int f = 0; f < numLetsMin; f++) {
                        getLetters.remove(findWordSplit[f]);
                        countRemoveB--;
                      }
                      numsList[numLetsMin]![r]["match"] = numLetsMin.toString();
                      wordsAdd.add(numsList[numLetsMin]![r]);
                    }
                    if (countRemoveB == 0) {
                      break;
                    }
                  }
                }
                if (countRemoveB > 0) {
                  isFoundAll = false;
                }
              }
              //print("LOOP wordsAdd = $wordsAdd");
              if (isFoundAll == true && getLetters.isEmpty) {
                //REMOVE WORDS FROM numsList:
                for (int w = 0; w < wordsAdd.length; w++) {
                  numsList[numLetsMax]!.removeWhere(
                      (dynamic item) => item["word"] == wordsAdd[w]["word"]);
                  numsList[numLetsMin]!.removeWhere(
                      (dynamic item) => item["word"] == wordsAdd[w]["word"]);
                }
                wordsMatched[i]!.add(wordsAdd);
                countAnagrams++;
              } else {
                //RESHUFFLE ARRAYS:
                numsList[numLetsMax]!.shuffle();
                numsList[numLetsMin]!.shuffle();
                //END FOUND ALL
              }
            } //END WHILE LOOP
            stopwatch.stop();
            //print("while loop time = ${stopwatch.elapsedMilliseconds}");
          } //END isDo
        } //END LOOP NUMBER WORDS
        foundWords.add(wordsMatched);
      }

      //print("LOOP NOT SHOWING AD,lastInput = $lastInput, foundWords.length = ${foundWords.length}");
      hideProgress(context);
      print("makeAnagramsOld foundWords = $foundWords");
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => WordsPageOld(
                  isMultipleWords: isMultipleWords,
                  lastInput: lastInput,
                  countAnagrams: countAnagrams,
                  words: foundWords)));
    });
  }

  Future<void> makeAnagramsNew(
      BuildContext context, String targetLanguage) async {
    print("makeAnagramsNew called, targetLanguage = $targetLanguage");
    MyHomePageState().showInterstitialAd(() async {
      showProgress(context, FlutterI18n.translate(context, "MAKING_ANAGRAMS"));
      isLoading = true;
      lastInput = inputController.text;
      dynamic foundWords = {};
      int countAnagrams = 0;
      List<String> languageIds = [];
      if (isAllLanguages == false) {
        List<String> langVals = [];
        for (var i = 0; i < myFilteredLanguages.length; i++) {
          langVals
              .add(myFilteredLanguages[i].toString().split("(")[0].toString());
        }
        print("makeAnagramsNew langVals =$langVals");
        List<dynamic> languages = List<dynamic>.from(availLanguages
            .where((dynamic lang) => langVals.contains(lang["name1"]))
            .toList());
        print("makeAnagramsNew got languages =${json.encode(languages)}");
        languageIds = List<String>.from(
            languages.map((dynamic lang) => lang["LID"]).toList());
      }
      //DEFAULT TO ENGLISH IF TARGET LANGUAGE(APP LANGUAGE) NOT AVAILABLE:
      String targetLangId = "8";
      List<dynamic> foundTargetLanguages = List<dynamic>.from(availLanguages
          .where((dynamic lang) => lang["value"] == targetLanguage)
          .toList());
      if (foundTargetLanguages.isNotEmpty) {
        targetLangId = foundTargetLanguages[0]["LID"];
      }
      Map<String, dynamic> body = {
        "wordInput": lastInput,
        "languageIds": languageIds,
        "isAllLangs": isAllLanguages.toString(),
        "targetLangId": targetLangId,
        "isExactWordLengths": isExactWordLengths.toString(),
        "isMultipleWords": isMultipleWords.toString(),
        "selectedSearchTime": selectedSearchTime
      };
      print("MAKE ANAGRAMS NEW DATA = ${json.encode(body)}");
      dynamic data = {"SUCCESS": false};
      bool isSuccessGetData = false;
      try {
        final response = await http.post(
            Uri.parse(
                'https://www.learnfactsquick.com/anagram_maker/make_anagrams.php'),
            body: json.encode(body));
        //hideProgress(context);
        if (response.statusCode == 200) {
          data = Map<String, dynamic>.from(json.decode(response.body));
          //print("GET ANAGRAMS NEW data = ${json.encode(data)}");
          if (data["SUCCESS"] == true) {
            //countWords = data["COUNT_WORDS"];
            if (data["WORDS"] != null) {
              if (data["WORDS"] is Map<String, dynamic>) {
                foundWords = data["WORDS"];
              } else {
                foundWords = {};
              }
            } else {
              foundWords = {};
            }
            //print("GOT ANAGRAMS = ${json.encode(data)}");
            hideProgress(context);
            isSuccessGetData = true;
          } else {
            print("GET MAJOR WORDS ERROR: ${data["ERROR"]}");
            hideProgress(context);
            showPopup(context, data["ERROR"]);
          }
        } else {
          hideProgress(context);
          showPopup(context, FlutterI18n.translate(context, "NETWORK_ERROR"));
        }
      } catch (generalError) {
        hideProgress(context);
        showPopup(context, generalError.toString());
      }
      if (isSuccessGetData == true) {
        if (isMultipleWords == false) {
          print("GOING TO WordsPageNewSingle!");
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => WordsPageNewSingle(
                      isMultipleWords: isMultipleWords,
                      lastInput: lastInput,
                      countAnagrams: data["COUNT_WORDS"],
                      words: Map<String, List<dynamic>>.from(foundWords))));
        } else {
          print("GOING TO WordsPageNewMulti!");
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => WordsPageNewMulti(
                      isMultipleWords: isMultipleWords,
                      lastInput: lastInput,
                      countAnagrams: data["COUNT_WORDS"],
                      words: foundWords)));
        }
      }
    });
  }

  static final AdRequest request = AdRequest(
    keywords: <String>[
      'anagrams',
      'memorize lists',
      'improve memory',
      'rememer lists'
    ],
    contentUrl: 'https://learnfactsquick.com/#/anagram_maker',
    nonPersonalizedAds: true,
  );

  void createInterstitialAd() {
    //print("createInterstitialAd interstitialAd CALLED.");

    var appId = Platform.isAndroid
        ? 'ca-app-pub-8514966468184377/2341919859'
        : 'ca-app-pub-8514966468184377/4214749627';
    //print("Using appId: $appId kDebugMode = $kDebugMode");
    InterstitialAd.load(
        adUnitId: appId,
        request: request,
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            //print('My InterstitialAd $ad loaded');
            interstitialAd = ad;
            numInterstitialLoadAttempts = 0;
            interstitialAd!.setImmersiveMode(true);
            //print("interstitialAd == null ? : ${interstitialAd == null}");
          },
          onAdFailedToLoad: (LoadAdError error) {
            //print('interstitialAd failed to load: $error.');
            numInterstitialLoadAttempts += 1;
            interstitialAd = null;
            if (numInterstitialLoadAttempts < maxFailedLoadAttempts) {
              createInterstitialAd();
            }
          },
        ));
  }

  void showInterstitialAd(Function callback) {
    print("showInterstitialAd called");
    if (kIsWeb == true) {
      print('Web can not show ads.');
      callback();
    } else if (interstitialAd == null) {
      print('Warning: attempt to show interstitialAd before loaded.');
      callback();
    } else {
      Random random = Random();
      var isShowAd = (random.nextInt(1000) < MyApp().ofThousandShowAds);
      if (isShowAd != true) {
        callback();
      } else {
        interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdShowedFullScreenContent: (InterstitialAd ad) =>
              debugPrint('interstitialAd onAdShowedFullScreenContent.'),
          onAdDismissedFullScreenContent: (InterstitialAd ad) {
            ad.dispose();
            createInterstitialAd();
            callback();
          },
          onAdFailedToShowFullScreenContent:
              (InterstitialAd ad, AdError error) {
            ad.dispose();
            createInterstitialAd();
            callback();
          },
        );
        interstitialAd!.show();
        interstitialAd = null;
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (kIsWeb == false) {
      //print("DISPOSING interstitialAd !!!");
      interstitialAd?.dispose();
    }
  }

  isLinkPlayStore() {
    return (kIsWeb || Platform.isAndroid);
  }

  isLinkAppStore() {
    return (kIsWeb || Platform.isIOS);
  }

  setMultipleWords(isMultiple) {
    //print("setShowTable SET isShow = $isMultiple");
    setState(() {
      isMultipleWords = isMultiple; // == false ? true : false;
      //print("setShowTable SET isMultipleWords = $isMultipleWords");
    });
  }

  // To save data
  Future<void> setData(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

// To read data
  Future<String?> getData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  getTransLangValue(dynamic value) {
    return "${value["name1"]}(${FlutterI18n.translate(context, value["name2"])})";
  }

  selectAllNoLanguages() {
    setState(() {
      isAllLanguages = !isAllLanguages;
      if (isAllLanguages == true) {
        myFilteredLanguages = List<String>.from(
            availLanguages.map((lang) => getTransLangValue(lang)).toList());
        Set<String> uniqueMyFilteredLanguages = myFilteredLanguages.toSet();
        myFilteredLanguages = uniqueMyFilteredLanguages.toList();
      } else {
        myFilteredLanguages = [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    MyHomePageState().setSavedLanguage(context);
    double screenWidth = MediaQuery.of(context).size.width;
    double tabFontSize =
        (screenWidth * 0.020 + 4) < 15 ? 15 : (screenWidth * 0.020 + 4);
    double promptFontSize =
        (screenWidth * 0.016 + 4) < 11 ? 11 : (screenWidth * 0.016 + 4);
    appTitle = FlutterI18n.translate(context, "APP_TITLE");
    //final theme = Theme.of(context); // ← Add this.
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text(appTitle),
        actions: <Widget>[
          Menu(context: context, page: 'main', updateParent: updateSelf)
        ],
      ),
      body: SingleChildScrollView(
        child: Row(
          children: [
            Expanded(
              child: Container(
                width: screenWidth - 40,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                      child: TextField(
                          controller: inputController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: FlutterI18n.translate(
                                context, "PROMPT_LETTERS_NO_SPACES"),
                          ),
                          keyboardType: TextInputType.text,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(onlyLetters)
                          ],
                          onEditingComplete: () {
                            FocusScope.of(context).unfocus();
                            //}
                            doMakeAnagrams(
                                context, selectedAnagramLanguage["value"]);
                          }),
                    ),
                    Padding(
                        padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                        child: Row(children: [
                          Text(
                              FlutterI18n.translate(
                                  context, "PROMPT_EXACT_WORD_LENGTHS"),
                              style: TextStyle(fontSize: 12)),
                          Checkbox(
                              value: isExactWordLengths,
                              onChanged: (newValue) {
                                setState(() {
                                  isExactWordLengths = newValue!;
                                });
                              }),
                        ])),
                    Padding(
                        padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                        child: Row(children: [
                          Text(
                              FlutterI18n.translate(
                                  context, "PROMPT_MULTIPLE_WORDS"),
                              style: TextStyle(fontSize: 12)),
                          Checkbox(
                              value: isMultipleWords,
                              onChanged: (newValue) {
                                setMultipleWords(newValue);
                              }),
                        ])),
                    Visibility(
                      visible: isMultipleWords == true,
                      child: Padding(
                          padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                          child: Row(children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                              child: Text('# Searches /word count: ',
                                  style: TextStyle(fontSize: 12)),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                              child: DropdownButton<int>(
                                value: selectedSearchTime,
                                onChanged: (newValue) {
                                  setSelectedSearchTime(newValue!);
                                  //appState.selectedTheme = newValue!;
                                  //});
                                },
                                items: searchTimes
                                    .map<DropdownMenuItem<int>>((int value) {
                                  return DropdownMenuItem<int>(
                                    value: value,
                                    child: Text(value.toString(),
                                        style: TextStyle(fontSize: 12)),
                                  );
                                }).toList(),
                              ),
                            ),
                          ])),
                    ),
                    Padding(
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                        child: ElevatedButton(
                          onPressed: () async {
                            selectAllNoLanguages();
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: isAllLanguages == false
                                ? Colors.purple[200]
                                : Colors.grey[700],
                            minimumSize: Size(75, 25),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: Text(FlutterI18n.translate(
                              context,
                              (isAllLanguages == false
                                  ? FlutterI18n.translate(
                                      context, "SELECT_ALL_LANGUAGES")
                                  : FlutterI18n.translate(
                                      context, "SELECT_NO_LANGUAGES")))),
                        )),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                      child: Container(
                          decoration: BoxDecoration(color: Colors.white),
                          width: screenWidth - 40,
                          child: DropDownMultiSelect(
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(),
                            ),
                            isDense: true,
                            onChanged: (List<String> newList) {
                              setLanguages(context, List<String>.from(newList));
                            },
                            options: myList,
                            selectedValues: myFilteredLanguages,
                            whenEmpty: FlutterI18n.translate(
                                context, "SELECT_LANGUAGES"),
                          )),
                    ),
                    Padding(
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                        child: SizedBox(
                          width: screenWidth - 100,
                          child: ElevatedButton(
                            onPressed: () async {
                              //if (Platform.isAndroid) {
                              focusNode.unfocus();
                              //} else if (Platform.isIOS) {
                              FocusScope.of(context).unfocus();
                              //}
                              //await Future.delayed(Duration(seconds: 1), () {
                              // Code to be executed after the delay
                              //print("Delayed action executed!");
                              doMakeAnagrams(
                                  context, selectedAnagramLanguage["value"]);
                              //});
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.green,
                              minimumSize: Size(100, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            child: Text(FlutterI18n.translate(
                                context, "MAKE_ANAGRAMS")),
                          ),
                        )),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: SizedBox(
                          width: 250,
                          child: ElevatedButton(
                            onPressed: () {
                              // Add your button's functionality here
                              launch('https://learnfactsquick.com');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                  255,
                                  204,
                                  159,
                                  252), // Change the button's background color
                              foregroundColor:
                                  Colors.white, // Change the text color
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Image.asset(
                                  'assets/images/lfq_icon.png', // Path to your image asset
                                  width: 25, // Set the desired width
                                  height: 25, // Set the desired height
                                ),
                                SizedBox(width: 8),
                                Text(
                                    FlutterI18n.translate(
                                        context, "PROMPT_TOOLS_WEBSITE"),
                                    style: TextStyle(fontSize: 10)), // Text
                              ],
                            ),
                          )),
                    ),
                    Visibility(
                      visible: isLinkPlayStore(),
                      child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: SizedBox(
                            width: 250,
                            child: ElevatedButton(
                              onPressed: () {
                                // Add your button's functionality here
                                launch(
                                    'https://play.google.com/store/apps/dev?id=5263177578338103821');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors
                                    .green, // Change the button's background color
                                foregroundColor:
                                    Colors.white, // Change the text color
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(Icons
                                      .play_circle_fill), // Google Play icon
                                  SizedBox(
                                      width:
                                          8), // Add some space between the icon and text
                                  Text(
                                      FlutterI18n.translate(
                                          context, "PROMPT_APPS_PLAY_STORE"),
                                      style: TextStyle(fontSize: 10)), // Text
                                ],
                              ),
                            )),
                      ),
                    ),
                    Visibility(
                      visible: isLinkAppStore(),
                      child: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: SizedBox(
                              width: 250,
                              child: ElevatedButton(
                                onPressed: () {
                                  // Add your button's functionality here
                                  launch(
                                      'https://apps.apple.com/us/developer/keith-harryman/id1693739510');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors
                                      .blue, // Change the button's background color
                                  foregroundColor:
                                      Colors.white, // Change the text color
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(Icons
                                        .download_sharp), // Google Play icon
                                    SizedBox(
                                        width:
                                            8), // Add some space between the icon and text
                                    Text(
                                        FlutterI18n.translate(
                                            context, "PROMPT_APPS_APP_STORE"),
                                        style: TextStyle(fontSize: 10)), // Text
                                  ],
                                ),
                              ))),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomPopupMenuItem<T> extends PopupMenuItem<T> {
  final double width;

  CustomPopupMenuItem({
    required T value,
    required Widget child,
    this.width = 200.0, // Set a default width or adjust as needed
  }) : super(value: value, child: child);

  //@override
  //double get width => 100;
}
