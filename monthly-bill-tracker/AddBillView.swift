import SwiftUI

struct AddBillView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var billStore: BillStore
    
    @State private var billName = ""
    @State private var amount = ""
    @State private var dueDay = 1
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Bill Details") {
                    TextField("Bill Name", text: $billName)
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                    
                    Picker("Due Day", selection: $dueDay) {
                        ForEach(1...31, id: \.self) { day in
                            Text("\(day)\(day.ordinalSuffix)")
                                .tag(day)
                        }
                    }
                }
            }
            .navigationTitle("Add New Bill")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveBill()
                    }
                }
            }
            .alert("Error", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func saveBill() {
        guard !billName.isEmpty else {
            alertMessage = "Please enter a bill name"
            showingAlert = true
            return
        }
        
        guard let amountDouble = Double(amount) else {
            alertMessage = "Please enter a valid amount"
            showingAlert = true
            return
        }
        
        let newBill = Bill(
            name: billName,
            amount: amountDouble,
            dueDay: dueDay
        )
        
        billStore.addBill(newBill)
        dismiss()
    }
}

// Extension to add ordinal suffix to numbers (1st, 2nd, 3rd, etc.)
extension Int {
    var ordinalSuffix: String {
        let j = self % 10
        let k = self % 100
        if j == 1 && k != 11 {
            return "st"
        }
        if j == 2 && k != 12 {
            return "nd"
        }
        if j == 3 && k != 13 {
            return "rd"
        }
        return "th"
    }
} 