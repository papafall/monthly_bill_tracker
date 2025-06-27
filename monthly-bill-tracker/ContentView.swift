//
//  ContentView.swift
//  monthly-bill-tracker
//
//  Created by Papa Fall on 6/26/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var billStore = BillStore()
    @Environment(\.colorScheme) var colorScheme
    @State private var showingClearConfirmation = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                    if billStore.bills.isEmpty {
                        Section {
                            ContentUnavailableView(
                                "No Bills",
                                systemImage: "doc.text",
                                description: Text("Tap the + button to add your first bill")
                            )
                        }
                    } else {
                        // Monthly Overview Section
                        Section {
                            monthlyOverview
                                .padding(.horizontal)
                                .padding(.top, 2)
                        } header: {
                            monthlyHeader
                                .background(Color(UIColor.systemBackground))
                        }
                        
                        if billStore.showCombinedSections {
                            // Combined Bills Section
                            Section {
                                ForEach(billStore.allBillsSorted) { bill in
                                    BillRowView(
                                        bill: bill,
                                        onToggle: { billStore.togglePaidStatus(bill) },
                                        billStore: billStore
                                    )
                                }
                            } header: {
                                allBillsHeader
                                    .background(Color(UIColor.systemBackground))
                            }
                        } else {
                            // Early Month Section
                            if !billStore.earlyMonthBills.isEmpty {
                                Section {
                                    ForEach(billStore.earlyMonthBills) { bill in
                                        BillRowView(
                                            bill: bill,
                                            onToggle: { billStore.togglePaidStatus(bill) },
                                            billStore: billStore
                                        )
                                    }
                                    
                                    // Add spacing after early month section
                                    Color.clear.frame(height: 24)
                                } header: {
                                    earlyMonthHeader
                                        .background(Color(UIColor.systemBackground))
                                }
                            }
                            
                            // Late Month Section
                            if !billStore.lateMonthBills.isEmpty {
                                Section {
                                    ForEach(billStore.lateMonthBills) { bill in
                                        BillRowView(
                                            bill: bill,
                                            onToggle: { billStore.togglePaidStatus(bill) },
                                            billStore: billStore
                                        )
                                    }
                                } header: {
                                    lateMonthHeader
                                        .background(Color(UIColor.systemBackground))
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Monthly Bills")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        billStore.isDarkMode.toggle()
                    } label: {
                        Image(systemName: billStore.isDarkMode ? "moon.fill" : "sun.max.fill")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AddBillView(billStore: billStore)) {
                        Image(systemName: "plus")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button {
                            billStore.toggleSectionDisplay()
                        } label: {
                            Label(
                                billStore.showCombinedSections ? "Split into Sections" : "Combine Sections",
                                systemImage: billStore.showCombinedSections ? "rectangle.split.2x1" : "rectangle"
                            )
                        }
                        .help(billStore.showCombinedSections 
                            ? "Split bills into Early Month (1st-14th) and Late Month (15th-31st) sections"
                            : "Show all bills in a single section sorted by due date")
                        
                        Divider()
                        
                        Button(role: .destructive) {
                            showingClearConfirmation = true
                        } label: {
                            Label("Clear All Bills", systemImage: "trash")
                        }
                        
                        Button {
                            billStore.loadStarterBills()
                        } label: {
                            Label("Load Sample Bills", systemImage: "doc.fill.badge.plus")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .alert("Clear All Bills?", isPresented: $showingClearConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Clear All", role: .destructive) {
                    billStore.clearAllBills()
                }
            } message: {
                Text("This will permanently delete all your bills. This action cannot be undone.")
            }
        }
        .preferredColorScheme(billStore.isDarkMode ? .dark : .light)
    }
    
    private var monthlyHeader: some View {
        VStack(spacing: 4) {
            HStack {
                Text("Monthly Overview")
                    .font(.title3)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 4)
        }
    }
    
    private var monthlyOverview: some View {
        VStack(spacing: 4) {
            HStack {
                Text("Total Bills")
                    .font(.subheadline)
                Spacer()
                Text(formattedAmount(billStore.totalAmount))
                    .font(.subheadline)
            }
            
            HStack {
                Text("Paid")
                    .font(.caption)
                    .foregroundColor(.green)
                Spacer()
                Text(formattedAmount(billStore.totalPaid))
                    .font(.caption)
                    .foregroundColor(.green)
            }
            
            HStack {
                Text("Unpaid")
                    .font(.caption)
                    .foregroundColor(.red)
                Spacer()
                Text(formattedAmount(billStore.totalUnpaid))
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
        .padding(.horizontal)
    }
    
    private var allBillsHeader: some View {
        VStack(spacing: 4) {
            HStack {
                Button {
                    billStore.toggleAllPaidStatus(forBills: billStore.bills)
                } label: {
                    Image(systemName: billStore.areAllBillsPaid(bills: billStore.bills) ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(billStore.areAllBillsPaid(bills: billStore.bills) ? .green : .gray)
                        .font(.system(size: 22))
                }
                .frame(width: 32)
                
                HStack(spacing: 8) {
                    Text("All Bills")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text("(By Due Date)")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // All Bills Summary
            HStack(spacing: 12) {
                Text(formattedAmount(billStore.totalAmount))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .padding(.leading, 32)
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(.green)
                        .frame(width: 8, height: 8)
                    Text(formattedAmount(billStore.totalPaid))
                        .font(.footnote)
                        .foregroundColor(.green)
                }
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(.red)
                        .frame(width: 8, height: 8)
                    Text(formattedAmount(billStore.totalUnpaid))
                        .font(.footnote)
                        .foregroundColor(.red)
                }
                
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(UIColor.systemBackground))
        .overlay(
            Rectangle()
                .fill(Color.blue.opacity(0.1))
                .allowsHitTesting(false)
        )
    }
    
    private var earlyMonthHeader: some View {
        VStack(spacing: 4) {
            HStack {
                Button {
                    billStore.toggleAllPaidStatus(forBills: billStore.earlyMonthBills)
                } label: {
                    Image(systemName: billStore.areAllBillsPaid(bills: billStore.earlyMonthBills) ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(billStore.areAllBillsPaid(bills: billStore.earlyMonthBills) ? .green : .gray)
                        .font(.system(size: 22))
                }
                .frame(width: 32)
                
                HStack(spacing: 8) {
                    Text("Early Month")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text("(1st-14th)")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // Early Month Summary
            HStack(spacing: 12) {
                Text(formattedAmount(billStore.earlyMonthTotal))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .padding(.leading, 32)
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(.green)
                        .frame(width: 8, height: 8)
                    Text(formattedAmount(billStore.earlyMonthPaid))
                        .font(.footnote)
                        .foregroundColor(.green)
                }
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(.red)
                        .frame(width: 8, height: 8)
                    Text(formattedAmount(billStore.earlyMonthUnpaid))
                        .font(.footnote)
                        .foregroundColor(.red)
                }
                
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(UIColor.systemBackground))
        .overlay(
            Rectangle()
                .fill(Color.orange.opacity(0.1))
                .allowsHitTesting(false)
        )
    }
    
    private var lateMonthHeader: some View {
        VStack(spacing: 4) {
            HStack {
                Button {
                    billStore.toggleAllPaidStatus(forBills: billStore.lateMonthBills)
                } label: {
                    Image(systemName: billStore.areAllBillsPaid(bills: billStore.lateMonthBills) ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(billStore.areAllBillsPaid(bills: billStore.lateMonthBills) ? .green : .gray)
                        .font(.system(size: 22))
                }
                .frame(width: 32)
                
                HStack(spacing: 8) {
                    Text("Late Month")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text("(15th-31st)")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // Late Month Summary
            HStack(spacing: 12) {
                Text(formattedAmount(billStore.lateMonthTotal))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .padding(.leading, 32)
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(.green)
                        .frame(width: 8, height: 8)
                    Text(formattedAmount(billStore.lateMonthPaid))
                        .font(.footnote)
                        .foregroundColor(.green)
                }
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(.red)
                        .frame(width: 8, height: 8)
                    Text(formattedAmount(billStore.lateMonthUnpaid))
                        .font(.footnote)
                        .foregroundColor(.red)
                }
                
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(UIColor.systemBackground))
        .overlay(
            Rectangle()
                .fill(Color.indigo.opacity(0.1))
                .allowsHitTesting(false)
        )
    }
    
    private func formattedAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
}

#Preview {
    ContentView()
}
