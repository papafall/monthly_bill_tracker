//
//  ContentView.swift
//  monthly-bill-tracker
//
//  Created by Papa Fall on 6/26/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var billStore = BillStore()
    @State private var showingAddBill = false
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    private var currencyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter
    }
    
    private func formattedAmount(_ amount: Double) -> String {
        currencyFormatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
    
    private var monthlyOverview: some View {
        VStack(spacing: 4) {
            HStack {
                Text("Unpaid: \(formattedAmount(billStore.totalUnpaidAmount))")
                    .foregroundColor(.red)
                Spacer()
                Text("Paid: \(formattedAmount(billStore.totalPaidAmountThisMonth))")
                    .foregroundColor(.green)
            }
            .font(.subheadline)
        }
        .padding(.vertical, 2)
    }
    
    private var billSummaryRow: some View {
        Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 4) {
            GridRow {
                Text("1st-14th:")
                    .gridColumnAlignment(.trailing)
                Text(formattedAmount(billStore.earlyMonthTotalUnpaid))
                    .foregroundColor(.red)
                Text("Paid:")
                    .gridColumnAlignment(.trailing)
                Text(formattedAmount(billStore.earlyMonthTotalPaid))
                    .foregroundColor(.green)
            }
            
            GridRow {
                Text("15th-31st:")
                    .gridColumnAlignment(.trailing)
                Text(formattedAmount(billStore.lateMonthTotalUnpaid))
                    .foregroundColor(.red)
                Text("Paid:")
                    .gridColumnAlignment(.trailing)
                Text(formattedAmount(billStore.lateMonthTotalPaid))
                    .foregroundColor(.green)
            }
        }
        .font(.caption)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(pinnedViews: [.sectionHeaders]) {
                    if !billStore.bills.isEmpty {
                        Section {
                            monthlyOverview
                                .padding(.horizontal)
                                .padding(.top, 2)
                        } header: {
                            HStack {
                                Text("Monthly Overview")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color(UIColor.systemBackground))
                        }
                        
                        Section {
                            LazyVStack(spacing: 0) {
                                ForEach(billStore.bills) { bill in
                                    BillRowView(
                                        bill: bill,
                                        onToggle: { billStore.togglePaidStatus(bill) },
                                        billStore: billStore
                                    )
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            billStore.deleteBill(bill)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                        } header: {
                            VStack(spacing: 4) {
                                HStack {
                                    Text("Bills by Due Date")
                                        .font(.headline)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Menu {
                                        Button(action: { billStore.markAllAsPaid() }) {
                                            Label("Mark All as Paid", systemImage: "checkmark.circle.fill")
                                        }
                                        Button(action: { billStore.markAllAsUnpaid() }) {
                                            Label("Mark All as Unpaid", systemImage: "circle")
                                        }
                                    } label: {
                                        Image(systemName: "ellipsis.circle")
                                            .font(.headline)
                                    }
                                }
                                
                                billSummaryRow
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(UIColor.systemBackground))
                        }
                    }
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Monthly Bills")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddBill = true
                    } label: {
                        Label("Add Bill", systemImage: "plus")
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        isDarkMode.toggle()
                    } label: {
                        Label(
                            isDarkMode ? "Switch to Light Mode" : "Switch to Dark Mode",
                            systemImage: isDarkMode ? "sun.max.fill" : "moon.fill"
                        )
                    }
                }
            }
            .sheet(isPresented: $showingAddBill) {
                AddBillView(billStore: billStore)
            }
            .overlay {
                if billStore.bills.isEmpty {
                    ContentUnavailableView(
                        "No Bills",
                        systemImage: "doc.text",
                        description: Text("Tap the + button to add your first bill")
                    )
                }
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

#Preview {
    ContentView()
}
