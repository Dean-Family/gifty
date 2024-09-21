//
//  StatusSelectionModal.swift
//  Gifty
//
//  Created by Gavin Dean on 8/30/24.
//

import SwiftUI

struct StatusSelectionModal: View {
    @Binding var selectedStatus: String
    @Binding var isPresented: Bool
    
    let statuses: [String]

    var body: some View {
        NavigationView {
            List {
                ForEach(statuses, id: \.self) { status in
                    Button(action: {
                        selectedStatus = status
                        isPresented = false
                    }) {
                        HStack {
                            Text(status)
                            Spacer()
                            if selectedStatus == status {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("Select Status", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
}
