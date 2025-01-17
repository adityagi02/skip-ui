// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP
import androidx.compose.runtime.Composable
import androidx.compose.runtime.saveable.Saver
import androidx.compose.ui.Modifier

/// Context to provide modifiers, parent, etc to composables.
public struct ComposeContext {
    /// Modifiers to apply.
    public var modifier: Modifier = Modifier

    /// Mechanism for a parent view to change how a child view is composed.
    public var composer: Composer?

    /// Use in conjunction with `rememberSaveable` to store view state.
    public var stateSaver: Saver<Any?, Any> = ComposeStateSaver()

    /// The context to pass to child content of a container view.
    ///
    /// By default, modifiers and the `composer` are reset for child content.
    public func content(modifier: Modifier = Modifier, composer: Composer? = nil, stateSaver: Saver<Any?, Any>? = nil) -> ComposeContext {
        var context = self
        context.modifier = modifier
        context.composer = composer
        context.stateSaver = stateSaver ?? self.stateSaver
        return context
    }
}

/// The result of composing content.
///
/// Reserved for future use. Having a return value also expands recomposition scope. See `ComposeView` for details.
public struct ComposeResult {
    public static let ok = ComposeResult()
}

/// Mechanism for a parent view to change how a child view is composed.
public protocol Composer {
    /// Called before a `ComposeView` composes its content.
    public func willCompose()

    /// Called after a `ComposeView` composes its content.
    public func didCompose(result: ComposeResult)

    /// Compose the given view.
    ///
    /// - Parameter context: The context to use to render the view, optionally retaining this composer.
    @Composable public func Compose(view: View, context: (Bool) -> ComposeContext)
}

extension Composer {
    public func willCompose() {
    }

    public func didCompose(result: ComposeResult) {
    }
}

/// Builtin composer that executes a closure to compose.
///
/// - Warning: Child composables may recompose at any time. Be careful with relying on block capture.
struct ClosureComposer: Composer {
    private let compose: @Composable (View, (Bool) -> ComposeContext) -> Void

    init(compose: @Composable (View, (Bool) -> ComposeContext) -> Void) {
        self.compose = compose
    }

    @Composable override func Compose(view: View, context: (Bool) -> ComposeContext) {
        compose(view, context)
    }
}

#endif
