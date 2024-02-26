//import 'dart:collection';
//import 'dart:js_interop';

//import 'dart:convert';
import 'dart:io';
import 'dart:math';

//kIsWeb : SIMILIAR TO NOT isApp() FUNCTION====>
import 'package:anagram_maker/dictionary.dart';
import 'package:anagram_maker/words.dart';
import 'package:flutter/foundation.dart';

//import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
//import 'package:anagram_maker/words.dart';
import 'package:flutter/services.dart';
//import 'package:provider/provider.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';

const String testDevice = '974550CBC7D4EA4718A67165E2E3B868';
const String myIpad = '00008020-0014301102D1002E';
const String myIphone11 = 'A8EC231A-DCFC-405C-8A0D-62E9F5BA1918';
const int maxFailedLoadAttempts = 3;
InterstitialAd? interstitialAd;
int numInterstitialLoadAttempts = 0;

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
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  final int ofThousandShowAds = 350;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anagram Maker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromRGBO(200, 255, 200, 1.0)),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final myDic = {
    "a": dicList1,
    "b": dicList2,
    "c": dicList3,
    "d": dicList4,
    "e": dicList4,
    "f": dicList5,
    "g": dicList5,
    "h": dicList5,
    "i": dicList6,
    "j": dicList6,
    "k": dicList6,
    "l": dicList6,
    "m": dicList7,
    "n": dicList7,
    "o": dicList7,
    "p": dicList8,
    "q": dicList8,
    "r": dicList8,
    "s": dicList9,
    "t": dicList10,
    "u": dicList10,
    "v": dicList10,
    "w": dicList10,
    "x": dicList10,
    "y": dicList10,
    "z": dicList10,
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
  static const appTitle = 'Anagram Maker';
  static String helpText = '';

  FocusNode focusNode = FocusNode();
  final RegExp onlyLetters = RegExp(r'^[a-zA-Z]+$');
  final TextEditingController inputController = TextEditingController();
  String lastInput = "";
  bool isLoading = false;
  bool isMultipleWords = false;
  List<int> searchTimes = [
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
  int selectedSearchTime = 10;
  bool isExactWordLengths = false;

  @override
  void initState() {
    super.initState();
    helpText +=
        '<strong style="font-style:">What are Anagrams?:</strong><br />';
    helpText +=
        '<span style="font-style:italic;">They are words created by scrambling the letters of a word.</span><br />';
    helpText +=
        '<br /><strong style="font-size: 16pt;font-style:italic;"><u>Help:</u></strong><ul style="padding:0px;">';
    helpText +=
        '<li><b>Option <i>"Show Exact Word Length(s)?"</i></b><br />Check to make anagrams with the same word length.<br />For example, If checked :<br />';
    helpText +=
        '<div style="margin-left: 10px;"><i>"LISTEN"</i> will create anagrams:</div><div style="margin-left: 15px;">1)ENLIST<br />2)SILENT';
    helpText +=
        '</div>If not checked it will find additional words to match the beginning letters: "ENLISTed", "LISTENing"';
    helpText +=
        '</li><li><b>Option <i>"Show Multiple Words?"</i></b><br />Check to break anagram into multiple words.<br />For example, If checked :<br />';
    helpText +=
        '<div style="margin-left: 10px;"><i>"WELDON"</i> will create anagrams:</div><div style="margin-left: 15px;">1)ENLightened DOWdiness<br />2)ENWrapped OLDish';
    helpText += '<br />→ <b>Option <i>"# Searches /word count"</i></b>';
    helpText +=
        '<br />Choose for how many times to randomly search(success/fail) for each count of anagrams used to represent the word.';
    helpText += '</ul>';
    if (kIsWeb == false) {
      createInterstitialAd();
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

  void setSelectedSearchTime(int searchTime) {
    setState(() {
      selectedSearchTime = searchTime;
    });
  }

  List<dynamic> getWords(String inputWord) {
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
      dicWords = MyHomePage().myDic[uniqueLetters[i]]!;
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

  Future<void> makeAnagrams(context) async {
    if (inputController.text.trim() == '') {
      showPopup(context, "Please enter letters to make anagrams of.");
      return;
    }
    MyHomePageState().showInterstitialAd(() async {
      isLoading = true;
      showProgress(context, 'Making anagrams..');
      await Future.delayed(Duration(milliseconds: 300));
      //print("makeAnagrams called inpt = ${inputController.text}");
      //print(inputController.text);
      lastInput = inputController.text;
      //print("isMultipleWords = $isMultipleWords");
      List<dynamic> foundWords = [];
      if (isMultipleWords == false) {
        foundWords = getWords(lastInput);
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
        for (int n = 2; n <= maxWords; n++) {
          minDiv = (numLetters / n).floor();
          maxDiv = (numLetters / n).ceil();
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
        //print("uniqueLetters = ${json.encode(uniqueLetters)}");
        for (int i = 0; i < uniqueLetters.length; i++) {
          dicWords = MyHomePage().myDic[uniqueLetters[i]]!;
          for (String word in dicWords.keys) {
            if (word.length >= lastInput.length) {
              getLetters = [];
              for (int k = 0; k < lastInputSplit.length; k++) {
                getLetters.add(lastInputSplit[k]);
              }
              //print("getLetters = ${json.encode(getLetters)}");
              isFound = true;
              findWordSplit = word.toLowerCase().split("");
              countMatch = 0;
              for (var j = 0; j < lastInput.length; j++) {
                if (getLetters.contains(findWordSplit[j])) {
                  getLetters.remove(findWordSplit[j]);
                  countMatch++;
                } else {
                  break;
                }
              }
              if (numberCombos.contains(countMatch) &&
                  (isExactWordLengths == false || word.length == countMatch)) {
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
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => WordsPage(
                  isMultipleWords: isMultipleWords,
                  lastInput: lastInput,
                  words: foundWords)));
    });
  }

  static final AdRequest request = AdRequest(
    keywords: <String>[
      'anagrms',
      'memorize lists',
      'improve memory',
      'rememer lists'
    ],
    contentUrl: 'https://learnfactsquick.com/#/major_system_generator',
    nonPersonalizedAds: true,
  );

  void createInterstitialAd() {
    //print("createInterstitialAd interstitialAd CALLED.");

    var appId = Platform.isAndroid
        ? 'ca-app-pub-8514966468184377/2341919859'
        : 'ca-app-pub-8514966468184377/5883541243';
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

  @override
  Widget build(BuildContext context) {
    //final theme = Theme.of(context); // ← Add this.
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: MaterialApp(
                  title: appTitle,
                  debugShowCheckedModeBanner: false,
                  home: Scaffold(
                    appBar: AppBar(
                      title: const Text(appTitle),
                      actions: <Widget>[MyPopup()],
                    ),
                    body: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                          child: TextField(
                              controller: inputController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Enter letters(no spaces)',
                              ),
                              keyboardType: TextInputType.text,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(onlyLetters)
                              ],
                              onEditingComplete: () {
                                FocusScope.of(context).unfocus();
                                //}
                                makeAnagrams(context);
                              }),
                        ),
                        Padding(
                            padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                            child: Row(children: [
                              Text('Show Exact Word Length(s)?',
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
                              Text('Show Multiple Words?',
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
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                  child: Text('# Searches /word count: ',
                                      style: TextStyle(fontSize: 12)),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(15, 0, 0, 0),
                                  child: DropdownButton<int>(
                                    value: selectedSearchTime,
                                    onChanged: (newValue) {
                                      setSelectedSearchTime(newValue!);
                                      //appState.selectedTheme = newValue!;
                                      //});
                                    },
                                    items: searchTimes
                                        .map<DropdownMenuItem<int>>(
                                            (int value) {
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
                            padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
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
                                makeAnagrams(context);
                                //});
                              },
                              child: Text('Make Anagrams'),
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
                                    Text('See other tools from the website',
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
                                      Text('See other apps from Play Store',
                                          style:
                                              TextStyle(fontSize: 10)), // Text
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Icon(Icons
                                            .download_sharp), // Google Play icon
                                        SizedBox(
                                            width:
                                                8), // Add some space between the icon and text
                                        Text('See other apps from App Store',
                                            style: TextStyle(
                                                fontSize: 10)), // Text
                                      ],
                                    ),
                                  ))),
                        ),
                      ],
                    ),
                  ),
                )),
          ),
        ],
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

// ignore: must_be_immutable
class MyPopup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
        constraints: BoxConstraints(
          minWidth: 2.0 * 56.0,
          maxWidth: MediaQuery.of(context).size.width,
        ),
        icon: Icon(Icons.menu),
        onSelected: (value) {
          //focusNode.unfocus();
          FocusScope.of(context).unfocus();
          //print("Selected Menu makeAnagrams showInterstitialAd CALLING...");
          MyHomePageState().showInterstitialAd(() {});
        },
        itemBuilder: (BuildContext context) {
          return [
            PopupMenuItem<String>(
                value: 'Help',
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                      padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                      child: Html(data: MyHomePageState.helpText)),
                ))
          ];
        });
  }
}
