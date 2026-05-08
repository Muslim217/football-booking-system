import SwiftUI

// MARK: - Status Badge

struct StatusBadge: View {
    let status: String

    private var label: String {
        switch status {
        case "CONFIRMED": return "Подтверждено"
        case "PENDING":   return "Ожидание"
        case "CANCELLED": return "Отменено"
        default:          return status
        }
    }

    private var color: Color {
        switch status {
        case "CONFIRMED": return .green
        case "PENDING":   return .orange
        case "CANCELLED": return .red
        default:          return .gray
        }
    }

    var body: some View {
        Text(label)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.15))
            .foregroundColor(color)
            .cornerRadius(6)
    }
}

// MARK: - Field Type Badge

struct FieldTypeBadge: View {
    let fieldType: String

    private var isIndoor: Bool { fieldType == "INDOOR" }

    var body: some View {
        Text(isIndoor ? "Крытое" : "Открытое")
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(isIndoor ? Color.blue.opacity(0.12) : Color.green.opacity(0.12))
            .foregroundColor(isIndoor ? .blue : .green)
            .cornerRadius(8)
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.title2.bold())
                .foregroundColor(color)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Error Banner

struct ErrorBanner: View {
    let message: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.red)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.red.opacity(0.08))
        .cornerRadius(10)
    }
}

// MARK: - Success Banner

struct SuccessBanner: View {
    let message: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.green)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.green.opacity(0.08))
        .cornerRadius(10)
    }
}

// MARK: - Primary Button

struct PrimaryButton: View {
    let title: String
    let isLoading: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading { ProgressView().tint(.white) }
                Text(title).fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(14)
        }
        .disabled(isLoading)
    }
}

// MARK: - Empty State

struct EmptyStateView: View {
    let icon: String
    let message: String
    var buttonTitle: String? = nil
    var buttonAction: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 52))
                .foregroundColor(.secondary.opacity(0.6))
            Text(message)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            if let title = buttonTitle, let action = buttonAction {
                Button(title, action: action)
                    .buttonStyle(.bordered)
                    .tint(.green)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Date formatting helper

extension String {
    func toDisplayDateTime() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        guard let date = f.date(from: self) else { return self }
        let out = DateFormatter()
        out.dateFormat = "dd.MM.yyyy HH:mm"
        out.locale = Locale(identifier: "ru_RU")
        return out.string(from: date)
    }

    func toShortDateTime() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        guard let date = f.date(from: self) else { return self }
        let out = DateFormatter()
        out.dateFormat = "dd.MM HH:mm"
        out.locale = Locale(identifier: "ru_RU")
        return out.string(from: date)
    }
}
