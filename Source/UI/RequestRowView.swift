//
//  RequestRowView.swift
//  Common
//
//  Created by LittleThings AI on 2026/05/17.
//

import SwiftUI

public struct RequestRowView: View {
    let entry: NetworkMonitorEntry
    let isSelected: Bool

    @State private var showingCopiedToast = false

    public var body: some View {
        ZStack {
            contentView

            if showingCopiedToast {
                VStack {
                    Spacer()
                    copiedToast
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(isSelected ? Color.accentColor.opacity(0.08) : Color.clear)
        .contentShape(Rectangle())
        .onLongPressGesture(minimumDuration: 0.5) {
            copyToClipboard()
        }
    }

    private var contentView: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                methodBadge

                Text(pathComponent)
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .truncationMode(.middle)

                Spacer()

                statusView
            }

            Text(entry.url.absoluteString)
                .font(.system(size: 10, design: .monospaced))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.head)

            Text("Long press to copy")
                .font(.system(size: 9))
                .foregroundStyle(.tertiary)
                .padding(.top, 2)
        }
    }

    private var copiedToast: some View {
        HStack(spacing: 6) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 14))
                .foregroundStyle(.green)
            Text("Copied to clipboard")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        .padding(.bottom, 60)
    }

    private func copyToClipboard() {
        UIPasteboard.general.string = entry.formattedCopyText

        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            showingCopiedToast = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeOut(duration: 0.2)) {
                showingCopiedToast = false
            }
        }
    }

    private var pathComponent: String {
        var path = entry.url.path
        if path.isEmpty {
            path = "/"
        }
        if let query = entry.url.query, !query.isEmpty {
            path += "?\(query)"
            if path.count > 50 {
                path = String(path.prefix(47)) + "..."
            }
        }
        return path
    }

    private var methodBadge: some View {
        Text(entry.method)
            .font(.system(size: 10, weight: .bold, design: .monospaced))
            .foregroundStyle(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(methodColor)
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }

    private var methodColor: Color {
        switch entry.method {
        case "GET":
            return .green
        case "POST":
            return .blue
        case "PUT":
            return .orange
        case "PATCH":
            return .purple
        case "DELETE":
            return .red
        default:
            return .gray
        }
    }

    @ViewBuilder
    private var statusView: some View {
        switch entry.state {
        case .loading:
            ProgressView()
                .scaleEffect(0.7)

        case .success:
            HStack(spacing: 4) {
                Text("\(entry.statusCode ?? 0)")
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.green)

                Text("•")
                    .foregroundStyle(.secondary)

                Text(entry.formattedDuration)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(.secondary)
            }

        case .failed:
            HStack(spacing: 4) {
                Text(entry.statusCode != nil ? "\(entry.statusCode!)" : "ERR")
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.red)

                Text("•")
                    .foregroundStyle(.secondary)

                Text(entry.formattedDuration)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
        }
    }
}
