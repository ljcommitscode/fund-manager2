//
//  MoneyTextField.swift
//  fund-manager2
//
//  Created by Leon Cutler on 8/17/26.
//

import SwiftUI
import UIKit

struct MoneyTextField: UIViewRepresentable {

    @Binding var text: String

    let placeholder: String

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()

        textField.placeholder = placeholder
        textField.textAlignment = .right
        textField.keyboardType = .numbersAndPunctuation
        textField.delegate = context.coordinator

        return textField
    }

    func updateUIView(_ textField: UITextField, context: Context) {
        if textField.text != text {
            textField.text = text
        }
    }

    final class Coordinator: NSObject, UITextFieldDelegate {

        @Binding var text: String

        init(text: Binding<String>) {
            _text = text
        }

        func textField(
            _ textField: UITextField,
            shouldChangeCharactersIn range: NSRange,
            replacementString string: String
        ) -> Bool {

            guard let currentText = textField.text else {
                return false
            }

            guard let textRange = Range(
                range,
                in: currentText
            ) else {
                return false
            }

            let newText = currentText.replacingCharacters(
                in: textRange,
                with: string
            )

            // Allow completely empty text.
            if newText.isEmpty {
                text = ""
                return true
            }

            // Allow "-" only as the first character.
            if newText == "-" {
                text = newText
                return true
            }

            // Only one negative sign.
            if newText.filter({ $0 == "-" }).count > 1 {
                return false
            }

            // Negative sign must be first.
            if newText.contains("-") && !newText.hasPrefix("-") {
                return false
            }

            // Only one decimal point.
            if newText.filter({ $0 == "." }).count > 1 {
                return false
            }

            // Check decimal places.
            if let decimalIndex = newText.firstIndex(of: ".") {

                let decimalPart = newText[
                    newText.index(after: decimalIndex)...
                ]

                // THIS is the important restriction.
                // Reject the change entirely if there are
                // already two decimal places.
                if decimalPart.count > 2 {
                    return false
                }
            }

            // Only allow numbers, "-" and ".".
            for character in newText {
                if !character.isNumber &&
                    character != "-" &&
                    character != "." {
                    return false
                }
            }

            // Keep SwiftUI's binding synchronized.
            text = newText

            return true
        }
    }
}
