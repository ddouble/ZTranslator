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

    @AppStorage("ZTranslator.to-lang")
    private var toLang: String = "Japanese"

    var body: some View {
        Form {
            TextField("OpenAI API key", text: $openaiApiKey)
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
            TextField("Translate to", text: $toLang)
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
        }
            .padding(.vertical, 20)
            .padding(.horizontal, 30)
    }
}
