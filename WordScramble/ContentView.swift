//
//  ContentView.swift
//  WordScramble
//
//  Created by Arthur Sh on 06.11.2022.
//

import SwiftUI

struct ContentView: View {
    
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    @State private var playerScore = 0
    
    var body: some View {
        NavigationStack{
            List() {
                Section{
                    TextField("Enter your word", text: $newWord)
                        .autocapitalization(.none)
                }
                
                ForEach(usedWords, id: \.self) { word in
                    HStack{
                        Image(systemName: "\(word.count).circle")
                        Text(word)
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("\(word), \(word.count) latters")
                }
                
                
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError){
                Button("OK", role: .cancel){}
            } message: {
                Text(errorMessage)
            }
            .toolbar{
                Button("Shuffle") {
                    startGame()
                    playerScore -= 2
                }
            }
            
            VStack{
                Text("Your score is \(playerScore)")
            }
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else{return}
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word is already used", message: "Be original")
            return
        }
        guard isPossible(word: answer) else {
            wordError(title: "Word is not possible", message: "You can't spell that word from \(rootWord)")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word isn't recognized", message: "You can't just make them up, you know!")
            return
        }
        
        guard shortNotAllowed(word: answer) else {
            wordError(title: "It's only \(answer.count) letters", message: "Shorties not allowed")
            return
        }
        
        guard clonesNotAllowed(word: answer) else {
            wordError(title: "Clone", message: "You're trying to use the main word")
            return
            
        }
        
        guard addPoints(word: answer) else {
            wordError(title: "Can't give you points", message: "Word is too short")
             return
        }
        
        withAnimation{
            usedWords.insert(answer, at: 0)
        }
        newWord = ""
    }
    
    func startGame(){
        if let startWordsUrl = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startWord = try? String(contentsOf: startWordsUrl){
                let allSeparatedWord = startWord.components(separatedBy: "\n")
                rootWord = allSeparatedWord.randomElement() ?? "silkWorm"
                return
            }
        }
        fatalError("Couldn't load text.txt")
    }
    
    func isOriginal (word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            }else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String){
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    func shortNotAllowed (word: String) -> Bool {
        if word.count < 3 {
            return false
        }
        return true
    }
    
    func clonesNotAllowed(word: String) -> Bool {
        if rootWord == word {
            return false
        } else {
            return true
        }
        
    }
    
    func addPoints (word: String) -> Bool{
        if word.count >= 4 {
            playerScore += 10
        } else if word.count >= 5 {
            playerScore += 15
        } else if word.count >= 6 {
            playerScore += 20
        } else if word.count >= 7 {
            playerScore += 25
        } else {
            playerScore += 30
        }
        return true
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
