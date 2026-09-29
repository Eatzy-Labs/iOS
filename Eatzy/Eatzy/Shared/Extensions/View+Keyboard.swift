//
//  View+Keyboard.swift
//  Eatzy
//

import SwiftUI
import UIKit

extension View {
    func hideKeyboardOnBackgroundTap() -> some View {
        background(KeyboardDismissGestureView())
    }

    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}

private struct KeyboardDismissGestureView: UIViewRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.isUserInteractionEnabled = false
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            guard let window = uiView.window else { return }
            context.coordinator.installIfNeeded(on: window)
        }
    }

    static func dismantleUIView(_ uiView: UIView, coordinator: Coordinator) {
        coordinator.uninstall()
    }

    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        private weak var installedWindow: UIWindow?
        private lazy var tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(didTapOutsideInput)
        )

        override init() {
            super.init()
            tapGesture.cancelsTouchesInView = false
            tapGesture.delegate = self
        }

        func installIfNeeded(on window: UIWindow) {
            guard installedWindow !== window else { return }
            uninstall()
            installedWindow = window
            window.addGestureRecognizer(tapGesture)
        }

        func uninstall() {
            installedWindow?.removeGestureRecognizer(tapGesture)
            installedWindow = nil
        }

        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldReceive touch: UITouch
        ) -> Bool {
            var touchedView = touch.view

            while let view = touchedView {
                if view is UITextField || view is UITextView {
                    return false
                }
                touchedView = view.superview
            }
            return true
        }

        @objc private func didTapOutsideInput() {
            installedWindow?.endEditing(true)
        }
    }
}
