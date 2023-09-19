// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.padding
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
#else
import struct CoreGraphics.CGFloat
import struct CoreGraphics.CGRect
import struct CoreGraphics.CGSize
#endif

public struct VStack<Content> : View where Content : View {
    let alignment: HorizontalAlignment
    let spacing: CGFloat?
    let content: Content

    public init(alignment: HorizontalAlignment = .center, spacing: CGFloat? = nil, @ViewBuilder content: () -> Content) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }

    #if SKIP
    /*
     https://cs.android.com/androidx/platform/frameworks/support/+/androidx-main:compose/foundation/foundation-layout/src/commonMain/kotlin/androidx/compose/foundation/layout/Column.kt
     @Composable
     inline fun Column(
         modifier: Modifier = Modifier,
         verticalArrangement: Arrangement.Vertical = Arrangement.Top,
         horizontalAlignment: Alignment.Horizontal = Alignment.Start,
         content: @Composable ColumnScope.() -> Unit
     )
     */
    @Composable public override func ComposeContent(context: ComposeContext) {
        let columnAlignment: androidx.compose.ui.Alignment.Horizontal
        switch alignment {
        case .leading:
            columnAlignment = androidx.compose.ui.Alignment.Start
        case .trailing:
            columnAlignment = androidx.compose.ui.Alignment.End
        default:
            columnAlignment = androidx.compose.ui.Alignment.CenterHorizontally
        }
        let contentContext: ComposeContext
        let columnArrangement: Arrangement.Vertical
        if let spacing {
            contentContext = context.content()
            columnArrangement = Arrangement.spacedBy(spacing.dp)
        } else {
            var lastViewWasText: Bool? = nil
            contentContext = context.content(composer: { view, context in
                lastViewWasText = ComposeDefaultSpacedItem(view: &view, context: context, lastViewWasText: lastViewWasText)
            })
            columnArrangement = Arrangement.Center
        }
        Column(modifier: context.modifier, verticalArrangement: columnArrangement, horizontalAlignment: columnAlignment) {
            EnvironmentValues.shared.setValues {
                $0.set_fillHeight(Modifier.weight(Float(1.0)))
                $0.set_fillWidth(nil)
            } in: {
                content.Compose(context: contentContext)
            }
        }
    }

    private static let defaultSpacing = 40.0
    private static let textSpacing = 20.0

    @Composable private func ComposeDefaultSpacedItem(view: inout View, context: ComposeContext, lastViewWasText: Bool?) -> Bool {
        if let lastViewWasText {
            let spacing = lastViewWasText ? Self.textSpacing : Self.defaultSpacing
            let modifier = Modifier.padding(top: spacing.dp).then(context.modifier)
            view.ComposeContent(context: context.content(modifier: modifier))
        } else {
            view.ComposeContent(context: context)
        }
        return lastViewWasText != true
    }
    #else
    public var body: some View {
        stubView()
    }
    #endif
}

#if !SKIP

// TODO: Process for use in SkipUI

/// A vertical container that you can use in conditional layouts.
///
/// This layout container behaves like a ``VStack``, but conforms to the
/// ``Layout`` protocol so you can use it in the conditional layouts that you
/// construct with ``AnyLayout``. If you don't need a conditional layout, use
/// ``VStack`` instead.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
@frozen public struct VStackLayout : Layout {

    /// The horizontal alignment of subviews.
    public var alignment: HorizontalAlignment { get { fatalError() } }

    /// The distance between adjacent subviews.
    ///
    /// Set this value to `nil` to use default distances between subviews.
    public var spacing: CGFloat?

    /// Creates a vertical stack with the specified spacing and horizontal
    /// alignment.
    ///
    /// - Parameters:
    ///     - alignment: The guide for aligning the subviews in this stack. It
    ///       has the same horizontal screen coordinate for all subviews.
    ///     - spacing: The distance between adjacent subviews. Set this value
    ///       to `nil` to use default distances between subviews.
    @inlinable public init(alignment: HorizontalAlignment = .center, spacing: CGFloat? = nil) { }

    /// The type defining the data to animate.
    public typealias AnimatableData = EmptyAnimatableData
    public var animatableData: AnimatableData { get { fatalError() } set { } }

    /// Cached values associated with the layout instance.
    ///
    /// If you create a cache for your custom layout, you can use
    /// a type alias to define this type as your data storage type.
    /// Alternatively, you can refer to the data storage type directly in all
    /// the places where you work with the cache.
    ///
    /// See ``makeCache(subviews:)-23agy`` for more information.
    public typealias Cache = Any

    public func makeCache(subviews: Subviews) -> Cache {
        fatalError()
    }

    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) -> CGSize {
        fatalError()
    }

    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) {
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension VStackLayout : Sendable {
}

#endif
