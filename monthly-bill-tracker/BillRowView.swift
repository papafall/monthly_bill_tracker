import SwiftUI

struct BillRowView: View {
    let bill: Bill
    let onToggle: () -> Void
    @ObservedObject var billStore: BillStore
    @State private var showingEditSheet = false
    
    private var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: bill.amount)) ?? "$\(bill.amount)"
    }
    
    private var formattedDueDay: String {
        "Due on the \(bill.dueDay)\(bill.dueDay.ordinalSuffix)"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                // Bill Information
                VStack(alignment: .leading, spacing: 6) {
                    Text(bill.name)
                        .font(.headline)
                    Text(formattedAmount)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(formattedDueDay)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Action Buttons
                HStack(spacing: 20) {
                    // Edit Button
                    Button {
                        showingEditSheet = true
                    } label: {
                        Image(systemName: "pencil.circle.fill")
                            .foregroundStyle(.blue)
                            .font(.title2)
                    }
                    .buttonStyle(.plain)
                    
                    // Paid/Unpaid Toggle
                    Button {
                        onToggle()
                    } label: {
                        Image(systemName: bill.isPaid ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(bill.isPaid ? .green : .gray)
                            .font(.title2)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
        .sheet(isPresented: $showingEditSheet) {
            EditBillView(billStore: billStore, bill: bill)
        }
    }
} 