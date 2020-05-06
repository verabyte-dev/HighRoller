//
//  SettingsView.swift
//  HighRoller
//
//  Created by Jeffrey Williams on 5/2/20.
//  Copyright © 2020 Jeffrey Williams. All rights reserved.
//
import CoreData
import SwiftUI

struct SettingsView: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.presentationMode) var presentationMode
    @FetchRequest(entity: DiceRoll.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \DiceRoll.sequence, ascending: false)]) var rolls: FetchedResults<DiceRoll>
    @State private var numberOfDice = 2
    @State private var sidesSelected = 1
    @Binding var dice: [Die]
    
    let sides = [4, 6, 8, 10, 12, 20, 100]
    
    var numberOfSides: Int {
        return sides[sidesSelected]
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Stepper(value: $numberOfDice, in: 1...5) {
                        Text("Number of dice:   \(numberOfDice)")
                    }
                }
                
                Section {
                    Stepper(value: $sidesSelected, in: 0...sides.count - 1) {
                        Text("Number of sides:  \(numberOfSides)")
                    }
                }
                
                Section(header: Text("Dice Roll History")) {
                    List(rolls, id: \.self) { roll in
                        Text("\(roll.value)")
                    }
                }
            }
            .navigationBarTitle("Settings")
            .navigationBarItems(trailing: Button("Done", action: dismiss))
            .onAppear(perform: loadDice)
            .onDisappear(perform: updateDice)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func dismiss() {
        self.presentationMode.wrappedValue.dismiss()
    }
    
    func loadDice() {
        self.numberOfDice = self.dice.count
        self.sidesSelected = self.sides.firstIndex(where: { $0 == self.dice.first?.sides}) ?? 2
    }
    
    func updateDice() {
        self.dice = []
        for _ in 0..<numberOfDice {
            let die = Die(sides: numberOfSides)
            dice.append(die)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    
    static var previews: some View {
        let roll = DiceRoll(context: moc)
        roll.value = 5
        
        return NavigationView {
            SettingsView(dice: .constant([Die(sides: 6), Die(sides: 6)]))
        }
    }
}
