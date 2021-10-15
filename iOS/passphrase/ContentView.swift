//
//  ContentView.swift
//  passphrase
//
//  Created on 2021-06-08.
//

func getFile(filename: String) -> String {
    var contents: String = "Nothing found"
    if let filepath = Bundle.main.path(forResource: filename, ofType: "txt") {
        do {
            contents = try String(contentsOfFile: filepath)
        } catch {
            // contents could not be loaded
            let _ = Alert(
                title:Text("File loading failed."),
                message:Text("\(filename) encountered an error while loading.")
            )
        }
    } else {
        // file not found!
        let _ = Alert(
            title:Text("File loading failed."),
            message:Text("\(filename) could not be located.")
        )
    }
    return contents
}

let reports = getFile(filename: "reports").split(whereSeparator: \.isNewline)
let nouns = getFile(filename: "n").split(whereSeparator: \.isNewline)
let nounsingle = getFile(filename: "n1").split(whereSeparator: \.isNewline)
let adjectives = getFile(filename: "a").split(whereSeparator: \.isNewline)
let punctuation = getFile(filename: "p").split(whereSeparator: \.isNewline)

import MobileCoreServices // for clipboard
import SwiftUI
import MessageUI
import CommonCrypto
import CryptoKit

struct ContentView: View {
    
    @Environment(\.openURL) var openURL
    
    @State var lowerNumberLimit: Int = 0
    @State var upperNumberLimit: Int = 10
    @State var numberOfAdjectives: Int = 2
    @State var uppercaseSentence: Bool = true
    @State var addPunctuation: Bool = true
    @State var addCommaAfterAdjective: Bool = true
    @State var addNumber: Bool = true
    
    
    
    @State var genCount: Int = UserDefaults.standard.integer(forKey: "Gens")
    
    @State var sentence = "Tap to generate"
    
    @State var reportURL = URL(string:"https://docs.google.com/forms/d/1b9ts7sJgAWQgGu-ndVaJFHdQSeHkKPw5Bn3buT47w1I")
    
    func hash(inputString: String) -> String {
        let inputData = Data(inputString.utf8)
        let hashed = SHA256.hash(data: inputData)
        let hashString = hashed.compactMap { String(format: "%02x", $0) }.joined()
        return hashString
    }
    
    func passphrase() {
        sentence = ""
        let number = Int.random(in: lowerNumberLimit ... upperNumberLimit)
        if addNumber {
            sentence += "\(number) "
        }
        if numberOfAdjectives != 0 {
            for i in 1 ... numberOfAdjectives {
                if numberOfAdjectives == 1 || i == numberOfAdjectives {
                    sentence += "\(adjectives.randomElement()!) "
                } else {
                    if addCommaAfterAdjective {
                        sentence += "\(adjectives.randomElement()!), "
                    } else {
                        sentence += "\(adjectives.randomElement()!) "
                    }
                }
            }
        }
        
        var noun = nouns.randomElement()
        if number == 1 || addNumber == false {
            noun = nounsingle.randomElement()
        }
        sentence += "\(noun!)"
        if addPunctuation {
            let punctuation = punctuation.randomElement()
            sentence += "\(punctuation!)"
        }
        if uppercaseSentence {
            sentence = sentence.capitalized
        } else {
            sentence = sentence
        }
        //sentence += "\n \(hash(inputString: sentence))"
        genCount += 1
        UserDefaults.standard.set(self.genCount, forKey: "Gens")
        let sentenceURL = sentence.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        reportURL=URL(string:"https://docs.google.com/forms/d/e/1FAIpQLSdMCBCvWt6J53Byorgjv_Jnuz6Ixib5mhVziUJpmi4KHsXxvA/viewform?usp=pp_url&entry.1868293312=\(sentenceURL ?? "error while converting to url")&entry.582945280=\(hash(inputString: sentence))")
    }
    
    func combinations() -> Int {
        var combinations: Int = 1
        if addNumber {
            combinations = (upperNumberLimit - lowerNumberLimit) + 1
            if upperNumberLimit == 1 && lowerNumberLimit == 1 {
                combinations *= nounsingle.count
            } else {
                combinations *= (nouns.count+nounsingle.count)
            }
        } else {
            combinations = nounsingle.count
        }
        if addPunctuation {
            combinations *= punctuation.count
        }
        let adjectivecount = pow(Double(adjectives.count), Double(numberOfAdjectives))
        
        combinations *= Int(adjectivecount)
        return combinations
    }
    
    func copy() {
        UIPasteboard.general.string = sentence
    }
    
    func reset() {
        lowerNumberLimit = 0
        upperNumberLimit = 10
        numberOfAdjectives = 2
        uppercaseSentence = true
        addPunctuation = true
        addCommaAfterAdjective = true
        addNumber = true
    }
    
    func enoughEntropy() -> Bool {
        if combinations() >= 1_000_000_000 {
            return true
        } else {
            return false
        }
    }
    
    
    
    var body: some View {
        TabView{
            NavigationView {
                
                VStack() {
                    
                    
                    Button(action: passphrase) {
                        VStack {
                            if reports.contains(Substring(hash(inputString: sentence))) {
                                Text("This sentence has been reported before.").font(.footnote)
                                    .foregroundColor(Color("Warn"))
                                    .multilineTextAlignment(.center)
                            } else {
                                Text("").font(.footnote)
                                    .foregroundColor(Color("Warn"))
                                    .multilineTextAlignment(.center)
                            }
                            Text(sentence as String)
                                .font(.title2)
                                .foregroundColor(Color("HighlightColour"))
                                .multilineTextAlignment(.leading)
                            
                            if sentence != "Tap to generate" { Text("Tap to generate.")
                                .font(.caption)
                                .multilineTextAlignment(.center)
                            } else { Text("Can anyone see your screen?")
                                .font(.footnote)
                                .foregroundColor(Color("Warn"))
                                .multilineTextAlignment(.center)
                            }
                            
                        }
                        .padding()
                        
                    }
                    
                    
                    
                    
                    HStack(alignment: .center) {
                        if sentence != "Tap to generate" { Button {
                            copy()
                        } label: {
                            Text("Copy")
                        }
                        .padding()
                        .background(Color("ButtonColour"))
                        .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                        
                        } else { Button {
                            copy()
                        } label: {
                            Text("Copy")
                        }
                        .padding()
                        .disabled(true)
                        .background(Color("ButtonColour"))
                        .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                        }
                    }
                    
                    
                }.navigationTitle("Generate")
            }.navigationViewStyle(StackNavigationViewStyle()).tabItem {
                Image(systemName: "wand.and.stars")
                Text("Generate")
            }
            NavigationView {
                ScrollView {
                    VStack {
                        Text("Number")
                            .font(.headline)
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal)
                        Toggle("Add number", isOn: $addNumber).padding(.horizontal)
                        Stepper("Lower Limit: \(lowerNumberLimit)", value: $lowerNumberLimit, in: 0 ... upperNumberLimit).padding(.horizontal)
                        Stepper("Upper Limit: \(upperNumberLimit)", value: $upperNumberLimit, in: lowerNumberLimit ... 100).padding(.horizontal)
                    }
                    VStack {
                        Text("Adjectives")
                            .font(.headline)
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal)
                        Stepper("Number of adjectives: \(numberOfAdjectives)", value: $numberOfAdjectives, in: 0 ... 4).padding(.horizontal)
                    }
                    VStack {
                        Text("Punctuation")
                            .font(.headline)
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal)
                        
                        Toggle("Add punctuation", isOn: $addPunctuation).padding(.horizontal)
                        
                        Toggle("Add comma", isOn: $addCommaAfterAdjective).padding(.horizontal)
                    }
                    
                    VStack {
                        Text("Sentence")
                            .font(.headline)
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal)
                        Toggle("Capitalise words", isOn: $uppercaseSentence).padding(.horizontal)
                    }
                    if enoughEntropy() {
                        Text("\(combinations())\n possible combinations.").font(.headline).multilineTextAlignment(.center)
                    } else {
                        Text("\(combinations())\n possible combinations may not be senough!").font(.headline).multilineTextAlignment(.center).foregroundColor(Color("Warn"))
                    }
                    
                    Button {
                        reset()
                    } label: {
                        Text("Reset to defaults")
                    }
                    .padding()
                    .background(Color("ButtonColour"))
                    .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                    Spacer()
                    if genCount==1 {
                        Text("\(genCount) passphrase generated")
                    } else {
                        Text("\(genCount) passphrases generated")
                    }
                    Spacer()
                }.navigationTitle("Options")
                
            }.navigationViewStyle(StackNavigationViewStyle()).tabItem {
                Image(systemName: "gearshape")
                Text("Options")
            }
            NavigationView {
                ScrollView{
                    //VStack {
                    //    Text("Why use passphrases?").font(.headline)
                    //    Text("Passwords are an essential part of everyone’s life. But they’re hard to remember, hard to make secure, and annoying to come up with. By creating passphrases instead of passwords, we can make it easier to remember them. This app creates grammatically correct sentences that meet all the requirements for a secure password - they’re long, have mixed capitalization, numbers, and special characters.").font(.body).multilineTextAlignment(.leading).padding()
                    //}.padding(.vertical)
                    VStack {
                        Text("How secure is this app?").font(.headline)
                        Text("The short answer is ”probably secure”.").font(.subheadline)
                        Text("The long answer is ”it depends”. This app is written in Swift and SwiftUI. It uses the system’s random number generator, which the Swift documentation says is secure. On iOS devices it is (according to Apple), so the app should be fine in terms of secure random. The bigger concern when using a tool like this is the limited dictionary. An attacker with a copy of your hashed password and with knowledge of how you generated it (i.e. this app and the options you have chosen) could check all the possible hashes in a number of hours. However, the likely hood of \na) the attacker knowing those things... \nb) the attacker being willing to extract the dictionaries used just to obtain one password... \nc) the likelihood that they would have access to your hashed password (which would require the service you are using the password with to get hacked)... \nis miniscule. That is to say, this app is less than ideal for individuals who feel they may be directly targeted, but for everyone else, it’s fine. The ideal use case for an application like this would be to use it to create a master password for a password manager, which would not store your hashed password as the decryption of the vault is done locally. That means that the attacker would have to compromise the encryption between your device and the password manager’s servers, or otherwise obtain the vault, obtain knowledge of the exact options used to generate the password, and be willing to try billions of potential matches, which would take longer without knowledge of the hashed form of the password (as the attacker would need to attempt to decrypt the blob for every password). This significantly decreases the attack surface.").font(.body).multilineTextAlignment(/*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/).padding()
                    }.padding(.vertical)
                    VStack {
                        Text("How big are the dictionaries?").font(.headline)
                        Text("The number of items in each dictionary fluctuates between versions as bad combinations are removed and new words are added. Here's the current count:\nPlural Nouns: \(nouns.count)\nSingular Nouns: \(nounsingle.count)\nAdjectives: \(adjectives.count)\nPunctuation: \(punctuation.count)\nReported Sentences: \(reports.count)").font(.body).multilineTextAlignment(/*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/).padding()
                    }.padding(.vertical)
                    
                    VStack {
                        Text("How can I report a bad combination?").font(.headline)
                        Text("I try my best to make sure there are no incorrect or inappropriate sentence combinations. If you think you've got a bad one, please report it. This will send me a copy of the generated passphrase, so please don't use it if you report it. Depending on what's wrong with the passphrase, we'll either completely remove it, or we'll place a warning above it when it's generated.").font(.body).multilineTextAlignment(/*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/).padding()
                        if reportURL != nil && sentence != "Tap to generate" {
                            Button("Report \"\(sentence)\"") {
                                openURL(reportURL!)
                            }.padding()
                            .background(Color("ButtonColour"))
                            .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                            
                            if reports.contains(Substring(hash(inputString: sentence))) {
                                Text("This sentence has been reported before.").font(.footnote)
                                    .foregroundColor(Color("Warn"))
                                    .multilineTextAlignment(.center)
                            }} else {
                                Button("Report") {
                                    openURL(reportURL!)
                                }.padding()
                                .background(Color("ButtonColour"))
                                .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                                .disabled(true)
                            }
                    }.padding(.vertical)
                }.navigationTitle("About")
            }.navigationViewStyle(StackNavigationViewStyle()).tabItem {
                Image(systemName: "info.circle")
                Text("About")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
            ContentView()
        }
    }
}
