var fs = require('fs');
const currentDirectory = process.cwd();

const getMajorSystemNumber = (inputWord) => {
    //console.log("getMajorSystemNumber called. word=" + input_word);
    var defspl = inputWord.toLowerCase().split("");
    var wl = defspl.length;
    var z = 0;
    var num = "";
    for (var i = 0; i < wl; i++) {
        z = i + 1;
        if (defspl[i] == "s") {
            if (z < wl) {
                if (defspl[z] != "h") {
                    num += "0";
                }
            } else if (z >= wl) {
                num += "0";
            }
        }
        if (defspl[i] == "z") {
            num += "0";
        }
        if (defspl[i] == "d" || defspl[i] == "t") {
            num += "1";
        }
        if (defspl[i] == "n") {
            num += "2";
        }
        if (defspl[i] == "m") {
            num += "3";
        }
        if (defspl[i] == "r") {
            num += "4";
        }
        if (defspl[i] == "l") {
            num += "5";
        }
        if (defspl[i] == "j") {
            num += "6";
        }
        if (defspl[i] == "c" && z < wl) {
            if (defspl[z] == "h") {
                num += "6";
            }
        }
        if (defspl[i] == "s" && z < wl) {
            if (defspl[z] == "h") {
                num += "6";
            }
        }
        if (defspl[i] == "g") {
            if (z < wl) {
                if (defspl[z] != "g" && defspl[z] != "h") {
                    num += "6";
                } else if (defspl[z] == "h") {
                    num += "7";
                    i++;
                } else if (defspl[z] == "g") {
                    num += "7";
                }
            } else if (z == wl) {
                num += "7";
            }
        }
        if (defspl[i] == "c") {
            if (z < wl) {
                if (defspl[z] != "h") {
                    num += "7";
                }
            } else if (z >= wl) {
                num += "7";
            }
        }
        if (defspl[i] == "k" || defspl[i] == "q") {
            num += "7";
        }
        if (defspl[i] == "f" || defspl[i] == "v") {
            num += "8";
        }
        if (defspl[i] == "p" && z < wl) {
            if (defspl[z] == "h") {
                num += "8";
            }
        }
        if (defspl[i] == "b") {
            num += "9";
        }
        if (defspl[i] == "p") {
            if (z < wl) {
                if (defspl[z] != "h") {
                    num += "9";
                }
            } else if (z >= wl) {
                num += "9";
            }
        }
    }
    //console.log("getMajorSystemNumber num = " + num);
    return num;
}

fs.readdir(currentDirectory + "/build/flutter_assets/packages/dictionaryx/assets", (err, files) => {

    var numFiles = 0;
    var jsonFiles = [];
    files.forEach(fileName => {
        fileSplit = fileName.split(".");
        if (fileSplit.slice(-1)[0] === "json") {
            numFiles++;
            //console.log("FILE:" + file);
            jsonFiles.push(fileName);
        }
    });
    //console.log("jsonFiles = " + jsonFiles);
    console.log("NUMBER FILES = " + numFiles);
    var myDict = [];
    var dictObj = {};
    var myDictObj = {};
    var Ms = [];
    var Ss = [];
    var POSs = {
        "Noun": "1",
        "Adjective": "2",
        "Verb": "3",
        "Adverb": "4"
    };
    var countTids = 1;
    var appendJson = function (fileIndex, jsonFiles) {
        if (fileIndex < jsonFiles.length) {
            fs.readFile(currentDirectory + "/build/flutter_assets/packages/dictionaryx/assets/" + jsonFiles[fileIndex], function (err, jsonStr) {
                if (err) {
                    console.log("READ FILE ERROR: " + JSON.stringify(err));
                }
                //console.log("READ FILE: " + jsonFiles[fileIndex]);
                var json = JSON.parse(jsonStr);
                //if(fileIndex === 0){
                //console.log("GOT JSON : " + JSON.stringify(json));
                var words = Object.keys(json);
                //console.log("GOT WORDS: " + words);
                for (var i = 0; i < words.length; i++) {
                    dictObj = json[words[i]];
                    myDictObj = {};
                    myDictObj["Word"] = words[i];
                    myDictObj["LID"] = "8";
                    myDictObj["TID"] = (countTids).toString();
                    myDictObj["Num"] = getMajorSystemNumber(words[i]);
                    myDictObj["Defs"] = [];
                    Ms = dictObj["M"];
                    for (var j = 0; j < Ms.length; j++) {
                        myDictObj["Defs"].push({
                            "PID": POSs[Ms[j][0]],
                            "Def": Ms[j][1]
                        })
                    }
                    if (Ms.length === 0) {
                        Ss = dictObj["S"];
                        if (Ss.length > 0 && Ss[0].trim() !== "")
                            myDictObj["Defs"].push({
                                "PID": "1",
                                "Def": Ss[0]
                            })
                    }
                    //if(fileIndex===0 && i<10){
                    myDict.push(myDictObj);
                    countTids++;
                    //}
                }
                //}
                fileIndex++;
                appendJson(fileIndex, jsonFiles);
            });
        } else {
            myDict.sort((a, b) => a.Word.localeCompare(b.Word));
            //console.log("GOT myDict = " + JSON.stringify(myDict));
            var myFile = currentDirectory + "/dict_big.json";
            fs.writeFile(myFile, JSON.stringify(myDict, null, 2), (err) => {
                if (err) {
                    console.error('Error writing to file:', err);
                    resolve();
                }
                console.log('Saved file ' + myFile + ".");
                console.log("ALL DONE CREATING BIG JSON DICT!");
            });
        }
    }
    appendJson(0, jsonFiles);
});