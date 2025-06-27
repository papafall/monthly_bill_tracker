import SwiftUI

struct EditBillView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var billStore: BillStore
    let bill: Bill
    
    @State private var billName = ""
    @State private var amount = ""
    @State private var dueDay: Int
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingDeleteConfirmation = false
    
    init(billStore: BillStore, bill: Bill) {
        self.billStore = billStore
        self.bill = bill
        _billName = State(initialValue: bill.name)
        _amount = State(initialValue: String(format: "%.2f", bill.amount))
        _dueDay = State(initialValue: bill.dueDay)
    }
    
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
                
                Section {
                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete Bill")
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationTitle("Edit Bill")
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
            .alert("Delete Bill", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    billStore.deleteBill(bill)
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to delete this bill? This action cannot be undone.")
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
        
        var updatedBill = bill
        updatedBill.name = billName
        updatedBill.amount = amountDouble
        updatedBill.dueDay = dueDay
        
        billStore.updateBill(updatedBill)
        dismiss()
    }
} 