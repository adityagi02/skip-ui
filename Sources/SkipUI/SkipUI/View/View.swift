// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org

#if SKIP
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.rememberUpdatedState
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clipToBounds
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.draw.scale
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.dp
#else
import struct CoreGraphics.CGAffineTransform
import struct CoreGraphics.CGFloat
import struct CoreGraphics.CGPoint
import struct CoreGraphics.CGSize
import struct Foundation.URL
#endif

public protocol View {
    #if SKIP
    // SKIP DECLARE: fun body(): View = EmptyView()
    @ViewBuilder @MainActor var body: any View { get }
    #else
    associatedtype Body : View
    @ViewBuilder @MainActor var body: Body { get }
    #endif
}

#if SKIP
extension View {
    /// Compose this view without an existing context - typically called when integrating a SwiftUI view tree into pure Compose.
    @Composable public func Compose() -> ComposeResult {
        return Compose(context: ComposeContext())
    }

    /// Calls to `Compose` are added by the transpiler.
    @Composable public func Compose(context: ComposeContext) -> ComposeResult {
        if let composer = context.composer {
            composer.Compose(view: self, context: { retain in
                guard !retain else {
                    return context
                }
                var context = context
                context.composer = nil
                return context
            })
        } else {
            ComposeContent(context: context)
        }
        return .ok
    }

    /// Compose this view's content.
    @Composable public func ComposeContent(context: ComposeContext) -> Void {
        body.ComposeContent(context)
    }

    /// Strip modifier views.
    ///
    /// - Parameter until: Return `true` to stop stripping at a modifier with a given role.
    public func strippingModifiers<R>(until: (ComposeModifierRole) -> Bool = { _ in false }, perform: (any View?) -> R) -> R {
        return perform(self)
    }
}
#endif

extension View {
    @available(*, unavailable)
    public func allowsHitTesting(_ enabled: Bool) -> some View {
        return self
    }

    public func aspectRatio(_ ratio: CGFloat? = nil, contentMode: ContentMode) -> some View {
        #if SKIP
        return environment(\._aspectRatio, (ratio, contentMode))
        #else
        return self
        #endif
    }

    public func aspectRatio(_ size: CGSize, contentMode: ContentMode) -> some View {
        return aspectRatio(size.width / size.height, contentMode: contentMode)
    }

    public func background(_ color: Color) -> some View {
        #if SKIP
        return ComposeModifierView(contextView: self) {
            $0.modifier = $0.modifier.background(color.colorImpl())
        }
        #else
        return self
        #endif
    }

    @available(*, unavailable)
    public func background<V>(alignment: Alignment = .center, @ViewBuilder content: () -> any View) -> some View {
        return self
    }

    @available(*, unavailable)
    public func background(ignoresSafeAreaEdges edges: Edge.Set = .all) -> some View {
        return self
    }

    @available(*, unavailable)
    public func background(_ style: any ShapeStyle, ignoresSafeAreaEdges edges: Edge.Set = .all) -> some View {
        return self
    }

    @available(*, unavailable)
    public func background<S>(in shape: any Shape, fillStyle: FillStyle = FillStyle()) -> some View {
        return self
    }

    @available(*, unavailable)
    public func background(_ style: any ShapeStyle, in shape: any Shape, fillStyle: FillStyle = FillStyle()) -> some View {
        return self
    }

    @available(*, unavailable)
    public func backgroundStyle(_ style: any ShapeStyle) -> some View {
        return self
    }

    @available(*, unavailable)
    public func badge(_ count: Int) -> some View {
        return self
    }

    @available(*, unavailable)
    public func badge(_ label: Text?) -> some View {
        return self
    }

    @available(*, unavailable)
    public func badge(_ key: LocalizedStringKey) -> some View {
        return self
    }

    @available(*, unavailable)
    public func badge(_ label: String) -> some View {
        return self
    }

    @available(*, unavailable)
    public func badgeProminence(_ prominence: BadgeProminence) -> some View {
        return self
    }

    @available(*, unavailable)
    public func blendMode(_ blendMode: BlendMode) -> some View {
        return self
    }

    @available(*, unavailable)
    public func blur(radius: CGFloat, opaque: Bool = false) -> some View {
        return self
    }

    public func border(_ color: Color, width: CGFloat = 1.0) -> some View {
        #if SKIP
        return ComposeModifierView(contextView: self) {
            $0.modifier = $0.modifier.border(width: width.dp, color: color.colorImpl())
        }
        #else
        return self
        #endif
    }

    @available(*, unavailable)
    public func border(_ style: any ShapeStyle, width: CGFloat = 1.0) -> some View {
        return self
    }

    @available(*, unavailable)
    public func brightness(_ amount: Double) -> some View {
        return self
    }

    @available(*, unavailable)
    public func clipShape(_ shape: any Shape, style: FillStyle = FillStyle()) -> some View {
        return self
    }

    public func clipped(antialiased: Bool = false) -> some View {
        #if SKIP
        return ComposeModifierView(contextView: self) {
            $0.modifier = $0.modifier.clipToBounds()
        }
        #else
        return self
        #endif
    }

    @available(*, unavailable)
    public func colorInvert() -> some View {
        return self
    }

    @available(*, unavailable)
    public func colorMultiply(_ color: Color) -> some View {
        return self
    }

    @available(*, unavailable)
    public func compositingGroup() -> some View {
        return self
    }

    @available(*, unavailable)
    public func confirmationDialog(_ titleKey: LocalizedStringKey, isPresented: Binding<Bool>, titleVisibility: Visibility = .automatic, @ViewBuilder actions: () -> any View) -> some View {
        return self
    }

    @available(*, unavailable)
    public func confirmationDialog(_ title: String, isPresented: Binding<Bool>, titleVisibility: Visibility = .automatic, @ViewBuilder actions: () -> any View) -> some View {
        return self
    }

    @available(*, unavailable)
    public func confirmationDialog(_ title: Text, isPresented: Binding<Bool>, titleVisibility: Visibility = .automatic, @ViewBuilder actions: () -> any View) -> some View {
        return self
    }

    @available(*, unavailable)
    public func confirmationDialog(_ titleKey: LocalizedStringKey, isPresented: Binding<Bool>, titleVisibility: Visibility = .automatic, @ViewBuilder actions: () -> any View, @ViewBuilder message: () -> any View) -> some View {
        return self
    }

    @available(*, unavailable)
    public func confirmationDialog(_ title: String, isPresented: Binding<Bool>, titleVisibility: Visibility = .automatic, @ViewBuilder actions: () -> any View, @ViewBuilder message: () -> any View) -> some View {
        return self
    }

    @available(*, unavailable)
    public func confirmationDialog(_ title: Text, isPresented: Binding<Bool>, titleVisibility: Visibility = .automatic, @ViewBuilder actions: () -> any View, @ViewBuilder message: () -> any View) -> some View {
        return self
    }

    @available(*, unavailable)
    public func confirmationDialog<T>(_ titleKey: LocalizedStringKey, isPresented: Binding<Bool>, titleVisibility: Visibility = .automatic, presenting data: T?, @ViewBuilder actions: (T) -> any View) -> some View {
        return self
    }

    @available(*, unavailable)
    public func confirmationDialog<T>(_ title: String, isPresented: Binding<Bool>, titleVisibility: Visibility = .automatic, presenting data: T?, @ViewBuilder actions: (T) -> any View) -> some View {
        return self
    }

    @available(*, unavailable)
    public func confirmationDialog<T>(_ title: Text, isPresented: Binding<Bool>, titleVisibility: Visibility = .automatic, presenting data: T?, @ViewBuilder actions: (T) -> any View) -> some View {
        return self
    }

    @available(*, unavailable)
    public func confirmationDialog<T>(_ titleKey: LocalizedStringKey, isPresented: Binding<Bool>, titleVisibility: Visibility = .automatic, presenting data: T?, @ViewBuilder actions: (T) -> any View, @ViewBuilder message: (T) -> any View) -> some View {
        return self
    }

    @available(*, unavailable)
    public func confirmationDialog<T>(_ title: String, isPresented: Binding<Bool>, titleVisibility: Visibility = .automatic, presenting data: T?, @ViewBuilder actions: (T) -> any View, @ViewBuilder message: (T) -> any View) -> some View {
        return self
    }

    @available(*, unavailable)
    public func confirmationDialog<T>(_ title: Text, isPresented: Binding<Bool>, titleVisibility: Visibility = .automatic, presenting data: T?, @ViewBuilder actions: (T) -> any View, @ViewBuilder message: (T) -> any View) -> some View {
        return self
    }

    @available(*, unavailable)
    public func containerBackground(_ style: any ShapeStyle, for container: ContainerBackgroundPlacement) -> some View {
        return self
    }

    @available(*, unavailable)
    public func containerBackground(for container: ContainerBackgroundPlacement, alignment: Alignment = .center, @ViewBuilder content: () -> any View) -> some View {
        return self
    }

    @available(*, unavailable)
    public func containerRelativeFrame(_ axes: Axis.Set, alignment: Alignment = .center) -> some View {
        return self
    }

    @available(*, unavailable)
    public func containerRelativeFrame(_ axes: Axis.Set, count: Int, span: Int = 1, spacing: CGFloat, alignment: Alignment = .center) -> some View {
        return self
    }

    @available(*, unavailable)
    public func containerRelativeFrame(_ axes: Axis.Set, alignment: Alignment = .center, _ length: @escaping (CGFloat, Axis) -> CGFloat) -> some View {
        return self
    }

    @available(*, unavailable)
    public func containerShape<T>(_ shape: any Shape) -> some View {
        return self
    }

    @available(*, unavailable)
    public func contentShape(_ shape: any Shape, eoFill: Bool = false) -> some View {
        return self
    }

    @available(*, unavailable)
    public func contentShape(_ kind: ContentShapeKinds, _ shape: any Shape, eoFill: Bool = false) -> some View {
        return self
    }

    @available(*, unavailable)
    public func contextMenu(@ViewBuilder menuItems: () -> any View) -> some View {
        return self
    }

    @available(*, unavailable)
    public func contextMenu(@ViewBuilder menuItems: () -> any View, @ViewBuilder preview: () -> any View) -> some View {
        return self
    }

    @available(*, unavailable)
    public func contextMenu<I>(forSelectionType itemType: Any.Type? = nil, @ViewBuilder menu: @escaping (Set<I>) -> any View, primaryAction: ((Set<I>) -> Void)? = nil) -> some View where I: Hashable {
        return self
    }

    @available(*, unavailable)
    public func contrast(_ amount: Double) -> some View {
        return self
    }

    @available(*, unavailable)
    public func controlSize(_ controlSize: ControlSize) -> some View {
        return self
    }

    @available(*, unavailable)
    public func coordinateSpace(_ name: NamedCoordinateSpace) -> some View {
        return self
    }

    @available(*, unavailable)
    public func defaultHoverEffect(_ effect: HoverEffect?) -> some View {
        return self
    }

    @available(*, unavailable)
    public func defersSystemGestures(on edges: Edge.Set) -> some View {
        return self
    }

    @available(*, unavailable)
    public func dialogSuppressionToggle(_ titleKey: LocalizedStringKey, isSuppressed: Binding<Bool>) -> some View {
        return self
    }

    @available(*, unavailable)
    public func dialogSuppression(_ title: String, isSuppressed: Binding<Bool>) -> some View {
        return self
    }

    @available(*, unavailable)
    public func dialogSuppressionToggle(_ label: Text, isSuppressed: Binding<Bool>) -> some View {
        return self
    }

    @available(*, unavailable)
    public func dialogSuppressionToggle(isSuppressed: Binding<Bool>) -> some View {
        return self
    }

    
    public func disabled(_ disabled: Bool) -> some View {
        #if SKIP
        return environment(\.isEnabled, !disabled)
        #else
        return self
        #endif
    }

    @available(*, unavailable)
    public func drawingGroup(opaque: Bool = false, colorMode: ColorRenderingMode = .nonLinear) -> some View {
        return self
    }

    public func equatable() -> some View {
        return EquatableView(content: self)
    }

    @available(*, unavailable)
    public func fileMover(isPresented: Binding<Bool>, file: URL?, onCompletion: @escaping (_ result: Result<URL, Error>) -> Void) -> some View {
        return self
    }

    @available(*, unavailable)
    public func fileMover(isPresented: Binding<Bool>, files: any Collection<URL>, onCompletion: @escaping (_ result: Result<[URL], Error>) -> Void) -> some View {
        return self
    }

    @available(*, unavailable)
    public func fileMover(isPresented: Binding<Bool>, file: URL?, onCompletion: @escaping (Result<URL, Error>) -> Void, onCancellation: @escaping () -> Void) -> some View {
        return self
    }

    @available(*, unavailable)
    public func fileMover(isPresented: Binding<Bool>, files: any Collection<URL>, onCompletion: @escaping (Result<[URL], Error>) -> Void, onCancellation: @escaping () -> Void) -> some View {
        return self
    }

    @available(*, unavailable)
    public func fixedSize(horizontal: Bool, vertical: Bool) -> some View {
        return self
    }

    @available(*, unavailable)
    public func fixedSize() -> some View {
        return self
    }

    @available(*, unavailable)
    public func flipsForRightToLeftLayoutDirection(_ enabled: Bool) -> some View {
        return self
    }

    public func foregroundColor(_ color: Color?) -> some View {
        #if SKIP
        return environment(\._color, color)
        #else
        return self
        #endif
    }

    public func foregroundStyle(_ color: Color) -> some View {
        return foregroundColor(color)
    }

    @available(*, unavailable)
    public func foregroundStyle(_ style: any ShapeStyle) -> some View {
        return self
    }

    @available(*, unavailable)
    public func foregroundStyle(_ primary:  any ShapeStyle, _ secondary:  any ShapeStyle) -> some View {
        return self
    }

    @available(*, unavailable)
    public func foregroundStyle(_ primary:  any ShapeStyle, _ secondary:  any ShapeStyle, _ tertiary:  any ShapeStyle) -> some View {
        return self
    }

    public func frame(width: CGFloat? = nil, height: CGFloat? = nil) -> some View {
        #if SKIP
        return ComposeModifierView(contentView: self) { view, context in
            var context = context
            if let width {
                context.modifier = context.modifier.width(width.dp)
            }
            if let height {
                context.modifier = context.modifier.height(height.dp)
            }
            EnvironmentValues.shared.setValues {
                if width != nil {
                    $0.set_fillWidth(nil)
                    $0.set_fillWidthModifier(nil)
                }
                if height != nil {
                    $0.set_fillHeight(nil)
                    $0.set_fillHeightModifier(nil)
                }
            } in: {
                view.ComposeContent(context: context)
            }
        }
        #else
        return self
        #endif
    }

    @available(*, unavailable)
    public func frame(width: CGFloat? = nil, height: CGFloat? = nil, alignment: Alignment) -> some View {
        return frame(width: width, height: height)
    }

    @available(*, unavailable)
    public func frame(minWidth: CGFloat? = nil, idealWidth: CGFloat? = nil, maxWidth: CGFloat? = nil, minHeight: CGFloat? = nil, idealHeight: CGFloat? = nil, maxHeight: CGFloat? = nil, alignment: Alignment = .center) -> some View {
        return self
    }

    @available(*, unavailable)
    public func grayscale(_ amount: Double) -> some View {
        return self
    }

    @available(*, unavailable)
    public func handlesExternalEvents(preferring: Set<String>, allowing: Set<String>) -> some View {
        return self
    }

    @available(*, unavailable)
    public func headerProminence(_ prominence: Prominence) -> some View {
        return self
    }

    @available(*, unavailable)
    public func help(_ textKey: LocalizedStringKey) -> some View {
        return self
    }

    @available(*, unavailable)
    public func help(_ text: Text) -> some View {
        return self
    }

    @available(*, unavailable)
    public func help(_ text: String) -> some View {
        return self
    }

    public func hidden() -> some View {
        #if SKIP
        return opacity(0.0)
        #else
        return self
        #endif
    }

    @available(*, unavailable)
    public func hoverEffect(_ effect: HoverEffect = .automatic, isEnabled: Bool = true) -> some View {
        return self
    }

    @available(*, unavailable)
    public func hoverEffectDisabled(_ disabled: Bool = true) -> some View {
        return self
    }

    @available(*, unavailable)
    public func hueRotation(_ angle: Angle) -> some View {
        return self
    }

    @available(*, unavailable)
    public func id(_ id: any Hashable) -> some View {
        return self
    }

    @available(*, unavailable)
    public func ignoresSafeArea(_ regions: SafeAreaRegions = .all, edges: Edge.Set = .all) -> some View {
        return self
    }

    @available(*, unavailable)
    public func inspector(isPresented: Binding<Bool>, @ViewBuilder content: () -> any View) -> some View {
        return self
    }

    @available(*, unavailable)
    public func inspectorColumnWidth(min: CGFloat? = nil, ideal: CGFloat, max: CGFloat? = nil) -> some View {
        return self
    }

    @available(*, unavailable)
    public func inspectorColumnWidth(_ width: CGFloat) -> some View {
        return self
    }

    @available(*, unavailable)
    public func interactionActivityTrackingTag(_ tag: String) -> some View {
        return self
    }

    @available(*, unavailable)
    public func interactiveDismissDisabled(_ isDisabled: Bool = true) -> some View {
        return self
    }

    @available(*, unavailable)
    public func keyboardShortcut(_ key: KeyEquivalent, modifiers: EventModifiers = .command) -> some View {
        return self
    }

    @available(*, unavailable)
    public func keyboardShortcut(_ shortcut: KeyboardShortcut?) -> some View {
        return self
    }

    @available(*, unavailable)
    public func keyboardShortcut(_ key: KeyEquivalent, modifiers: EventModifiers = .command, localization: KeyboardShortcut.Localization) -> some View {
        return self
    }

    public func labelsHidden() -> some View {
        #if SKIP
        return environment(\._labelsHidden, true)
        #else
        return self
        #endif
    }

    @available(*, unavailable)
    public func layoutDirectionBehavior(_ behavior: LayoutDirectionBehavior) -> some View {
        return self
    }

    @available(*, unavailable)
    public func layoutPriority(_ value: Double) -> some View {
        return self
    }

    @available(*, unavailable)
    public func listRowBackground(_ view: (any View)?) -> some View {
        return self
    }

    @available(*, unavailable)
    public func luminanceToAlpha() -> some View {
        return self
    }

    @available(*, unavailable)
    public func mask(alignment: Alignment = .center, @ViewBuilder _ mask: () -> any View) -> some View {
        return self
    }

    @available(*, unavailable)
    public func matchedGeometryEffect<ID>(id: any Hashable, in namespace: Any /* Namespace.ID */, properties: MatchedGeometryProperties = .frame, anchor: UnitPoint = .center, isSource: Bool = true) -> some View {
        return self
    }

    @available(*, unavailable)
    public func modifier(_ modifier: Any) -> some View {
        return self
    }

    public func offset(_ offset: CGSize) -> some View {
        return self.offset(x: offset.width, y: offset.height)
    }

    public func offset(x: CGFloat = 0.0, y: CGFloat = 0.0) -> some View {
        #if SKIP
        return ComposeModifierView(contextView: self) {
            $0.modifier = $0.modifier.offset(x: x.dp, y: y.dp)
        }
        #else
        return self
        #endif
    }

    @available(*, unavailable)
    public func onAppear(perform action: (() -> Void)? = nil) -> some View {
        return self
    }

    @available(*, unavailable)
    public func onChange<V>(of value: V, perform action: @escaping (_ newValue: V) -> Void) -> some View where V : Equatable {
        return self
    }

    @available(*, unavailable)
    public func onChange<V>(of value: V, initial: Bool = false, _ action: @escaping (_ oldValue: V, _ newValue: V) -> Void) -> some View where V : Equatable {
        return self
    }

    @available(*, unavailable)
    public func onChange<V>(of value: V, initial: Bool = false, _ action: @escaping () -> Void) -> some View where V : Equatable {
        return self
    }

    @available(*, unavailable)
    public func onContinuousHover(coordinateSpace: some CoordinateSpaceProtocol = CoordinateSpaceProtocol.local, perform action: @escaping (HoverPhase) -> Void) -> some View {
        return self
    }

    @available(*, unavailable)
    public func onDisappear(perform action: (() -> Void)? = nil) -> some View {
        return self
    }

    @available(*, unavailable)
    public func onHover(perform action: @escaping (Bool) -> Void) -> some View {
        return self
    }

    public func opacity(_ opacity: Double) -> some View {
        #if SKIP
        return ComposeModifierView(contextView: self) {
            $0.modifier = $0.modifier.alpha(Float(opacity))
        }
        #else
        return self
        #endif
    }

    @available(*, unavailable)
    public func overlay(alignment: Alignment = .center, @ViewBuilder content: () -> any View) -> some View {
        return self
    }

    @available(*, unavailable)
    public func overlay(_ style: any ShapeStyle, ignoresSafeAreaEdges edges: Edge.Set = .all) -> some View {
        return self
    }

    @available(*, unavailable)
    public func overlay(_ style: any ShapeStyle, in shape: any Shape, fillStyle: FillStyle = FillStyle()) -> some View {
        return self
    }

    public func padding(_ insets: EdgeInsets) -> some View {
        #if SKIP
        return ComposeModifierView(contextView: self, role: .spacing) {
            // Compose throws a runtime error for negative padding
            $0.modifier = $0.modifier.padding(start: max(insets.leading, 0.0).dp, top: max(insets.top, 0.0).dp, end: max(insets.trailing, 0.0).dp, bottom: max(insets.bottom, 0.0).dp)
        }
        #else
        return self
        #endif
    }

    public func padding(_ edges: Edge.Set = .all, _ length: CGFloat? = nil) -> some View {
        #if SKIP
        let amount = max(length ?? CGFloat(16.0), CGFloat(0.0)).dp
        let start = edges.contains(.leading) ? amount : 0.dp
        let end = edges.contains(.trailing) ? amount : 0.dp
        let top = edges.contains(.top) ? amount : 0.dp
        let bottom = edges.contains(.bottom) ? amount : 0.dp
        return ComposeModifierView(contextView: self, role: .spacing) {
            $0.modifier = $0.modifier.padding(start: start, top: top, end: end, bottom: bottom)
        }
        #else
        return self
        #endif
    }

    public func padding(_ length: CGFloat) -> some View {
        return padding(.all, length)
    }

    @available(*, unavailable)
    public func persistentSystemOverlays(_ visibility: Visibility) -> some View {
        return self
    }

    @available(*, unavailable)
    public func position(_ position: CGPoint) -> some View {
        return self
    }

    @available(*, unavailable)
    public func position(x: CGFloat = 0.0, y: CGFloat = 0.0) -> some View {
        return self
    }

    @available(*, unavailable)
    public func preferredColorScheme(_ colorScheme: ColorScheme?) -> some View {
        return self
    }

    @available(*, unavailable)
    public func projectionEffect(_ transform: Any /* ProjectionTransform */) -> some View {
        return self
    }

    @available(*, unavailable)
    public func popover<Item>(item: Binding<Item?>, attachmentAnchor: Any? = nil /* PopoverAttachmentAnchor = .rect(.bounds) */, arrowEdge: Edge = .top, @ViewBuilder content: @escaping (Item) -> any View) -> some View /* where Item : Identifiable, */ {
        return self
    }

    @available(*, unavailable)
    public func popover(isPresented: Binding<Bool>, attachmentAnchor: Any? = nil /* PopoverAttachmentAnchor = .rect(.bounds) */, arrowEdge: Edge = .top, @ViewBuilder content: @escaping () -> any View) -> some View {
        return self
    }

    @available(*, unavailable)
    public func refreshable(action: @escaping () async -> Void) -> some View {
        return self
    }

    @available(*, unavailable)
    public func renameAction(_ isFocused: Any /* FocusState<Bool>.Binding */) -> some View {
        return self
    }

    @available(*, unavailable)
    public func renameAction(_ action: @escaping () -> Void) -> some View {
        return self
    }

    public func rotationEffect(_ angle: Angle) -> some View {
        #if SKIP
        return ComposeModifierView(contextView: self) {
            $0.modifier = $0.modifier.rotate(Float(angle.degrees))
        }
        #else
        return self
        #endif
    }

    @available(*, unavailable)
    public func rotationEffect(_ angle: Angle, anchor: UnitPoint) -> some View {
        #if SKIP
        fatalError()
        #else
        return self
        #endif
    }

    @available(*, unavailable)
    public func rotation3DEffect(_ angle: Angle, axis: (x: CGFloat, y: CGFloat, z: CGFloat), anchor: UnitPoint = .center, anchorZ: CGFloat = 0.0, perspective: CGFloat = 1.0) -> some View {
        return self
    }

    @available(*, unavailable)
    public func safeAreaInset(edge: VerticalEdge, alignment: HorizontalAlignment = .center, spacing: CGFloat? = nil, @ViewBuilder content: () -> any View) -> some View {
        return self
    }

    @available(*, unavailable)
    public func safeAreaInset(edge: HorizontalEdge, alignment: VerticalAlignment = .center, spacing: CGFloat? = nil, @ViewBuilder content: () -> any View) -> some View {
        return self
    }

    @available(*, unavailable)
    public func safeAreaPadding(_ insets: EdgeInsets) -> some View {
        return self
    }

    @available(*, unavailable)
    public func safeAreaPadding(_ edges: Edge.Set = .all, _ length: CGFloat? = nil) -> some View {
        return self
    }

    @available(*, unavailable)
    public func safeAreaPadding(_ length: CGFloat) -> some View {
        return self
    }

    @available(*, unavailable)
    public func saturation(_ amount: Double) -> some View {
        return self
    }

    public func scaledToFit() -> some View {
        return aspectRatio(nil, contentMode: .fit)
    }

    public func scaledToFill() -> some View {
        return aspectRatio(nil, contentMode: .fill)
    }

    public func scaleEffect(_ scale: CGSize) -> some View {
        return scaleEffect(x: scale.width, y: scale.height)
    }

    @available(*, unavailable)
    public func scaleEffect(_ scale: CGSize, anchor: UnitPoint) -> some View {
        return scaleEffect(x: scale.width, y: scale.height)
    }

    public func scaleEffect(_ s: CGFloat) -> some View {
        return scaleEffect(x: s, y: s)
    }

    @available(*, unavailable)
    public func scaleEffect(_ s: CGFloat, anchor: UnitPoint) -> some View {
        return scaleEffect(x: s, y: s)
    }

    public func scaleEffect(x: CGFloat = 1.0, y: CGFloat = 1.0) -> some View {
        #if SKIP
        return ComposeModifierView(contextView: self) {
            $0.modifier = $0.modifier.scale(scaleX: Float(x), scaleY: Float(y))
        }
        #else
        return self
        #endif
    }

    @available(*, unavailable)
    public func scaleEffect(x: CGFloat = 1.0, y: CGFloat = 1.0, anchor: UnitPoint) -> some View {
        return scaleEffect(x: x, y: y)
    }

    @available(*, unavailable)
    public func selectionDisabled(_ isDisabled: Bool = true) -> some View {
        return self
    }

    @available(*, unavailable)
    public func sensoryFeedback(_ feedback: SensoryFeedback, trigger: any Equatable) -> some View {
        return self
    }

    @available(*, unavailable)
    public func sensoryFeedback<T>(_ feedback: SensoryFeedback, trigger: T, condition: @escaping (_ oldValue: T, _ newValue: T) -> Bool) -> some View where T: Equatable {
        return self
    }

    @available(*, unavailable)
    public func sensoryFeedback<T>(trigger: T, _ feedback: @escaping (_ oldValue: T, _ newValue: T) -> SensoryFeedback?) -> some View where T : Equatable {
        return self
    }

    @available(*, unavailable)
    public func shadow(color: Color = Color(/* .sRGBLinear, */ white: 0.0, opacity: 0.33), radius: CGFloat, x: CGFloat = 0.0, y: CGFloat = 0.0) -> some View {
        return self
    }

    @available(*, unavailable)
    public func statusBarHidden(_ hidden: Bool = true) -> some View {
        return self
    }

    @available(*, unavailable)
    public func submitLabel(_ submitLabel: SubmitLabel) -> some View {
        return self
    }

    @available(*, unavailable)
    public func symbolEffectsRemoved(_ isEnabled: Bool = true) -> some View {
        return self
    }

    public func tag(_ tag: any Hashable) -> some View {
        return self
    }

    public func task(priority: TaskPriority = .userInitiated, _ action: @escaping () async -> Void) -> some View {
        return task(id: 0, priority: priority, action)
    }

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

    public func tint(_ color: Color?) -> some View {
        #if SKIP
        return environment(\._tint, color)
        #else
        return self
        #endif
    }

    @available(*, unavailable)
    public func tint(_ tint: (any ShapeStyle)?) -> some View {
        return self
    }

    @available(*, unavailable)
    public func transformEffect(_ transform: Any /* CGAffineTransform */) -> some View {
        return self
    }

    @available(*, unavailable)
    public func transformEnvironment<V>(_ keyPath: Any /* WritableKeyPath<EnvironmentValues, V> */, transform: @escaping (inout V) -> Void) -> some View {
        return self
    }

    @available(*, unavailable)
    public func typeSelectEquivalent(_ text: Text?) -> some View {
        return self
    }

    @available(*, unavailable)
    public func typeSelectEquivalent(_ stringKey: LocalizedStringKey) -> some View {
        return self
    }

    @available(*, unavailable)
    public func typeSelectEquivalent(_ string: String) -> some View {
        return self
    }

    @available(*, unavailable)
    public func zIndex(_ value: Double) -> some View {
        return self
    }
}

#if !SKIP

// Stubs needed to compile this package:

extension Optional : View where Wrapped : View {
    public var body: some View {
        stubView()
    }
}

extension Never : View {
}
#endif
