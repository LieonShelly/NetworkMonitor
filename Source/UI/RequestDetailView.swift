//
//  Created by lieon on 2026/05/17.
//  This code is protected by intellectual property rights.
//

import SwiftUI

public struct RequestDetailView: View {
    let entry: NetworkMonitorEntry

    @State private var requestExpanded = true
    @State private var responseExpanded = true
    @State private var requestHeadersExpanded = false
    @State private var responseHeadersExpanded = false
    @State private var showingShareSheet = false

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            detailHeader
            requestSection
            Divider().padding(.horizontal, 16)
            responseSection
        }
        .padding(.vertical, 8)
        .background(Color(.secondarySystemBackground))
        .sheet(isPresented: $showingShareSheet) {
            ShareTextSheet(text: entry.formattedExportText)
        }
    }

    private var detailHeader: some View {
        HStack {
            Button(action: { showingShareSheet = true }) {
                HStack(spacing: 4) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 12, weight: .medium))
                    Text("Export")
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundStyle(Color.accentColor)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.accentColor.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }

    private var requestSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: { withAnimation { requestExpanded.toggle() } }) {
                HStack {
                    Image(systemName: "arrow.up.circle.fill")
                        .foregroundStyle(.blue)
                    Text("Request")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Spacer()
                    Image(systemName: requestExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }
            .buttonStyle(.plain)

            if requestExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    if !entry.requestHeaders.isEmpty {
                        expandableHeaders(
                            title: "Headers",
                            count: entry.requestHeaders.count,
                            isExpanded: $requestHeadersExpanded,
                            headers: entry.requestHeaders
                        )
                    }

                    if let body = entry.prettyPrintedRequestBody {
                        bodySection(title: "Body", content: body)
                    } else if let bodyString = entry.requestBodyString, !bodyString.isEmpty {
                        bodySection(title: "Body", content: bodyString)
                    }
                }
                .padding(.bottom, 12)
            }
        }
    }

    private var responseSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: { withAnimation { responseExpanded.toggle() } }) {
                HStack {
                    Image(systemName: "arrow.down.circle.fill")
                        .foregroundStyle(.green)
                    Text("Response")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Spacer()
                    Image(systemName: responseExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }
            .buttonStyle(.plain)

            if responseExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    statusSection

                    if let headers = entry.responseHeaders, !headers.isEmpty {
                        expandableHeaders(
                            title: "Headers",
                            count: headers.count,
                            isExpanded: $responseHeadersExpanded,
                            headers: headers
                        )
                    }

                    if let body = entry.prettyPrintedResponseBody {
                        bodySection(title: "Body", content: body)
                    } else if let bodyString = entry.responseBodyString, !bodyString.isEmpty {
                        bodySection(title: "Body", content: bodyString)
                    }
                }
                .padding(.bottom, 12)
            }
        }
    }

    private var statusSection: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Status")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack(spacing: 6) {
                    Text("\(entry.statusCode ?? 0)")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundStyle(statusColor)
                    Text(statusText)
                        .font(.caption)
                        .foregroundStyle(statusColor)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("Duration")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(entry.formattedDuration)
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundStyle(.primary)
            }
        }
        .padding(.horizontal, 16)
    }

    private func expandableHeaders(
        title: String,
        count: Int,
        isExpanded: Binding<Bool>,
        headers: [String: String]
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Button(action: { withAnimation { isExpanded.wrappedValue.toggle() } }) {
                HStack {
                    Text("\(title) (\(count))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Image(systemName: isExpanded.wrappedValue ? "chevron.up" : "chevron.down")
                        .font(.system(size: 8))
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)

            if isExpanded.wrappedValue {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(headers.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(key)
                                .font(.system(size: 11, weight: .medium, design: .monospaced))
                                .foregroundStyle(.primary)
                            Text(value)
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundStyle(.secondary)
                                .lineLimit(3)
                        }
                    }
                }
                .padding(10)
                .background(Color(.tertiarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
        .padding(.horizontal, 16)
    }

    private func bodySection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 16)

            ScrollView([.horizontal, .vertical], showsIndicators: true) {
                Text(content)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(.primary)
                    .textSelection(.enabled)
            }
            .frame(maxHeight: 200)
            .padding(10)
            .background(Color(.tertiarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .padding(.horizontal, 16)
        }
    }

    private var statusColor: Color {
        guard let code = entry.statusCode else { return .secondary }
        switch code {
        case 200..<300:
            return .green
        case 300..<400:
            return .orange
        case 400..<500:
            return .red
        case 500..<600:
            return .red
        default:
            return .secondary
        }
    }

    private var statusText: String {
        guard let code = entry.statusCode else { return "" }
        switch code {
        case 200:
            return "OK"
        case 201:
            return "Created"
        case 204:
            return "No Content"
        case 301:
            return "Moved Permanently"
        case 302:
            return "Found"
        case 304:
            return "Not Modified"
        case 400:
            return "Bad Request"
        case 401:
            return "Unauthorized"
        case 403:
            return "Forbidden"
        case 404:
            return "Not Found"
        case 422:
            return "Unprocessable Entity"
        case 429:
            return "Too Many Requests"
        case 500:
            return "Internal Server Error"
        case 502:
            return "Bad Gateway"
        case 503:
            return "Service Unavailable"
        default:
            return ""
        }
    }
}
