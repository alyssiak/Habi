//
//  QuoteService.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 18.06.2026.
//

import Foundation

struct Quote: Decodable {
    let text: String
    let author: String
    
    //mapping
    enum CodingKeys: String, CodingKey {
        case text = "quote"
        case author
    }
}


protocol QuoteServiceProtocol {
    // async потому что мы знаем что метод может зависнуть , поэтому делаем ассинхронным = ответ придется ждать
    // throws - потому что он может и вовсе не прийти или ошибка произойти, поэтому далее будем писать do catch
    func fetchQuote() async throws -> Quote
}

final class QuoteService: QuoteServiceProtocol {
    func fetchQuote() async throws -> Quote {
        guard let url = URL(string: "https://raw.githubusercontent.com/alyssiak/SpeciallyQuotes/main/statham.json") else {
            throw URLError(.badURL)
        }
        
        // говорим: попробуй дождаться
        // try - функция может выбросить ошибку
        // await - дождись результата асинхронной функции
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }
        
        let quotes = try JSONDecoder().decode([Quote].self, from: data)
        guard let quote = quotes.randomElement() else {
            throw URLError(.cannotParseResponse)
        }

        return quote
    }
}
