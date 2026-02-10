# SwiftUI Rules (Condensed)

**Full versions:** [swiftui-api-rules.md](../swiftui-api-rules.md), [swiftui-component-rules.md](../swiftui-component-rules.md)

**Inherits:** [common-rules.md](../common-rules.md), [code-quality-condensed-rules.md](./code-quality-condensed-rules.md), [swift-ios-condensed-rules.md](./swift-ios-condensed-rules.md)

Essential rules for idiomatic SwiftUI APIs and components. Apply in addition to inherited rules.

---

## Naming Conventions ⭐⭐⭐

| Rule | Pattern | Example |
|------|---------|---------|
| SWIFTUI-NAME-001 | View types → PascalCase noun | `ProfileCard`, `LoadingIndicator` (not `profileCard`, `RenderProfile`) |
| SWIFTUI-NAME-002 | View modifiers → camelCase | `func cardStyle()`, `.font()`, `.padding()` |
| SWIFTUI-NAME-003 | Environment values → descriptive | `var theme: Theme` (not `themeEnvironment`) |
| SWIFTUI-NAME-004 | PreferenceKey → "Key" or "Preference" suffix | `ViewSizeKey`, `ScrollOffsetPreference` |
| COMP-NAME-001 | Descriptive view names | `ProfileImageView`, `ErrorBanner` (not `MyView`) |
| COMP-NAME-002 | Avoid redundant "View" suffix | `ProfileCard` (not `ProfileCardView`) unless adds clarity |
| COMP-NAME-003 | Style variants → explicit types | `Button`, `OutlinedButton` (not `enum ButtonStyle`) |

---

## View Design Patterns ⭐⭐⭐

### Core Principles

| Rule | Principle | Why |
|------|-----------|-----|
| SWIFTUI-VIEW-001 | Single responsibility per view | Easier to understand, test, reuse |
| SWIFTUI-VIEW-002 | Prefer stateless views | Caller controls state - testable, predictable |
| SWIFTUI-COMP-001 | Split complex components | Each solves ONE problem |
| SWIFTUI-COMP-002 | Layer components | Low-level customizable + high-level opinionated |

```swift
// Good - Stateless
struct CounterView: View {
    let count: Int
    let onIncrement: () -> Void
    let onDecrement: () -> Void
    
    var body: some View {
        HStack {
            Button("-", action: onDecrement)
            Text("\(count)")
            Button("+", action: onIncrement)
        }
    }
}

// Usage - Parent owns state
struct ParentView: View {
    @State private var count = 0
    
    var body: some View {
        CounterView(
            count: count,
            onIncrement: { count += 1 },
            onDecrement: { count -= 1 }
        )
    }
}
```

### View Body Organization

```swift
// Good - Extract complex body logic
struct DashboardView: View {
    var body: some View {
        ScrollView {
            mainContent
        }
    }
    
    @ViewBuilder
    private var mainContent: some View {
        if user.isAuthenticated {
            if user.hasCompletedOnboarding {
                DashboardContent(user: user)
            } else {
                OnboardingContent(user: user)
            }
        } else {
            LoginContent()
        }
    }
}
```

---

## State Management ⭐⭐⭐

### Property Wrapper Selection

| Wrapper | Ownership | Use When |
|---------|-----------|----------|
| `@State` | View owns | Simple value types, view-local state |
| `@Binding` | Parent owns | Child needs to modify parent's state |
| `@StateObject` | View owns | View creates and owns ObservableObject |
| `@ObservedObject` | Parent owns | View receives ObservableObject from parent |
| `@EnvironmentObject` | Ancestor owns | Object shared across view hierarchy |
| `@Environment` | System/ancestor | Read system or custom environment values |

### Critical State Rules

| Rule | Guideline |
|------|-----------|
| SWIFTUI-STATE-002 | **@State must be private** |
| SWIFTUI-STATE-003 | **@StateObject** when view creates, **@ObservedObject** when received |
| SWIFTUI-STATE-004 | Use `$` prefix for bindings |
| SWIFTUI-STATE-005 | Minimize state - derive computed values |

```swift
// Good - Correct wrapper usage
struct ParentView: View {
    @StateObject private var viewModel = ParentViewModel()  // View creates
    @State private var isSheetPresented = false  // View-local, private
    
    var body: some View {
        ChildView(viewModel: viewModel)
    }
}

struct ChildView: View {
    @ObservedObject var viewModel: ParentViewModel  // Received from parent
    
    var body: some View {
        Text(viewModel.data)
    }
}

// @Published in ObservableObject
class UserViewModel: ObservableObject {
    @Published var userName: String = ""
    @Published var isLoading: Bool = false
}
```

---

## Component Parameters ⭐⭐⭐

### Parameter Order

1. **Required** parameters (data/content)
2. **Optional** customization parameters (with defaults)
3. **Trailing closures** (if any)

```swift
struct ProfileCard: View {
    // 1. Required
    let user: User
    
    // 2. Optional with defaults
    let showBadge: Bool = true
    let cornerRadius: CGFloat = 12
    
    // 3. Trailing closures
    let onTap: (() -> Void)?
}
```

### Key Parameter Rules

| Rule | Guideline |
|------|-----------|
| COMP-PARAM-002 | Provide sensible defaults |
| COMP-PARAM-003 | Optional for "absence", not defaults |
| COMP-PARAM-004 | Descriptive closure names (`onSearch`, `onCancel`) |

---

## View Modifiers ⭐⭐⭐

### Modifier Rules

| Rule | Guideline |
|------|-----------|
| SWIFTUI-MOD-001 | Components should accept standard modifiers |
| SWIFTUI-MOD-002 | Don't create parameters that duplicate standard modifiers |
| SWIFTUI-MOD-003 | Extract repeated modifier chains into custom modifiers |

```swift
// Good - Custom modifier for reusable styling
struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 4)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardModifier())
    }
}

// Usage
Text("Hello").cardStyle()
VStack { }.cardStyle()
```

---

## Content Parameters ⭐⭐⭐

### @ViewBuilder for Flexibility

| Rule | Guideline |
|------|-----------|
| SWIFTUI-CONTENT-001 | Prefer `@ViewBuilder` over data parameters |
| SWIFTUI-CONTENT-002 | Multiple slots for distinct content areas |
| SWIFTUI-CONTENT-003 | Optional slots default to `EmptyView` |

```swift
// Good - Flexible content slot
struct Card<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack {
            content
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}

// Usage - Full flexibility
Card {
    Image("custom-image")
    Text("Title")
    Text("Subtitle").font(.caption)
}
```

---

## View Composition ⭐⭐

### Composition Rules

- **SWIFTUI-COMP-001:** Prefer composition over inheritance
- **SWIFTUI-COMP-002:** Extract repeated patterns into reusable components

```swift
// Good - Composition
struct ProfileCard: View {
    let user: User
    
    var body: some View {
        VStack {
            ProfileImage(url: user.avatarURL)
            ProfileInfo(user: user)
            ProfileActions(user: user)
        }
    }
}
```

---

## Environment Values ⭐⭐

### Custom Environment Values

```swift
// Define the key
private struct ThemeKey: EnvironmentKey {
    static let defaultValue: Theme = .light
}

// Extend EnvironmentValues
extension EnvironmentValues {
    var theme: Theme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}

// Provide value
ContentView()
    .environment(\.theme, .dark)

// Read value
struct DetailView: View {
    @Environment(\.theme) var theme
    
    var body: some View {
        Text("Current theme: \(theme.name)")
    }
}
```

---

## Performance ⭐⭐

### Optimization Rules

| Rule | Technique |
|------|-----------|
| SWIFTUI-PERF-001 | Conform to `Equatable` for optimization |
| SWIFTUI-PERF-002 | Avoid expensive operations in `body` |
| SWIFTUI-PERF-003 | Use `LazyVStack`/`LazyHStack` for large lists |

```swift
// Good - Equatable view
struct ItemRow: View, Equatable {
    let item: Item
    
    var body: some View {
        HStack {
            Text(item.name)
            Text(item.price)
        }
    }
    
    static func == (lhs: ItemRow, rhs: ItemRow) -> Bool {
        lhs.item.id == rhs.item.id
    }
}

// Usage
List(items) { item in
    ItemRow(item: item)
        .equatable()  // Only updates if properties change
}
```

---

## PreferenceKeys ⭐⭐

### Child-to-Parent Communication

```swift
// Define PreferenceKey
struct ViewSizeKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

// Child reports size
extension View {
    func reportSize(to binding: Binding<CGSize>) -> some View {
        background(
            GeometryReader { geometry in
                Color.clear.preference(
                    key: ViewSizeKey.self,
                    value: geometry.size
                )
            }
        )
        .onPreferenceChange(ViewSizeKey.self) { size in
            binding.wrappedValue = size
        }
    }
}
```

---

## Accessibility ⭐⭐⭐

### Critical A11y Rules

| Rule | Guideline |
|------|-----------|
| SWIFTUI-ACCESS-001 | Provide labels for non-text elements |
| SWIFTUI-ACCESS-002 | Add traits and hints for complex interactions |
| SWIFTUI-ACCESS-003 | Group related elements |
| SWIFTUI-ACCESS-004 | Support Dynamic Type |

```swift
// Good - Accessibility labels
struct IconButton: View {
    let icon: String
    let label: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
        }
        .accessibilityLabel(label)
    }
}

// Good - Grouped accessibility
struct UserRow: View {
    let user: User
    
    var body: some View {
        HStack {
            AsyncImage(url: user.avatarURL)
                .accessibilityHidden(true)  // Decorative
            
            VStack(alignment: .leading) {
                Text(user.name)
                Text(user.email).font(.caption)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(user.name), \(user.email)")
    }
}

// Good - Dynamic Type support
Text("Hello")
    .font(.headline)  // Scales with Dynamic Type

// Bad - Fixed size
Text("Hello")
    .font(.system(size: 18))  // Doesn't scale
```

---

## Configuration ⭐⭐

### Configuration Patterns

```swift
// Good - Configuration struct for related settings
struct ButtonConfiguration {
    var cornerRadius: CGFloat = 8
    var padding: EdgeInsets = EdgeInsets(top: 12, leading: 24, bottom: 12, trailing: 24)
    var backgroundColor: Color = .blue
    var foregroundColor: Color = .white
}

struct ConfigurableButton: View {
    let title: String
    let action: () -> Void
    let configuration: ButtonConfiguration
    
    init(
        title: String,
        action: @escaping () -> Void,
        configuration: ButtonConfiguration = ButtonConfiguration()
    ) {
        self.title = title
        self.action = action
        self.configuration = configuration
    }
}
```

---

## Documentation ⭐⭐

### Required Documentation

Every reusable component must have:
1. One-line summary
2. Detailed description
3. Usage example
4. Parameter descriptions
5. Special behaviors noted

```swift
/// A card view that displays content with a standard visual style.
///
/// `Card` provides a container with padding, background, rounded corners,
/// and shadow. It accepts any SwiftUI content via a `@ViewBuilder` closure.
///
/// ## Usage
///
/// ```swift
/// Card {
///     Text("Hello")
///     Text("World")
/// }
/// ```
///
/// - Note: The card automatically adapts to the current color scheme.
struct Card<Content: View>: View {
    /// The content to display inside the card.
    let content: Content
    
    /// Creates a card with the specified content.
    ///
    /// - Parameter content: A view builder that creates the card's content.
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
}
```

---

## Quick Checklist

### Before Publishing SwiftUI Code ✅

**Naming:**
- [ ] Views use PascalCase nouns
- [ ] Modifiers use camelCase
- [ ] Environment values named clearly
- [ ] PreferenceKeys have "Key" or "Preference" suffix

**Design:**
- [ ] Single responsibility per view/component
- [ ] Views are stateless where possible
- [ ] Complex body logic extracted to @ViewBuilder properties
- [ ] Component necessity justified

**State:**
- [ ] Appropriate property wrapper chosen
- [ ] @State properties are private
- [ ] @StateObject vs @ObservedObject used correctly
- [ ] Bindings created with $ syntax
- [ ] State minimized, computed values derived
- [ ] @Published used for observable properties

**Parameters:**
- [ ] Logical parameter order (required, optional, closures)
- [ ] Sensible defaults provided
- [ ] Optional for "absence", not defaults
- [ ] Descriptive closure names

**Modifiers:**
- [ ] Works with standard modifiers
- [ ] No duplication of standard modifiers
- [ ] Custom modifiers for reusable styling

**Content:**
- [ ] @ViewBuilder for flexible content
- [ ] Multiple slots for distinct areas
- [ ] Optional content defaults to EmptyView

**Composition:**
- [ ] Views composed, not inherited
- [ ] Reusable components extracted

**Performance:**
- [ ] Equatable conformance where beneficial
- [ ] Expensive operations cached
- [ ] LazyStacks for large collections

**Accessibility:**
- [ ] Labels for non-text elements
- [ ] Traits and hints added
- [ ] Related elements grouped
- [ ] Dynamic Type supported

**Documentation:**
- [ ] Component purpose documented
- [ ] Usage examples provided
- [ ] All parameters documented

---

## Common Mistakes

**Naming:**
- ❌ `struct profileCard: View` → ✅ `struct ProfileCard: View`
- ❌ `var themeEnvironment: Theme` → ✅ `var theme: Theme`
- ❌ `func CardStyle()` → ✅ `func cardStyle()`
- ❌ `struct ProfileCardPreview` → ✅ `struct ProfileCard_Previews`

**State Management:**
- ❌ `@State var count` (public) → ✅ `@State private var count`
- ❌ `@ObservedObject var vm = ViewModel()` → ✅ `@StateObject private var vm = ViewModel()`
- ❌ Store derived values → ✅ Compute on demand
- ❌ Mutate state in `init()` → ✅ Initialize with value or use `.onAppear`

**Parameters:**
- ❌ `let text: String` (restrictive) → ✅ `@ViewBuilder content: () -> Content` (flexible)
- ❌ `let cornerRadius: CGFloat?` (for default) → ✅ `let cornerRadius: CGFloat = 8`
- ❌ `let callback: () -> Void` (vague) → ✅ `let onTap: () -> Void` (clear)

**Modifiers:**
- ❌ Custom parameters duplicating modifiers → ✅ Let users apply standard modifiers
- ❌ Expensive work in body → ✅ Use computed properties or cache
- ❌ Body longer than 10 lines → ✅ Extract subviews
- ❌ Nesting deeper than 4 levels → ✅ Extract to dedicated views

**Closures & Syntax:**
- ❌ `return Text("Hello")` in body → ✅ `Text("Hello")` (implicit return)
- ❌ Redundant `self.property` → ✅ `property` (unless required)
- ❌ `.animation(.spring())` → ✅ `.animation(.spring(), value: state)` (iOS 15+)

**Navigation & Lifecycle:**
- ❌ `NavigationView` → ✅ `NavigationStack` (iOS 16+)
- ❌ GeometryReader for simple sizing → ✅ `.frame(maxWidth: .infinity)`

**Anti-Patterns:**
- ❌ `AnyView` everywhere → ✅ Use `@ViewBuilder`
- ❌ `EmptyView()` in else → ✅ Use `if` without `else`
- ❌ `@State` with classes → ✅ Use `@StateObject`

**Accessibility:**
- ❌ Icon without label → ✅ `.accessibilityLabel("Delete")`
- ❌ Fixed font sizes → ✅ Use `.font(.headline)` for Dynamic Type

---

## Priority Guide

**P0 - Critical (Must Fix):**
- Views not PascalCase nouns (SWIFTUI-NAME-001)
- @State not private (SWIFTUI-STATE-002)
- @ObservedObject when view creates object (SWIFTUI-STATE-003)
- Missing accessibility labels (SWIFTUI-ACCESS-001)
- Fixed font sizes preventing Dynamic Type (SWIFTUI-ACCESS-004)

**P1 - High (Should Fix):**
- Multiple responsibilities per view (SWIFTUI-VIEW-001)
- Internal state when should be stateless (SWIFTUI-VIEW-002)
- Data parameters instead of @ViewBuilder (SWIFTUI-CONTENT-001)
- Parameters duplicating standard modifiers (SWIFTUI-MOD-002)
- Expensive operations in body (SWIFTUI-PERF-002)

**P2 - Medium (Fix When Refactoring):**
- Complex body not extracted (SWIFTUI-VIEW-003)
- Missing custom modifiers for repeated patterns (SWIFTUI-MOD-003)
- No Equatable conformance for repeated views (SWIFTUI-PERF-001)
- Missing accessibility traits/hints (SWIFTUI-ACCESS-002)
- Missing documentation (SWIFTUI-DOC-001)

**P3 - Low (Nice to Have):**
- Redundant "View" suffix (COMP-NAME-002)
- Component could be composition of existing views (SWIFTUI-COMP-003)

---

## Resources

- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [State and Data Flow](https://developer.apple.com/documentation/swiftui/state-and-data-flow)
- [View Layout and Presentation](https://developer.apple.com/documentation/swiftui/view-layout-and-presentation)
- [Accessibility in SwiftUI](https://developer.apple.com/documentation/swiftui/accessibility)

For complete rules with detailed explanations and examples, see:
- [swiftui-api-rules.md](../swiftui-api-rules.md) - API design patterns
- [swiftui-component-rules.md](../swiftui-component-rules.md) - Component guidelines

---

**Last Updated:** January 2026  
**Version:** 1.0  
**Maintained By:** Development Team
