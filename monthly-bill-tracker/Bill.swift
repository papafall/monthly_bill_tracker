import Foundation

struct Bill: Identifiable, Codable {
    var id = UUID()
    var name: String
    var amount: Double
    var dueDay: Int // Day of the month (1-31)
    private var paidMonths: Set<String> = [] // Format: "YYYY-MM"
    
    init(name: String, amount: Double, dueDay: Int) {
        self.name = name
        self.amount = amount
        self.dueDay = dueDay
    }
    
    // Computed property to get the next due date based on the due day
    var nextDueDate: Date {
        let calendar = Calendar.current
        let today = Date()
        let currentDay = calendar.component(.day, from: today)
        let currentMonth = calendar.component(.month, from: today)
        let currentYear = calendar.component(.year, from: today)
        
        // If the due day hasn't passed this month, use current month
        // Otherwise, use next month
        let targetMonth = currentDay > dueDay ? currentMonth + 1 : currentMonth
        let targetYear = targetMonth > 12 ? currentYear + 1 : currentYear
        let normalizedMonth = targetMonth > 12 ? 1 : targetMonth
        
        // Create date components for the target date
        var components = DateComponents()
        components.year = targetYear
        components.month = normalizedMonth
        components.day = dueDay
        
        // Return the calculated date or today if something goes wrong
        return calendar.date(from: components) ?? today
    }
    
    var isPaid: Bool {
        get {
            let key = monthYearKey(from: Date())
            return paidMonths.contains(key)
        }
        set {
            let key = monthYearKey(from: Date())
            if newValue {
                paidMonths.insert(key)
            } else {
                paidMonths.remove(key)
            }
        }
    }
    
    private func monthYearKey(from date: Date) -> String {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        return String(format: "%04d-%02d", year, month)
    }
    
    static var sampleBill: Bill {
        Bill(name: "Electricity", amount: 150.00, dueDay: 15)
    }
} 