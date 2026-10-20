//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import Testing
@testable import SDK_Showcase

struct CategoriesInteractorMock: CategoriesInteractor {
    func loadCategories() -> [SDK_Showcase.Category] {
        [Category(name: "Test", description: "Test description", options: [], selections: [], requiredActions: [], optionalActions: []),
         Category(name: "Test2", description: "Test2 description", options: [], selections: [], requiredActions: [], optionalActions: [])]
    }

    func category(of type: Categories) -> Category? {
        loadCategories().first(where: { $0.type == type })
    }
}

struct CategoriesInteractorEmptyMock: CategoriesInteractor {
    func loadCategories() -> [SDK_Showcase.Category] {
        []
    }

    func category(of type: Categories) -> Category? {
        nil
    }
}
