import SwiftUI

struct BillRowView: View {
    let bill: Bill
    let onToggle: () -> Void
    let billStore: BillStore
    @State private var showingEditSheet = false
    
    private func formattedAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
    
    private var isEarlyMonth: Bool {
        bill.dueDay <= 14
    }
    
    private var themeColor: Color {
        isEarlyMonth ? .orange : .indigo
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                // Left side: Toggle button
                Button {
                    onToggle()
                } label: {
                    Image(systemName: bill.isPaid ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(bill.isPaid ? .green : .gray)
                        .font(.system(size: 22))
                }
                .frame(width: 32)
                
                // Middle: Bill info
                VStack(alignment: .leading, spacing: 4) {
                    Text(bill.name)
                        .font(.body)
                        .fontWeight(.medium)
                    HStack {
                        Text("Due: \(bill.dueDay.ordinalString)")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        Text("•")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(formattedAmount(bill.amount))
                            .font(.footnote)
                            .foregroundColor(bill.isPaid ? .green : .secondary)
                    }
                }
                
                Spacer()
                
                // Right side: Edit button
                Button {
                    showingEditSheet = true
                } label: {
                    Image(systemName: "pencil.circle.fill")
                        .foregroundColor(themeColor)
                        .font(.system(size: 22))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color(UIColor.secondarySystemBackground))
        .overlay(
            Rectangle()
                .fill(themeColor.opacity(0.1))
                .allowsHitTesting(false)
        )
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, y: 1)
        .padding(.horizontal)
        .padding(.vertical, 4)
        .sheet(isPresented: $showingEditSheet) {
            EditBillView(billStore: billStore, bill: bill)
        }
        .contextMenu {
            Button {
                showingEditSheet = true
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            
            Button(role: .destructive) {
                billStore.deleteBill(bill)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

extension Int {
    var ordinalString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
} 