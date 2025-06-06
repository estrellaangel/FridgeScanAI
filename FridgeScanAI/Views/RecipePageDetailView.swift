//
//  RecipePageDetailView.swift
//  FridgeScanAI
//
//  Created by Estrella Angel on 4/25/25.
//

import SwiftUI

struct RecipePageDetailView: View {
    let recipe: Recipe

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            
            // IMAGE
            recipe.imageView
                .frame(width: 100, height: 100) // fixed size ✅
                .clipped()
                .cornerRadius(12)
            

            // TEXT
            VStack(alignment: .leading, spacing: 8) {
                Text(recipe.title)
                    .font(.headline)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Text(cleanSummaryHTML(recipe.summary ?? "No summary available."))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }

        }
        .padding(.vertical, 8) // add space between rows
    }
    
    func cleanSummaryHTML(_ html: String) -> String {
        // Remove <b>, </b>, <i>, </i>
        var cleaned = html
            .replacingOccurrences(of: "<b>", with: "")
            .replacingOccurrences(of: "</b>", with: "")
            .replacingOccurrences(of: "<i>", with: "")
            .replacingOccurrences(of: "</i>", with: "")
            .replacingOccurrences(of: "</a>", with: "")
        
        cleaned = cleaned.replacingOccurrences(of: "<a[^>].*?>", with: "", options: .regularExpression)

        return cleaned
    }
}
//
//#Preview {
//    RecipePageDetailView()
//}
