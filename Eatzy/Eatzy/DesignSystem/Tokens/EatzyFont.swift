//
//  EatzyFont.swift
//  Eatzy
//

import SwiftUI
import UIKit

enum EatzyFont {
    case display_22_sb
    case display_16_sb

    case title_18_sb
    case title_16_sb
    case title_16_m
    case title_14_sb

    case body_18_m
    case body_18_r
    case body_16_m
    case body_16_r
    case body_14_m
    case body_14_r

    case head_18_m
    case head_15_sb
    case head_15_m

    case button_18_m
    case button_16_m
    case button_14_m

    case caption_12_m
    case caption_12_r
    case caption_11_m
    case caption_10_r

    // MARK: - Font Size

    private var fontSize: CGFloat {
        switch self {
        case .display_22_sb: return 22
        case .display_16_sb: return 16
        case .title_18_sb: return 16
        case .title_16_sb, .title_16_m: return 14
        case .title_14_sb: return 12
        case .body_18_m, .body_18_r: return 16
        case .body_16_m, .body_16_r: return 14
        case .body_14_m, .body_14_r: return 12
        case .head_18_m: return 16
        case .head_15_sb, .head_15_m: return 15
        case .button_18_m: return 18
        case .button_16_m: return 16
        case .button_14_m: return 14
        case .caption_12_m, .caption_12_r: return 12
        case .caption_11_m, .caption_10_r: return 10
        }
    }

    // MARK: - Line Height

    var lineHeight: CGFloat {
        switch self {
        case .display_22_sb, .display_16_sb, .title_18_sb, .head_18_m, .button_18_m, .button_16_m:
            return 21
        case .title_16_sb, .title_16_m, .body_14_m, .body_14_r, .button_14_m:
            return 18
        case .title_14_sb:
            return 16
        case .body_18_m, .body_18_r:
            return 24
        case .body_16_m, .body_16_r:
            return 21
        case .head_15_sb, .head_15_m:
            return 19
        case .caption_12_m, .caption_12_r:
            return 17
        case .caption_11_m, .caption_10_r:
            return 14
        }
    }

    // MARK: - Letter Spacing

    var letterSpacing: CGFloat {
        switch self {
        case .display_22_sb, .display_16_sb, .title_14_sb:
            return fontSize * 0.04
        default:
            return 0
        }
    }

    // MARK: - Font Weight

    private var interFontName: String {
        switch self {
        case .display_22_sb, .display_16_sb, .title_18_sb, .title_16_sb, .title_14_sb, .head_15_sb:
            return "Inter-SemiBold"
        case .body_18_r, .body_16_r, .body_14_r, .caption_12_r, .caption_10_r:
            return "Inter-Regular"
        case .title_16_m, .body_18_m, .body_16_m, .body_14_m, .head_18_m, .head_15_m,
             .button_18_m, .button_16_m, .button_14_m, .caption_12_m, .caption_11_m:
            return "Inter-Medium"
        }
    }

    private var systemFontWeight: UIFont.Weight {
        switch self {
        case .display_22_sb, .display_16_sb, .title_18_sb, .title_16_sb, .title_14_sb, .head_15_sb:
            return .semibold
        case .body_18_r, .body_16_r, .body_14_r, .caption_12_r, .caption_10_r:
            return .regular
        default:
            return .medium
        }
    }

    func uiFont() -> UIFont {
        UIFont(name: interFontName, size: fontSize)
            ?? .systemFont(ofSize: fontSize, weight: systemFontWeight)
    }
}

// MARK: - EatzyFontModifier

private struct EatzyFontModifier: ViewModifier {
    let style: EatzyFont

    func body(content: Content) -> some View {
        let uiFont = style.uiFont()
        let lineSpacing = style.lineHeight - uiFont.lineHeight

        content
            .font(Font(uiFont))
            .kerning(style.letterSpacing)
            .lineSpacing(lineSpacing)
            .padding(.vertical, lineSpacing / 2)
    }
}

extension View {
    func applyEatzyFont(_ font: EatzyFont) -> some View {
        modifier(EatzyFontModifier(style: font))
    }
}
