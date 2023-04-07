//
// SettingsView.swift
//
// Created by Alan on 7/4/23.
//

import SwiftUI
import Cocoa

struct ZTranslatorSettings: View {
    @AppStorage("ZTranslator.openai-api-key")
    private var openaiApiKey: String = "YOUR-OPENAI-API-KEY"

    var body: some View {
        Form {
            TextField("Enter your openai API key", text: $openaiApiKey)
                .padding()
        }
    }
}