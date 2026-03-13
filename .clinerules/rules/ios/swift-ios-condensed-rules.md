# Swift/iOS Rules (Condensed)

**Full version:** [swift-ios-rules.md](../swift-ios-rules.md)

**Inherits:** [common-rules.md](../common-rules.md), [code-quality-condensed-rules.md](./code-quality-condensed-rules.md)

Essential rules for Swift and iOS development. Apply in addition to inherited rules.

---

## Format & Style

| Rule | Standard | Example |
|------|----------|---------|
| Indent | 2 spaces | Kodeco/community standard |
| Line length | ~70 chars | Soft limit |
| Brace style | End of line | `func foo() {` |
| Semicolons | Omit | `let x = 5` not `let x = 5;` |
| Implicit return | Single expression | `func double(_ x: Int) -> Int { x * 2 }` |
| Use of self | Only when required | Avoid unless @escaping or init |

---

## Naming Conventions ⭐⭐⭐

| Element | Convention | Example |
|---------|-----------|---------|
| Types | UpperCamelCase | `UserProfile`, `NetworkManager` |
| Functions/Variables | lowerCamelCase | `fetchUserData()`, `userName` |
| Enum cases | lowerCamelCase | `.success`, `.failure` |
| Protocols | UpperCamelCase or `-able` | `Codable`, `DataSource` |
| Booleans | is/has/can prefix | `isValid`, `hasData` |
| Generics | Descriptive or single letter | `Element`, `T` |
| Delegates | First param unnamed, is source | `func picker(_ picker: Picker, didSelect: String)` |

---

## Constants & Variables ⭐⭐⭐

**Critical: Prefer `let` over `var`**

| Rule | Use | When |
|------|-----|------|
| `let` | Constants (immutable) | Value won't change |
| `var` | Variables (mutable) | Value will change |
| Type inference | Omit type when clear | `let name = "Alice"` |
| Explicit type | When needed | `let name: String` (no init value) |
| `lazy var` | Expensive init | Closure or factory method |

```swift
// Good
let maxAttempts = 3
var currentAttempt = 0

// Lazy with closure
lazy var thumbnail: UIImage = { generateThumbnail() }()

// Lazy with factory
lazy var locationManager = makeLocationManager()

// Constants in enums (namespace)
enum Math {
    static let e = 2.718281828459045235360287
}

// Empty collections with type annotation
var names: [String] = []
var lookup: [String: Int] = [:]

// Bad
var maxAttempts = 3  // Should be let
var names = [String]()  // Use type annotation
```

---

## Optionals ⭐⭐⭐

**Swift's killer feature for handling absence**

### Syntax

| Pattern | Syntax | Use Case |
|---------|--------|----------|
| Optional type | `Type?` | May be nil |
| Nil value | `nil` | Absence |
| Optional binding | `if let value = optional` | Use if present |
| Guard binding | `guard let value = optional else { return }` | Early exit |
| Nil-coalescing | `optional ?? defaultValue` | Provide fallback |
| Optional chaining | `user?.address?.street` | Safe nested access |
| Force unwrap | `optional!` | **Avoid** - crashes if nil |
| Implicitly unwrapped | `Type!` | IBOutlets only |

### Critical Rules

```swift
// Good - optional binding (shadow original name)
if let user = findUser(id: 123) {
    print(user.name)
}

// Swift 5.7+ shorthand
if let user {
    print(user.name)
}

// Good - guard for early exit (Golden Path)
func processUser(id: Int) {
    guard let user = findUser(id: id) else { return }
    // Happy path not nested
    print(user.name)
}

// Good - nil-coalescing
let name = user.nickname ?? user.fullName

// Good - optional chaining
let street = user?.address?.street

// Bad - force unwrap
let user = findUser(id: 123)!  // Crashes if nil

// Bad - nested ifs
if let user = user {
    if let address = user.address {  // Nested - use guard
        // ...
    }
}

// Acceptable - IBOutlets
@IBOutlet weak var tableView: UITableView!
```

---

## Type Safety ⭐⭐

- **No implicit conversions** - must explicitly convert
- **Avoid `Any`** - use generics or protocols

```swift
// Good
let doubleValue = Double(intValue)

// Bad
let total = intValue + 3.14  // Compile error
```


---

## Code Organization ⭐⭐

**Use Extensions for Protocol Conformance**

```swift
// Good - separate extensions with MARK
class MyViewController: UIViewController {
    // Class stuff
}

// MARK: - UITableViewDataSource
extension MyViewController: UITableViewDataSource {
    // Table view methods
}

// Bad - all in one
class MyViewController: UIViewController, UITableViewDataSource {
    // Everything mixed
}
```

**Key Organization Rules:**
- Remove unused/template code
- Minimal imports (Foundation vs UIKit)
- Use `// MARK: -` for sections
- Hide implementation details in extensions with `private`

---

## Functions ⭐⭐

### Argument Labels

```swift
// Good - descriptive labels
func move(from start: Point, to end: Point) { }
move(from: pointA, to: pointB)

// Good - omit first with _
func remove(_ item: Item) { }
remove(item)
```

### Key Features

| Feature | Syntax | Example |
|---------|--------|---------|
| Default params | `param: Type = value` | `timeout: Double = 30.0` |
| Variadic | `param: Type...` | `numbers: Double...` |
| inout | `inout Type` | `increment(&count)` |
| Throwing | `throws` | `func load() throws -> Data` |

---

## Classes vs Structs ⭐⭐⭐

**Critical: Prefer structs by default**

| Feature | Struct | Class |
|---------|--------|-------|
| Semantics | Value type (copied) | Reference type (shared) |
| Inheritance | ❌ No | ✅ Yes |
| Deinitializers | ❌ No | ✅ Yes |
| Memberwise init | ✅ Automatic | ❌ Manual |
| Thread safety | ✅ Copy = safe | ⚠️ Needs care |
| Use when | Default choice | Need class features |

```swift
// Good - struct for data
struct User {
    let id: Int
    var name: String
}

// Use class when need:
// - Inheritance
// - Deinitializers  
// - Reference semantics
class ViewController: UIViewController { }
```

---


---

## Access Control ⭐⭐

- **Prefer `private` over `fileprivate`**
- **Access control as leading specifier** (except for `static`, `@IBAction`)
- **Don't specify `internal`** (it's the default)

```swift
// Good
private let message = "Great Scott!"
@IBOutlet private weak var label: UILabel!

// Not preferred
fileprivate let message = "Great Scott!"
lazy dynamic private var capacitor = FluxCapacitor()  // Wrong order
```

---

## Properties ⭐⭐

| Type | Syntax | Use |
|------|--------|-----|
| Stored | `var/let name: Type` | Regular property |
| Computed (read-only) | `var name: Type { value }` | Omit `get` |
| Computed (read-write) | `var name: Type { get {} set {} }` | Need `get` |
| Lazy | `lazy var name = value` | Expensive init |
| Observed | `var name: Type { willSet/didSet }` | React to changes |

```swift
struct Circle {
    var radius: Double
    
    // Read-only computed - omit get
    var area: Double {
        .pi * radius * radius
    }
}
```

---

## Protocols ⭐⭐

**Protocol-Oriented Programming**

```swift
// Define protocol
protocol Drawable {
    func draw()
}

// Default implementation
extension Drawable {
    func draw() { /* default */ }
}

// Protocol composition
func process<T: Codable & Equatable>(item: T) { }
```

**Naming:**
- Nouns: `DataSource`, `Collection`
- Adjectives: `Codable`, `Equatable`, `Cancellable`

**Final Classes:**
- Use `final` when inheritance not intended

```swift
final class Box<T> {
    let value: T
    init(_ value: T) { self.value = value }
}
```

---

## Error Handling ⭐⭐⭐

### Define Errors

```swift
enum NetworkError: Error {
    case invalidURL
    case noConnection
    case serverError(code: Int)
}
```

### Handle Errors

| Pattern | Syntax | Use |
|---------|--------|-----|
| Do-catch | `do { try } catch { }` | Handle specific errors |
| Try? | `try?` | Convert to optional |
| Try! | `try!` | Force (use sparingly) |
| Throws | `throws` | Propagate error |
| Result | `Result<T, Error>` | Async operations |

```swift
// Do-catch
do {
    let data = try loadData()
} catch NetworkError.invalidURL {
    print("Invalid URL")
} catch {
    print("Error: \(error)")
}

// Try?
if let data = try? loadData() { }

// Result
func fetch(completion: @escaping (Result<Data, Error>) -> Void)
```

---


---

## Control Flow ⭐⭐

**Key Rules:**
- **Prefer `for-in`** over while loops
- **Ternary operator** for simple assignments only
- **No parentheses** in conditionals

```swift
// Good
for (index, person) in attendeeList.enumerated() {
    print("\(person) is at #\(index)")
}

let result = value != 0 ? x : y

if name == "Hello" {
    print("World")
}

// Not preferred
var i = 0
while i < attendeeList.count { i += 1 }

result = a > b ? x = c > d ? c : d : y  // Too complex

if (name == "Hello") {  // No parentheses
    print("World")
}
```

---

## Closures ⭐⭐

### Syntax & Trailing Closures

```swift
// Type inference
let doubled = numbers.map { $0 * 2 }

// Trailing closure - single closure only
UIView.animate(withDuration: 1.0) {
    self.myView.alpha = 0
}

// Multiple closures - use labels
UIView.animate(withDuration: 1.0, animations: {
    self.myView.alpha = 0
}, completion: { finished in
    self.myView.removeFromSuperview()
})
```


### Capture Lists & Extending Lifetime ⭐⭐⭐

```swift
// Good - weak self + guard
resource.request().onComplete { [weak self] response in
    guard let self = self else { return }
    let model = self.updateModel(response)
    self.updateUI(model)
}

// Not preferred - optional chaining
resource.request().onComplete { [weak self] response in
    let model = self?.updateModel(response)
    self?.updateUI(model)  // self might be nil between calls
}

// Bad - retain cycle
loadData { result in
    self.processResult(result)  // Retains self
}
```

---

## Concurrency ⭐⭐⭐

### Modern Swift (async/await)

```swift
// Async function
func fetchUser(id: Int) async throws -> User {
    let data = try await networkManager.fetchData(from: "/users/\(id)")
    return try JSONDecoder().decode(User.self, from: data)
}

// Call
Task {
    let user = try await fetchUser(id: 123)
}

// Actor for thread safety
actor Counter {
    private var value = 0
    func increment() { value += 1 }
}

// MainActor for UI
@MainActor
class ViewModel: ObservableObject {
    @Published var users: [User] = []
}
```

### Legacy (GCD)

```swift
DispatchQueue.global(qos: .background).async {
    let result = processData()
    DispatchQueue.main.async {
        self.updateUI(with: result)
    }
}
```

---

## Memory Management ⭐⭐⭐

**ARC (Automatic Reference Counting)**

| Reference | Use | Behavior |
|-----------|-----|----------|
| Strong (default) | Regular ownership | Keeps object alive |
| `weak` | Optional reference | Set to nil when deallocated |
| `unowned` | Non-optional reference | Crashes if accessed after dealloc |

### Critical: Avoid Retain Cycles

```swift
// Good - weak delegate
protocol Delegate: AnyObject { }
class DataSource {
    weak var delegate: Delegate?
}

// Good - weak parent
class Child {
    weak var parent: Parent?
}

// Good - closure capture
loadData { [weak self] in
    guard let self = self else { return }
    self.process()
}
```

---

## Collections ⭐

```swift
// Array
var numbers: [Int] = [1, 2, 3]

// Set  
var uniqueNames: Set<String> = ["Alice", "Bob"]

// Dictionary
var scores: [String: Int] = ["Alice": 95]

// Operations
let doubled = numbers.map { $0 * 2 }
let evens = numbers.filter { $0 % 2 == 0 }
let sum = numbers.reduce(0, +)
```

---

## iOS Specific ⭐⭐⭐

### UIKit Lifecycle

```swift
class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()  // One-time setup
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)  // Before appears
    }
}
```

### SwiftUI

```swift
struct ContentView: View {
    @State private var name = ""
    
    var body: some View {
        VStack {
            TextField("Name", text: $name)
            Text("Hello, \(name)!")
        }
    }
}
```

### Property Wrappers

| Wrapper | Use | Where |
|---------|-----|-------|
| `@State` | Local state | SwiftUI views |
| `@Binding` | Two-way binding | Child views |
| `@Published` | Observable property | ViewModels |
| `@ObservedObject` | External object | SwiftUI |
| `@EnvironmentObject` | Shared across views | SwiftUI |
| `@IBOutlet` | Interface Builder | UIKit |

---

## Quick Checklist ✅

**Before committing:**
- [ ] 2-space indentation (not 4)
- [ ] Types: UpperCamelCase, Functions/vars: lowerCamelCase
- [ ] `let` for constants, `var` only when mutable
- [ ] Guard for early exits (golden path)
- [ ] Shadow original names when unwrapping (`if let user`)
- [ ] Minimize force unwraps `!`
- [ ] Structs preferred over classes
- [ ] Use extensions for protocol conformance
- [ ] `private` over `fileprivate`
- [ ] Remove unused/template code
- [ ] async/await for modern concurrency
- [ ] `[weak self]` + `guard let self` pattern
- [ ] Delegates are `weak` references
- [ ] UI updates on main thread
- [ ] Trailing closure only for single closure

---

## Common Mistakes

**Optionals:**
- ❌ Force unwrap `optional!` → ✅ `if let` or `??`
- ❌ Magic values (-1, "") → ✅ Optional types
- ❌ Nested if lets → ✅ `guard let` (golden path)
- ❌ `if let unwrappedView` → ✅ Shadow original name

**Memory:**
- ❌ Strong closure capture → ✅ `[weak self]`
- ❌ Optional chaining lifetime → ✅ `guard let self`
- ❌ Strong delegates → ✅ `weak var delegate`

**Types:**
- ❌ Using `var` everywhere → ✅ Prefer `let`
- ❌ Using classes by default → ✅ Prefer structs
- ❌ 4-space indentation → ✅ 2-space (Kodeco)

**Organization:**
- ❌ Mixing protocol methods → ✅ Separate extensions
- ❌ `fileprivate` by default → ✅ Prefer `private`
- ❌ Template/dead code → ✅ Remove it

**Closures:**
- ❌ Trailing with multiple closures → ✅ Use labels
- ❌ Unnamed closure params → ✅ Descriptive names

**Concurrency:**
- ❌ Blocking main thread → ✅ async/await or GCD
- ❌ UI updates on background → ✅ `@MainActor` or `DispatchQueue.main`

---

## Priority Guide

**P0 - Critical:**
- Retain cycles (`[weak self]` + `guard let self`)
- Force unwrapping optionals
- UI updates not on main thread
- Using `var` for constants
- Nested if statements (use guard)

**P1 - High:**
- Using classes instead of structs
- Not handling errors properly
- Wrong indentation (use 2 spaces)
- Blocking main thread
- Protocol methods not in extensions
- Template/dead code not removed

**P2 - Medium:**
- Naming conventions
- Missing argument labels
- Not using computed properties
- `fileprivate` instead of `private`
- Optional chaining for multiple operations
- Trailing closures with multiple closures

For complete rules with detailed examples, see [swift-ios-rules.md](../swift-ios-rules.md)
