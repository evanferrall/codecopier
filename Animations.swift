import SwiftUI

/// Collection of standard animations used across CodeCopier UI.
///
/// All animations share a common `.easeOut` curve with a 0.25 second duration
/// so interactions feel consistent across the app.
public enum Animations {
    /// The base animation used for all transitions.
    public static let standard: Animation = .easeOut(duration: 0.25)

    /// Transition that smoothly toggles visibility with a fade.
    public static var smoothToggle: AnyTransition {
        .opacity.animation(standard)
    }

    /// A sliding transition that also fades the content.
    ///
    /// Useful when inserting or removing views from a stack.
    public static var slideFade: AnyTransition {
        .move(edge: .top).combined(with: .opacity).animation(standard)
    }
}

extension View {
    /// Applies a smooth toggle effect when `isOn` changes.
    public func smoothToggle(_ isOn: Bool) -> some View {
        transition(Animations.smoothToggle)
            .animation(Animations.standard, value: isOn)
    }

    /// Applies the slide and fade transition when `condition` changes.
    public func slideFade(_ condition: Bool) -> some View {
        transition(Animations.slideFade)
            .animation(Animations.standard, value: condition)
    }
}
