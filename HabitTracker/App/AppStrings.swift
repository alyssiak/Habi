//
//  AppStrings.swift
//  HabitTracker
//
//  Created by Alice Kamyshenko on 17.07.2026.
//

enum AppStrings {
    static func habitsTab(_ language: AppLanguage) -> String {
        switch language {
        case .english: return "Habits"
        case .russian: return "Привычки"
        }
    }

    static func statisticsTab(_ language: AppLanguage) -> String {
        switch language {
        case .english: return "Statistics"
        case .russian: return "Статистика"
        }
    }

    static func profileTab(_ language: AppLanguage) -> String {
        switch language {
        case .english: return "Profile"
        case .russian: return "Профиль"
        }
    }

    static func greeting(name: String, language: AppLanguage) -> String {
        switch language {
        case .english: return "Hello, \(name)!"
        case .russian: return "Привет, \(name)!"
        }
    }

    static func noHabitsTitle(_ language: AppLanguage) -> String {
        switch language {
        case .english: return "No habits yet"
        case .russian: return "Пока нет привычек"
        }
    }

    static func noHabitsSubtitle(_ language: AppLanguage) -> String {
        switch language {
        case .english: return "Tap + to add your first habit"
        case .russian: return "Нажми +, чтобы добавить первую привычку"
        }
    }

    static func undo(_ language: AppLanguage) -> String {
        switch language {
        case .english: return "Undo"
        case .russian: return "Вернуть"
        }
    }

    static func deleteHabitTitle(_ language: AppLanguage) -> String {
        switch language {
        case .english: return "Delete habit?"
        case .russian: return "Удалить привычку?"
        }
    }

    static func deleteHabitMessage(title: String, language: AppLanguage) -> String {
        switch language {
        case .english:
            return "This will remove \"\(title)\" from your list. You can undo it right after."
        case .russian:
            return "Привычка «\(title)» исчезнет из списка. Сразу после удаления её можно вернуть."
        }
    }

    static func cancel(_ language: AppLanguage) -> String {
        switch language {
        case .english: return "Cancel"
        case .russian: return "Отмена"
        }
    }

    static func delete(_ language: AppLanguage) -> String {
        switch language {
        case .english: return "Delete"
        case .russian: return "Удалить"
        }
    }

    static func edit(_ language: AppLanguage) -> String {
        switch language {
        case .english: return "Edit"
        case .russian: return "Изменить"
        }
    }

    static func deletedOne(title: String, language: AppLanguage) -> String {
        switch language {
        case .english: return "\"\(title)\" deleted"
        case .russian: return "«\(title)» удалена"
        }
    }

    static func deletedMany(count: Int, language: AppLanguage) -> String {
        switch language {
        case .english: return "\(count) habits deleted"
        case .russian: return "Удалено привычек: \(count)"
        }
    }

    static func quoteTitle(_ language: AppLanguage) -> String {
        switch language {
        case .english: return "Quote of the day"
        case .russian: return "Цитата дня"
        }
    }

    static func fallbackQuote(_ language: AppLanguage) -> String {
        switch language {
        case .english: return "Track your habits to stay motivated."
        case .russian: return "Отмечай привычки и продолжай двигаться."
        }
    }

    static func weeklySnapshot(_ language: AppLanguage) -> String {
        switch language {
        case .english: return "Weekly snapshot"
        case .russian: return "Неделя"
        }
    }

    static func settings(_ language: AppLanguage) -> String {
        switch language {
        case .english: return "Settings"
        case .russian: return "Настройки"
        }
    }

    static func theme(_ language: AppLanguage) -> String {
        switch language {
        case .english: return "Theme"
        case .russian: return "Тема"
        }
    }

    static func language(_ language: AppLanguage) -> String {
        switch language {
        case .english: return "Language"
        case .russian: return "Язык"
        }
    }

    static func dailyReminder(_ language: AppLanguage) -> String {
        switch language {
        case .english: return "Daily reminder"
        case .russian: return "Напоминание"
        }
    }

    static func comingSoon(_ language: AppLanguage) -> String {
        switch language {
        case .english: return "Coming soon"
        case .russian: return "Скоро"
        }
    }

    static func about(_ language: AppLanguage) -> String {
        switch language {
        case .english: return "About"
        case .russian: return "О приложении"
        }
    }

    static func appVersion(_ language: AppLanguage) -> String {
        switch language {
        case .english: return "HabitTracker MVP"
        case .russian: return "HabitTracker MVP"
        }
    }

    static func currentStreak(_ language: AppLanguage) -> String {
        switch language {
        case .english: return "Current\nstreak"
        case .russian: return "Текущая\nсерия"
        }
    }

    static func bestStreak(_ language: AppLanguage) -> String {
        switch language {
        case .english: return "Best\nstreak"
        case .russian: return "Лучшая\nсерия"
        }
    }

    static func completionRate(_ language: AppLanguage) -> String {
        switch language {
        case .english: return "Completion\nrate"
        case .russian: return "Процент\nвыполнения"
        }
    }

    static func perfectDays(_ language: AppLanguage) -> String {
        switch language {
        case .english: return "Perfect\ndays"
        case .russian: return "Идеальные\nдни"
        }
    }

    static func themeTitle(_ theme: AppTheme, language: AppLanguage) -> String {
        switch (theme, language) {
        case (.system, .english): return "System"
        case (.system, .russian): return "Системная"
        case (.light, .english): return "Light"
        case (.light, .russian): return "Светлая"
        case (.dark, .english): return "Dark"
        case (.dark, .russian): return "Тёмная"
        }
    }

    static func addHabit(_ language: AppLanguage) -> String {
        switch language {
        case .english: return "Add Habit"
        case .russian: return "Новая привычка"
        }
    }

    static func editHabit(_ language: AppLanguage) -> String {
        switch language {
        case .english: return "Edit Habit"
        case .russian: return "Изменить привычку"
        }
    }

    static func save(_ language: AppLanguage) -> String {
        switch language {
        case .english: return "Save"
        case .russian: return "Сохранить"
        }
    }

    static func update(_ language: AppLanguage) -> String {
        switch language {
        case .english: return "Update"
        case .russian: return "Обновить"
        }
    }

    static func habitName(_ language: AppLanguage) -> String {
        switch language {
        case .english: return "Habit name"
        case .russian: return "Название привычки"
        }
    }

    static func habitNamePlaceholder(_ language: AppLanguage) -> String {
        switch language {
        case .english: return "e.g. Morning run"
        case .russian: return "Например, утренняя пробежка"
        }
    }

    static func enterHabitName(_ language: AppLanguage) -> String {
        switch language {
        case .english: return "Enter habit name"
        case .russian: return "Введите название привычки"
        }
    }

    static func description(_ language: AppLanguage) -> String {
        switch language {
        case .english: return "Description"
        case .russian: return "Описание"
        }
    }

    static func shortNote(_ language: AppLanguage) -> String {
        switch language {
        case .english: return "Add a short note"
        case .russian: return "Добавьте короткую заметку"
        }
    }

    static func emoji(_ language: AppLanguage) -> String {
        switch language {
        case .english: return "Emoji"
        case .russian: return "Эмодзи"
        }
    }

    static func color(_ language: AppLanguage) -> String {
        switch language {
        case .english: return "Color"
        case .russian: return "Цвет"
        }
    }

    static func editProfile(_ language: AppLanguage) -> String {
        switch language {
        case .english: return "Edit Profile"
        case .russian: return "Редактировать профиль"
        }
    }

    static func changePhoto(_ language: AppLanguage) -> String {
        switch language {
        case .english: return "Change photo"
        case .russian: return "Изменить фото"
        }
    }

    static func name(_ language: AppLanguage) -> String {
        switch language {
        case .english: return "Name"
        case .russian: return "Имя"
        }
    }

    static func archive(_ language: AppLanguage) -> String {
        switch language {
        case .english: return "Archive"
        case .russian: return "Архив"
        }
    }

    static func noArchivedHabits(_ language: AppLanguage) -> String {
        switch language {
        case .english: return "No archived habits yet."
        case .russian: return "В архиве пока пусто."
        }
    }

    static func deleteAllArchivedTitle(_ language: AppLanguage) -> String {
        switch language {
        case .english: return "Delete all archived habits?"
        case .russian: return "Удалить весь архив?"
        }
    }

    static func cannotBeUndone(_ language: AppLanguage) -> String {
        switch language {
        case .english: return "This action cannot be undone."
        case .russian: return "Это действие нельзя отменить."
        }
    }

    static func deleteForeverTitle(_ language: AppLanguage) -> String {
        switch language {
        case .english: return "Delete forever?"
        case .russian: return "Удалить навсегда?"
        }
    }

    static func deleteForeverMessage(title: String, language: AppLanguage) -> String {
        switch language {
        case .english:
            return "This will permanently delete \"\(title)\" and its progress history."
        case .russian:
            return "Привычка «\(title)» и вся её история будут удалены навсегда."
        }
    }
}
