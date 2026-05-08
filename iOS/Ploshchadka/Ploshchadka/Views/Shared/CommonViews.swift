import SwiftUI

// MARK: - Design Tokens

extension Color {
    static let fbBg          = Color(hex: "F6F7F2")
    static let fbSurface     = Color(hex: "FFFFFF")
    static let fbSurfaceAlt  = Color(hex: "EEF4EC")
    static let fbBorder      = Color(hex: "D7DED2")
    static let fbText        = Color(hex: "172117")
    static let fbTextMuted   = Color(hex: "667263")
    static let fbTextFaint   = Color(hex: "9CA89A")
    static let fbPrimary     = Color(hex: "1B6B2E")
    static let fbPrimarySoft = Color(hex: "E3F3E5")
    static let fbPrimaryDeep = Color(hex: "0E3F1B")
    static let fbAccent      = Color(hex: "F6B73C")
    static let fbAccentSoft  = Color(hex: "FCEBC1")
    static let fbDanger      = Color(hex: "B83A3A")
    static let fbDangerSoft  = Color(hex: "F7E1E1")
    static let fbWarning     = Color(hex: "B66A1D")
    static let fbWarningSoft = Color(hex: "FAEAD3")
    static let fbInfo        = Color(hex: "256C8A")
    static let fbInfoSoft    = Color(hex: "DDEDF4")

    init(hex: String) {
        let h = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: h).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >>  8) & 0xFF) / 255
        let b = Double( int        & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Pitch Illustration

struct FieldPitchView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "2d7a3f"), Color(hex: "1B6B2E"), Color(hex: "145322")],
                startPoint: .top, endPoint: .bottom
            )
            GeometryReader { geo in
                ZStack {
                    // field border
                    Rectangle()
                        .strokeBorder(Color.white.opacity(0.35), lineWidth: 2)
                        .padding(12)
                    // center line
                    Rectangle()
                        .fill(Color.white.opacity(0.22))
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                        .padding(.vertical, 12)
                    // center circle
                    Circle()
                        .strokeBorder(Color.white.opacity(0.35), lineWidth: 2)
                        .frame(width: 52, height: 52)
                    // penalty areas
                    Rectangle()
                        .strokeBorder(Color.white.opacity(0.25), lineWidth: 1.5)
                        .frame(width: geo.size.width * 0.28, height: geo.size.height * 0.52)
                        .position(x: geo.size.width * 0.14, y: geo.size.height / 2)
                    Rectangle()
                        .strokeBorder(Color.white.opacity(0.25), lineWidth: 1.5)
                        .frame(width: geo.size.width * 0.28, height: geo.size.height * 0.52)
                        .position(x: geo.size.width * 0.86, y: geo.size.height / 2)
                }
            }
        }
        .frame(height: 140)
        .clipped()
    }
}

// MARK: - Brand Mark

struct BrandMark: View {
    var size: CGFloat = 40
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.3)
                .fill(Color.fbPrimary)
                .frame(width: size, height: size)
            Text("⚽").font(.system(size: size * 0.5))
        }
    }
}

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
        case "CONFIRMED": return .fbPrimary
        case "PENDING":   return .fbWarning
        case "CANCELLED": return .fbDanger
        default:          return .fbTextMuted
        }
    }

    private var bg: Color {
        switch status {
        case "CONFIRMED": return .fbPrimarySoft
        case "PENDING":   return .fbWarningSoft
        case "CANCELLED": return .fbDangerSoft
        default:          return .fbSurfaceAlt
        }
    }

    var body: some View {
        HStack(spacing: 5) {
            Circle().fill(color).frame(width: 6, height: 6)
            Text(label).font(.system(size: 12, weight: .semibold))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(bg)
        .foregroundColor(color)
        .clipShape(Capsule())
    }
}

// MARK: - Field Type Badge

struct FieldTypeBadge: View {
    let fieldType: String

    private var label: String {
        switch fieldType.uppercased() {
        case "FOOTBALL":   return "Футбол"
        case "BASKETBALL": return "Баскетбол"
        case "VOLLEYBALL": return "Волейбол"
        case "TENNIS":     return "Теннис"
        case "PADEL":      return "Падел"
        case "HOCKEY":     return "Хоккей"
        case "INDOOR":     return "Крытое"
        case "OUTDOOR":    return "Открытое"
        default:           return fieldType
        }
    }

    var body: some View {
        HStack(spacing: 5) {
            Circle().fill(Color.fbPrimary).frame(width: 6, height: 6)
            Text(label).font(.system(size: 12, weight: .semibold))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(Color.fbPrimarySoft)
        .foregroundColor(Color.fbPrimary)
        .clipShape(Capsule())
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .monospaced))
                .foregroundColor(color == .primary ? Color.fbText : color)
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(.fbTextMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 22)
        .padding(.vertical, 20)
        .background(Color.fbSurface)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Color.fbBorder, lineWidth: 1)
        )
        .cornerRadius(14)
        .shadow(color: Color(hex: "172117").opacity(0.06), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Error Banner

struct ErrorBanner: View {
    let message: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.fbDanger)
                .font(.system(size: 14))
            Text(message)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.fbDanger)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.fbDangerSoft)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(Color.fbDanger.opacity(0.25), lineWidth: 1)
        )
        .cornerRadius(10)
    }
}

// MARK: - Success Banner

struct SuccessBanner: View {
    let message: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.fbPrimary)
                .font(.system(size: 14))
            Text(message)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.fbPrimary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.fbPrimarySoft)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(Color.fbPrimary.opacity(0.25), lineWidth: 1)
        )
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
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView().tint(.white).scaleEffect(0.85)
                }
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color.fbPrimary)
            .foregroundColor(.white)
            .cornerRadius(10)
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
                .font(.system(size: 48))
                .foregroundColor(.fbTextFaint)
            Text(message)
                .font(.system(size: 15))
                .foregroundColor(.fbTextMuted)
                .multilineTextAlignment(.center)
            if let title = buttonTitle, let action = buttonAction {
                Button(title, action: action)
                    .font(.system(size: 14, weight: .semibold))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.fbPrimary)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Pitch Strip (bottom accent)

struct PitchStrip: View {
    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                Color.fbPrimary.frame(width: geo.size.width * 0.6)
                Color.fbAccent
            }
        }
        .frame(height: 4)
    }
}

// MARK: - Date formatting

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
