# SkipUI

SwiftUI support for [Skip](https://skip.tools) apps.

## About 

SkipUI vends the `skip.ui` Kotlin package. It is a reimplementation of SwiftUI for Kotlin on Android using Jetpack Compose. Its goal is to mirror as much of SwiftUI as possible, allowing Skip developers to use SwiftUI with confidence.

## Dependencies

SkipUI depends on the [skip](https://source.skip.tools/skip) transpiler plugin. The transpiler must transpile SkipUI's own source code, and SkipUI relies on the transpiler's transformation of SwiftUI code. See [Implementation Strategy](#implementation-strategy) for details.

SkipUI is part of the core Skip stack and is not intended to be imported directly.
The module is transparently adopted through the translation of `import SwiftUI` into `import skip.ui.*` by the Skip transpiler.

## Status

SkipUI - together with the Skip transpiler - has robust support for the building blocks of SwiftUI, including its state flow and declarative syntax. SkipUI also implements many of SwiftUI's basic layout and control views, as well as many core modifiers. It is possible to write an Android app entirely in SwiftUI utilizing SkipUI's current component set.

SkipUI is a young library, however, and much of SwiftUI's vast surface area is not yet implemented. You are likely to run into limitations while writing real-world apps. See [Supported SwiftUI](#supported-swiftui) for a full list of supported components and constructs. Anything not listed there is likely not yet ported.

When you want to use a SwiftUI construct that has not been implemented, you have options. You can try to find a workaround using only supported components, [embed Compose code directly](#composeview), or [add support to SkipUI](#implementation-strategy). If you choose to enhance SkipUI itself, please consider [contributing](#contributing) your code back for inclusion in the official release.

## Contributing

We welcome contributions to SkipUI. The Skip product documentation includes helpful instructions on [local Skip library development](https://skip.tools/docs/#local-libraries). 

The most pressing need is to implement more core components and view modifiers.
To help fill in unimplemented API in SkipUI:

1. Find unimplemented API. Unimplemented API will either be within `#if !SKIP` blocks, or will be marked with `@available(unavailable, *)`.
1. Write an appropriate Compose implementation. See [Implementation Strategy](#implementation-strategy) below.
1. Write tests and/or playground code to exercise your component. See [Tests](#tests).
1. [Submit a PR.](https://github.com/skiptools/skip-ui/pulls)

Other forms of contributions such as test cases, comments, and documentation are also welcome!

## Implementation Strategy

### Code Transformations

SkipUI does not work in isolation. It depends on transformations the [skip](https://source.skip.tools/skip) transpiler plugin makes to SwiftUI code. And while Skip generally strives to write Kotlin that is similar to hand-crafted code, these SwiftUI transformations are not something you'd want to write yourself. Before discussing SkipUI's implementation, let's explore them.

Both SwiftUI and Compose are declarative UI frameworks. Both have mechanisms to track state and automatically re-render when state changes. SwiftUI models user interface elements with `View` objects, however, while Compose models them with `@Composable` functions. The Skip transpiler must therefore translate your code defining a `View` graph into `@Composable` function calls. This involves two primary transformations:

1. The transpiler inserts code to sync `View` members that have special meanings in SwiftUI - `@State`, `@EnvironmentObject`, etc - with the corresponding Compose state mechanisms, which are not member-based. The syncing goes two ways, so that your `View` members are populated from Compose's state values, and changing your `View` members updates Compose's state values. 
1. The transpiler turns `@ViewBuilders` - including `View.body` - into `@Composable` function calls.

The second transformation in particular deserves some explanation, because it may help you to understand SkipUI's internal API. Consider the following simple example:

```swift
struct V: View {
    let isHello: Bool

    var body: some View {
        if isHello {
            Text("Hello!")
        } else {
            Text("Goodbye!")
        }
    }
}
```

The transpilation would look something like the following:

```swift
class V: View {
    val isHello: Bool

    constructor(isHello: Bool) {
        this.isHello = isHello
    }

    override fun body(): View {
        return ComposeView { composectx: ComposeContext in 
            if (isHello) {
                Text("Hello!").Compose(context: composectx)
            } else {
                Text("Goodbye!").Compose(context: composectx)
            }
        }
    }

    ...
}
```

Notice the changes to the `body` content. Rather than returning an arbitrary view tree, the transpiled `body` always returns a single `ComposeView`, a special SkipUI view type that invokes a `@Composable` block. The logic of the original `body` is now within that block, and any `View` that `body` would have returned instead invokes its own `Compose(context:)` function to render the corresponding Compose component. The `Compose(context:)` function is part of SkipUI's `View` API.

Thus the transpiler is able to turn any `View.body` - actually any `@ViewBuilder` - into a block of Compose code that it can invoke to render the desired content. A [later section](#composeview) details how you can use `ComposeView` yourself to move fluidly between SwiftUI and Compose when writing your Android UI. 

### Implementation Phases

SkipUI contains stubs for the entire SwiftUI framework. API generally goes through three phases:

1. Code that no one has begun to port to Skip starts in `#if !SKIP` blocks. This hides it from the Skip transpiler.
1. The first implementation step is to move code out of `#if !SKIP` blocks so that it will be transpiled. This is helpful on its own, even if you just mark the API `@available(unavailable, *)` because you are not ready to implement it for Compose. An `unavailable` attribute will provide Skip users with a clear error message, rather than relying on the Kotlin compiler to complain about unfound API.
    - When moving code out of a `#if !SKIP` block, please strip Apple's extensive API comments. There is no reason for Skip to duplicate the official SwiftUI documentation, and it obscures any Skip-specific implementation comments we may add.
    - SwiftUI uses complex generics extensively, and the generics systems of Swift and Kotlin have significant differences. You may have to replace some generics or generic constraints with looser typing in order to transpile successfully.
    - Reducing the number of Swift extensions and instead folding API into the primary declaration of a type can make Skip's internal symbol storage more efficient. This includes moving general modifier implementations from `ViewExtensions.swift` to `View.swift`. If a modifier is specific to a component - e.g. `.navigationTitle` is specific to `NavigationStack` - then use a `View` extension within the component's source file.
1. Finally, we add a Compose implementation and remove any `unavailable` attribute.

Note that SkipUI should remain buildable throughout this process. Being able to successfully compile SkipUI in Xcode helps us validate that our ported components still mesh with the rest of the framework.

### Components

Before implementing a component, familiarize yourself with SkipUI's `View` protocol in `Sources/View/View.swift` as well as the files in the `Sources/Compose` directory. It is also helpful to browse the source code for components and modifiers that have already been ported. See the table of [Supported SwiftUI](#supported-swiftui).

The `Text` view exemplifies a typical SwiftUI component implementation. Here is an abbreviated code sample:

```swift
public struct Text: View, Equatable, Sendable {
    let text: String

    public init(_ text: String) {
        self.text = text
    }

    ...

    #if SKIP
    @Composable public override func ComposeContent(context: ComposeContext) {
        let modifier = context.modifier
        let font = EnvironmentValues.shared.font ?? Font(fontImpl: { LocalTextStyle.current })
        ...
        androidx.compose.material3.Text(text: text, modifier: modifier, style: font.fontImpl(), ...)
    }
    #else
    public var body: some View {
        stubView()
    }
    #endif
}

```

As you can see, the `Text` type is defined just as it is in SwiftUI. We then use an `#if SKIP` block to implement the composable `View.ComposeContent` function for Android, while we stub the `body` var to satisfy the Swift compiler. `ComposeContent` makes the necessary Compose calls to render the component, applying the modifier from the given `context` as well as any applicable environment values. If `Text` had any child views, `ComposeContent` would call `child.Compose(context: context.content())` to compose its child content. (Note that `View.Compose(context:)` delegates to `View.ComposeContent(context:)` after performing other bookkeeping operations, which is why we override `ComposeContent` rather than `Compose`.)

### Modifiers

Most modifiers, on the other hand, use the `ComposeModifierView` to change the `context` passed to the modified view. Here is the `.opacity` modifier:

```swift
extension View {
    public func opacity(_ opacity: Double) -> some View {
        #if SKIP
        return ComposeModifierView(contextView: self) { context in
            context.modifier = context.modifier.alpha(Float(opacity))
        }
        #else
        return self
        #endif
    }
}
```

Some modifiers have their own composition logic. These modifiers use a different `ComposeModifierView` constructor whose block defines the composition. Here, for example, `.task` uses Compose's `LaunchedEffect` to run an asynchronous block the first time it is composed:

```swift
extension View {
    public func task(id value: Any, priority: TaskPriority = .userInitiated, _ action: @escaping () async -> Void) -> some View {
        #if SKIP
        return ComposeModifierView(contentView: self) { view, context in
            let handler = rememberUpdatedState(action)
            LaunchedEffect(value) {
                handler.value()
            }
            view.Compose(context: context)
        }
        #else
        return self
        #endif
    }
}
```

Like other SwiftUI components, modifiers use `#if SKIP ... #else ...` to stub the Swift implementation and keep SkipUI buildable in Xcode.

## Topics

### ComposeView

`ComposeView` is an Android-only SwiftUI view that you can use to embed Compose code directly into your SwiftUI view tree. In the following example, we use a SwiftUI `Text` to write "Hello from SwiftUI", followed by calling the `androidx.compose.material3.Text()` Compose function to write "Hello from Compose" below it:

```swift
VStack {
    Text("Hello from SwiftUI")
    ComposeView { _ in
        androidx.compose.material3.Text("Hello from Compose")
    }
}
```

Skip also enhances all SwiftUI views with a `Compose()` method, allowing you to use SwiftUI views from within Compose. The following example again uses a SwiftUI `Text` to write "Hello from SwiftUI", but this time from within a `ComposeView`:

```swift
ComposeView { context in 
    androidx.compose.foundation.layout.Column {
        Text("Hello from SwiftUI").Compose(context: context.content())
        androidx.compose.material3.Text("Hello from Compose")
    }
}
```

Or:

```swift
ComposeView { context in 
    VStack {
        Text("Hello from SwiftUI").Compose(context: context.content())
        androidx.compose.material3.Text("Hello from Compose")
    }.Compose(context: context.content())
}
```

With `ComposeView` and the `Compose()` function, you can move fluidly between SwiftUI and Compose code. These techniques work not only with standard SwiftUI and Compose components, but with your own custom SwiftUI views and Compose functions as well.

Note that `ComposeView` and the `Compose()` function are only available in Android, so you must guard all uses with the `#if SKIP` or `#if os(Android)` compiler directives. 

### Images

SkipUI currently only supports the `Image(systemName:)` constructor. The table below details the mapping between iOS and Android system images. Other system names are not supported. Loading images from resources and URLs is also not yet supported. These restrictions also apply to other components that load images, such as `SwiftUI.Label`.

In addition to the system images below, you can display any emoji using `Text`. 

If these options do not meet your needs, consider [embedding Compose code](#composeview) directly until resource and URL loading is implemented.

| iOS | Android |   |
|---|-------|---|
| person.crop.square | Icons.Outlined.AccountBox | 􀉹 |
| person.crop.circle | Icons.Outlined.AccountCircle | 􀉭 |
| plus.circle.fill | Icons.Outlined.AddCircle | 􀁍 |
| plus | Icons.Outlined.Add | 􀅼 |
| arrow.left | Icons.Outlined.ArrowBack | 􀄪 |
| arrowtriangle.down.fill | Icons.Outlined.ArrowDropDown | 􀄥 |
| arrow.forward | Icons.Outlined.ArrowForward | 􀰑 |
| wrench | Icons.Outlined.Build | 􀎕 |
| phone | Icons.Outlined.Call | 􀌾 |
| checkmark.circle | Icons.Outlined.CheckCircle | 􀁢 |
| checkmark | Icons.Outlined.Check | 􀆅 |
| xmark | Icons.Outlined.Clear | 􀆄 |
| pencil | Icons.Outlined.Create | 􀈊 |
| calendar | Icons.Outlined.DateRange | 􀉉 |
| trash | Icons.Outlined.Delete | 􀈑 |
| envelope | Icons.Outlined.Email | 􀍕 |
| arrow.forward.square | Icons.Outlined.ExitToApp | 􀰔 |
| face.smiling | Icons.Outlined.Face | 􀎸 |
| heart | Icons.Outlined.FavoriteBorder | 􀊴 |
| heart.fill | Icons.Outlined.Favorite | 􀊵 |
| house | Icons.Outlined.Home | 􀎞 |
| info.circle | Icons.Outlined.Info | 􀅴 |
| chevron.down | Icons.Outlined.KeyboardArrowDown | 􀆈 |
| chevron.left | Icons.Outlined.KeyboardArrowLeft | 􀆉 |
| chevron.right | Icons.Outlined.KeyboardArrowRight | 􀆊 |
| chevron.up | Icons.Outlined.KeyboardArrowUp | 􀆇 |
| list.bullet | Icons.Outlined.List | 􀋲 |
| location | Icons.Outlined.LocationOn | 􀋑 |
| lock | Icons.Outlined.Lock | 􀎠 |
| line.3.horizontal | Icons.Outlined.Menu | 􀌇 |
| ellipsis | Icons.Outlined.MoreVert | 􀍠 |
| bell | Icons.Outlined.Notifications | 􀋙 |
| person | Icons.Outlined.Person | 􀉩 |
| mappin.circle | Icons.Outlined.Place | 􀎪 |
| play | Icons.Outlined.PlayArrow | 􀊃 |
| arrow.clockwise.circle | Icons.Outlined.Refresh | 􀚁 |
| magnifyingglass | Icons.Outlined.Search | 􀊫 |
| paperplane | Icons.Outlined.Send | 􀈟 |
| gearshape | Icons.Outlined.Settings | 􀣋 |
| square.and.arrow.up | Icons.Outlined.Share | 􀈂 |
| cart | Icons.Outlined.ShoppingCart | 􀍩 |
| star | Icons.Outlined.Star | 􀋃 |
| hand.thumbsup | Icons.Outlined.ThumbUp | 􀉿 |
| exclamationmark.triangle | Icons.Outlined.Warning | 􀇿 |
| person.crop.square.fill | Icons.Filled.AccountBox | 􀉺 |
| person.crop.circle.fill | Icons.Filled.AccountCircle | 􀉮 |
| wrench.fill | Icons.Filled.Build | 􀎖 |
| phone.fill | Icons.Filled.Call | 􀌿 |
| checkmark.circle.fill | Icons.Filled.CheckCircle | 􀁣 |
| trash.fill | Icons.Filled.Delete | 􀈒 |
| envelope.fill | Icons.Filled.Email | 􀍖 |
| house.fill | Icons.Filled.Home | 􀎟 |
| info.circle.fill | Icons.Filled.Info | 􀅵 |
| location.fill | Icons.Filled.LocationOn | 􀋒 |
| lock.fill | Icons.Filled.Lock | 􀎡 |
| bell.fill | Icons.Filled.Notifications | 􀋚 |
| person.fill | Icons.Filled.Person | 􀉪 |
| mappin.circle.fill | Icons.Filled.Place | 􀜈 |
| play.fill | Icons.Filled.PlayArrow | 􀊄 |
| paperplane.fill | Icons.Filled.Send | 􀈠 |
| gearshape.fill | Icons.Filled.Settings | 􀣌 |
| square.and.arrow.up.fill | Icons.Filled.Share | 􀈃 |
| cart.fill | Icons.Filled.ShoppingCart | 􀍪 |
| star.fill | Icons.Filled.Star | 􀋃 |
| hand.thumbsup.fill | Icons.Filled.ThumbUp | 􀊀 |
| exclamationmark.triangle.fill | Icons.Filled.Warning | 􀇿 |

In Android-only code, you can also supply any `androidx.compose.material.icons.Icons` image name as the `systemName`. For example:

```swift
#if SKIP
Image(systemName: "Icons.Filled.Settings")
#endif
```

### Lists

SwiftUI `Lists` are powerful and flexible components. SkipUI currently supports the following patterns for specifying `List` content.

Static content. Embed a child view for each row directly within the `List`:

```swift
List {
    Text("Row 1")
    Text("Row 2")
    Text("Row 3")
}
```

Indexed content. Specify an `Int` range and a closure to create a row for each index:

```swift
List(1...100) { index in 
    Text("Row \(index)")
}
```

Collection content. Supply any `RandomAccessCollection` - typically an `Array` - and a closure to create a row for each element. If the elements do not implement the `Identifiable` protocol, specify the key path to a property that can be used to uniquely identify each element:

```swift
List([person1, person2, person3], id: \.fullName) { person in
    HStack {
        Text(person.fullName)
        Spacer()
        Text(person.age)
    } 
}
```

Note in particular that `ForEach` is not yet supported.

### Navigation

Documentation in progress

## Tests

SkipUI utilizes a combination of unit tests, UI tests, and basic snapshot tests in which the snapshots are converted into ASCII art for easy processing. 

Perhaps the most common way to test SkipUI's support for a SwiftUI component, however, is through the [Skip playground app](https://github.com/skiptools/skipapp-playground). Whenever you add or update support for a visible element of SwiftUI, make sure there is a playground that exercises the element. This not only gives us a mechanism to test appearance and behavior, but the playground app becomes a showcase of supported SwiftUI components on Android over time.

## Supported SwiftUI

|Component|Support Level|Notes|
|---------|-------------|-----|
|`@AppStorage`|Medium||
|`@Bindable`|Full||
|`@Binding`|Full||
|`@Environment`|Full|Custom keys supported, but most builtin keys not yet available|
|`@EnvironmentObject`|Full||
|`@ObservedObject`|Full||
|`@State`|Full||
|`@StateObject`|Full||
|Custom Views|Full||
|`Button`|High||
|`Color`|High||
|`Divider`|Full||
|`EmptyView`|Full||
|`Font`|Medium||
|`Group`|Full||
|`HStack`|Full||
|`Image`|Low|See [Images](#images)|
|`Label`|Low|See [Images](#images)|
|`List`|Medium|See [Lists](#lists)|
|`NavigationLink`|Medium|See [Navigation](#navigation)|
|`NavigationStack`|Medium|See [Navigation](#navigation)|
|`ScrollView`|Full||
|`Slider`|Medium|Labels, `onEditingChanged` not supported|
|`Spacer`|Medium|`minLength` not supported|
|`TabView`|Medium|See [Navigation](#navigation)|
|`Text`|High|Formatting not supported|
|`TextField`|High|Formatting not supported|
|`Toggle`|Medium|Styling, `sources` not supported|
|`VStack`|Full||
|`ZStack`|Full||
|`.background`|Low|Only color supported|
|`.bold`|Full||
|`.border`|Full||
|`.buttonStyle`|High|Custom styles not supported|
|`.environment`|Full||
|`.environmentObject`|Full||
|`.font`|Full||
|`.foregroundColor`|Full||
|`.foregroundStyle`|Medium|Only color supported|
|`.frame`|Low|Only fixed dimensions supported|
|`.italic`|Full||
|`.labelsHidden`|Full||
|`.listStyle`|Full||
|`.navigationDestination`|Medium|See [Navigation](#navigation)|
|`.navigationTitle`|Full||
|`.opacity`|Full||
|`.padding`|Full||
|`.rotationEffect`|Medium||
|`.scaleEffect`|Medium||
|`.tabItem`|Full||
|`.task`|Full||

## Helpful Compose components

[androidx.compose.material package](https://developer.android.com/reference/kotlin/androidx/compose/material3/package-summary)
[androidx.compose.ui.Modifier list](https://developer.android.com/jetpack/compose/modifiers-list)

- Text (androidx.compose.material3.Text): Displays a text element on the screen.
- Button (androidx.compose.material3.Button): Creates a clickable button.
- Surface (androidx.compose.material3.Surface): Defines a surface with a background color and elevation.
- Image (androidx.compose.foundation.Image): Displays an image.
- Box (androidx.compose.foundation.Box): A composable that places its children in a box layout.
- Row (androidx.compose.foundation.layout.Row): Lays out its children in a horizontal row.
- Column (androidx.compose.foundation.layout.Column): Lays out its children in a vertical column.
- Spacer (androidx.compose.ui.layout.Spacer): Adds empty space between composables.
- Card (androidx.compose.material3.Card): Creates a Material Design card.
- TextField (androidx.compose.material3.TextField): Creates an editable text field.
- TopAppBar (androidx.compose.material3.TopAppBar): Creates a Material Design top app bar.
- BottomAppBar (androidx.compose.material3.BottomAppBar): Creates a Material Design bottom app bar.
- FloatingActionButton (androidx.compose.material3.FloatingActionButton): Creates a floating action button.
- AlertDialog (androidx.compose.material3.AlertDialog): Creates a Material Design alert dialog.
- ModalBottomSheetLayout (androidx.compose.material3.ModalBottomSheetLayout): Creates a modal bottom sheet.
- IconButton (androidx.compose.material3.IconButton): Creates an icon button.
- OutlinedTextField (androidx.compose.material3.OutlinedTextField): Creates an outlined text field.
- LazyColumn (androidx.compose.foundation.lazy.LazyColumn): Creates a lazily laid out column.
- LazyRow (androidx.compose.foundation.lazy.LazyRow): Creates a lazily laid out row.
- LazyVerticalGrid (androidx.compose.foundation.lazy.LazyVerticalGrid): Creates a lazily laid out vertical grid.
- LazyRow (androidx.compose.foundation.lazy.LazyRow): Creates a lazily laid out row with horizontally scrolling items.
- LazyColumnFor (androidx.compose.foundation.lazy.LazyColumnFor): Creates a lazily laid out column for a list of items.
- LazyRowFor (androidx.compose.foundation.lazy.LazyRowFor): Creates a lazily laid out row for a list of items.
- LazyVerticalGridFor (androidx.compose.foundation.lazy.LazyVerticalGridFor): Creates a lazily laid out vertical grid for a list of items.
- Clickable (androidx.compose.ui.Modifier.clickable): Adds a click listener to a composable.
- Icon (androidx.compose.material3.Icon): Displays an icon from the Material Icons font.
- IconButton (androidx.compose.material3.IconButton): Creates an icon button with optional click listener.
- Checkbox (androidx.compose.material3.Checkbox): Creates a checkbox.
- RadioButton (androidx.compose.material3.RadioButton): Creates a radio button.
- Switch (androidx.compose.material3.Switch): Creates a switch (on/off toggle).
- Slider (androidx.compose.material3.Slider): Creates a slider for selecting a value within a range.
- LinearProgressIndicator (androidx.compose.material3.LinearProgressIndicator): Creates a linear progress indicator.
- CircularProgressIndicator (androidx.compose.material3.CircularProgressIndicator): Creates a circular progress indicator.
- Divider (androidx.compose.material3.Divider): Creates a horizontal divider.
- Spacer (androidx.compose.foundation.layout.Spacer): Adds empty space between composables.
- AlertDialog (androidx.compose.material3.AlertDialog): Creates an alert dialog with customizable buttons and content.
- Snackbar (androidx.compose.material3.SnackbarHost): Creates a snackbar to display short messages.
- DropdownMenu (androidx.compose.material3.DropdownMenu): Creates a dropdown menu with a list of items.
- Drawer (androidx.compose.material3.Drawer): Creates a sliding drawer panel for navigation.
- MaterialTheme (androidx.compose.material3.MaterialTheme): Applies Material Design styles to its children.
