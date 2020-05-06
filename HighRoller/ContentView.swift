//
//  ContentView.swift
//  HighRoller
//
//  Created by Jeffrey Williams on 5/2/20.
//  Copyright © 2020 Jeffrey Williams. All rights reserved.
//
import CoreHaptics
import CoreData
import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.presentationMode) var presentationMode
    @State private var isShowingSettings = false
    @State private var dice = [Die]()
    @State private var values: [Int] = []
    @State private var engine: CHHapticEngine?
    
    var total: Int {
        return values.reduce(0, +)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                VStack(spacing: 50) {
                    Text("Total:  \(self.total)")
                        .font(.title)
                    
                    HStack(spacing: 50) {
                        ForEach(values, id: \.self) { die in
                            Image(systemName: "\(die).circle")
                                .font(.largeTitle)
                                .accessibility(value: Text("\(die)"))
                        }
                    }
                }

                Spacer()
                
                Button("Roll") {
                    self.rollDice()
                }
                .frame(width: 100, height: 50)
                .background(Color.blue)
                .foregroundColor(Color.white)
                .clipShape(Capsule())
                
                Spacer()
            }
            .sheet(isPresented: $isShowingSettings) {
                SettingsView(dice: self.$dice).environment(\.managedObjectContext, self.moc)
            }
            .navigationBarTitle("High Roller")
            .navigationBarItems(trailing:
                Button(action: {
                    self.isShowingSettings = true
                }) {
                    Image(systemName: "gear")
                        .font(.title)
                }
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear(perform: setup)
    }
    
    func setup() {
        loadDice()
        prepareHaptics()
    }
        
    func loadDice() {
        let dice1 = Die(sides: 6)
        let dice2 = Die(sides: 6)
        self.dice.append(contentsOf: [dice1, dice2])
        self.values = dice.map { $0.value }
    }
    
    func rollDice() {
        // perform 7 rolls to simulate rolling
        for i in 1...7 {
            let delay = Double(i) * Double(i) / 50
            // start fast, end slow
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.values = self.dice.map { $0.value }
                self.feedback()
            }
        }
        
        // save to coredata after rolls have finished
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.addToDatabase(value: self.total)
        }
    }
    
    func addToDatabase(value: Int) {
        let roll = DiceRoll(context: self.moc)
        roll.value = Int16(value)
        roll.sequence = Date()
        
        do {
            try self.moc.save()
        } catch {
            print("Unable to save to Core data!")
        }
    }
        
    func feedback() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        var events = [CHHapticEvent]()
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        events.append(event)
        
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription).")
        }
    }
    
    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            self.engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("There was an error creating the engine: \(error.localizedDescription)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
