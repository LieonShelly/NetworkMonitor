//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import SwiftUI

public struct NetworkMonitorPanelView: View {
    @State private var store = NetworkMonitorStore.shared
    @State private var selectedEntryId: UUID?

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            headerView

            Divider()

            if store.entries.isEmpty {
                emptyStateView
            } else {
                requestListView
            }
        }
        .background(Color(.systemBackground))
    }

    private var headerView: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "network")
                    .foregroundStyle(Color.accentColor)
                Text("Network Monitor")
                    .font(.headline)
                    .foregroundStyle(.primary)
            }

            Spacer()

            Button(action: { store.clear() }) {
                Image(systemName: "trash")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(store.entries.isEmpty ? .gray : .red)
            }
            .disabled(store.entries.isEmpty)

            Button(action: { store.isExpanded = false }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemBackground))
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "network.slash")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("No requests captured")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("Start making API requests to see them here")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private var requestListView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(store.entries) { entry in
                    VStack(spacing: 0) {
                        RequestRowView(entry: entry, isSelected: selectedEntryId == entry.id)
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    if selectedEntryId == entry.id {
                                        selectedEntryId = nil
                                    } else {
                                        selectedEntryId = entry.id
                                    }
                                }
                            }

                        if selectedEntryId == entry.id {
                            RequestDetailView(entry: entry)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                }
            }
        }
    }
}
