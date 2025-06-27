import Foundation

@MainActor
class BillStore: ObservableObject {
    @Published var bills: [Bill] = []
    @Published var isDarkMode: Bool = false
    @Published var showCombinedSections: Bool = false
    private let saveKey = "SavedBills"
    
    init() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let savedBills = try? JSONDecoder().decode([Bill].self, from: data) {
            bills = savedBills
        }
    }
    
    func clearAllBills() {
        bills = []
        saveBills()
    }
    
    func loadStarterBills() {
        let starterBills = [
            // Early Month Bills (1-14)
            Bill(name: "Mortgage/Rent", amount: 2500.00, dueDay: 1),
            Bill(name: "HOA Fees", amount: 350.00, dueDay: 1),
            Bill(name: "Car Payment", amount: 450.00, dueDay: 5),
            Bill(name: "Car Insurance", amount: 175.00, dueDay: 5),
            Bill(name: "Home Insurance", amount: 180.00, dueDay: 8),
            Bill(name: "Internet/Cable", amount: 120.00, dueDay: 10),
            Bill(name: "Cell Phone", amount: 150.00, dueDay: 12),
            
            // Late Month Bills (15-31)
            Bill(name: "Electric Bill", amount: 200.00, dueDay: 15),
            Bill(name: "Gas Bill", amount: 85.00, dueDay: 15),
            Bill(name: "Water & Sewage", amount: 95.00, dueDay: 18),
            Bill(name: "Credit Card", amount: 500.00, dueDay: 20),
            Bill(name: "Student Loan", amount: 375.00, dueDay: 21),
            Bill(name: "Streaming Services", amount: 45.00, dueDay: 25), // Combined streaming
            Bill(name: "Gym Membership", amount: 55.00, dueDay: 28)
        ]
        
        bills = starterBills
        sortBills()
        saveBills()
    }
    
    func addBill(_ bill: Bill) {
        bills.append(bill)
        sortBills()
        saveBills()
    }
    
    func updateBill(_ updatedBill: Bill) {
        if let index = bills.firstIndex(where: { $0.id == updatedBill.id }) {
            bills[index] = updatedBill
            sortBills()
            saveBills()
        }
    }
    
    func deleteBill(_ bill: Bill) {
        bills.removeAll { $0.id == bill.id }
        saveBills()
    }
    
    func togglePaidStatus(_ bill: Bill) {
        if let index = bills.firstIndex(where: { $0.id == bill.id }) {
            bills[index].isPaid.toggle()
            saveBills()
        }
    }
    
    func markAllAsPaid() {
        for var bill in bills {
            bill.isPaid = true
            updateBill(bill)
        }
    }
    
    func markAllAsUnpaid() {
        for var bill in bills {
            bill.isPaid = false
            updateBill(bill)
        }
    }
    
    func toggleFirstHalfPaidStatus() {
        // Check if all first half bills are paid
        let allPaid = earlyMonthBills.allSatisfy { $0.isPaid }
        
        // Toggle to opposite state
        for var bill in bills where bill.dueDay <= 14 {
            bill.isPaid = !allPaid
            updateBill(bill)
        }
    }
    
    func toggleSecondHalfPaidStatus() {
        // Check if all second half bills are paid
        let allPaid = lateMonthBills.allSatisfy { $0.isPaid }
        
        // Toggle to opposite state
        for var bill in bills where bill.dueDay > 14 {
            bill.isPaid = !allPaid
            updateBill(bill)
        }
    }
    
    private func sortBills() {
        bills.sort { $0.dueDay < $1.dueDay }
    }
    
    // Early month bills (1-14)
    var earlyMonthBills: [Bill] {
        bills.filter { $0.dueDay <= 14 }.sorted { $0.dueDay < $1.dueDay }
    }
    
    // Late month bills (15-31)
    var lateMonthBills: [Bill] {
        bills.filter { $0.dueDay > 14 }.sorted { $0.dueDay < $1.dueDay }
    }
    
    // Early month totals
    var earlyMonthTotal: Double {
        earlyMonthBills.reduce(0) { $0 + $1.amount }
    }
    
    var earlyMonthPaid: Double {
        earlyMonthBills.filter { $0.isPaid }.reduce(0) { $0 + $1.amount }
    }
    
    var earlyMonthUnpaid: Double {
        earlyMonthBills.filter { !$0.isPaid }.reduce(0) { $0 + $1.amount }
    }
    
    // Late month totals
    var lateMonthTotal: Double {
        lateMonthBills.reduce(0) { $0 + $1.amount }
    }
    
    var lateMonthPaid: Double {
        lateMonthBills.filter { $0.isPaid }.reduce(0) { $0 + $1.amount }
    }
    
    var lateMonthUnpaid: Double {
        lateMonthBills.filter { !$0.isPaid }.reduce(0) { $0 + $1.amount }
    }
    
    // Grand totals
    var totalAmount: Double {
        bills.reduce(0) { $0 + $1.amount }
    }
    
    var totalPaid: Double {
        bills.filter { $0.isPaid }.reduce(0) { $0 + $1.amount }
    }
    
    var totalUnpaid: Double {
        bills.filter { !$0.isPaid }.reduce(0) { $0 + $1.amount }
    }
    
    func toggleAllPaidStatus(forBills selectedBills: [Bill]) {
        let allPaid = areAllBillsPaid(bills: selectedBills)
        for bill in selectedBills {
            if let index = bills.firstIndex(where: { $0.id == bill.id }) {
                bills[index].isPaid = !allPaid
            }
        }
        saveBills()
    }
    
    func areAllBillsPaid(bills: [Bill]) -> Bool {
        !bills.isEmpty && bills.allSatisfy { $0.isPaid }
    }
    
    private func saveBills() {
        if let encoded = try? JSONEncoder().encode(bills) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadBills() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Bill].self, from: data) {
            bills = decoded
            sortBills()
        }
    }
    
    var allBillsSorted: [Bill] {
        bills.sorted { $0.dueDay < $1.dueDay }
    }
    
    func toggleSectionDisplay() {
        showCombinedSections.toggle()
        objectWillChange.send()
    }
} 