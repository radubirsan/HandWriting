import SwiftUI
import Combine

class KeyboardResponder: ObservableObject {
    @Published var currentHeight: CGFloat = 0
    private var cancellable: AnyCancellable?

    init() {
        cancellable = NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillChangeFrameNotification)
            .merge(with: NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification))
            .compactMap { notification in
                self.keyboardHeight(from: notification)
            }
            .assign(to: \.currentHeight, on: self)
    }

    deinit {
        cancellable?.cancel()
    }

    private func keyboardHeight(from notification: Notification) -> CGFloat? {
        guard let frameEnd = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return nil
        }
        return frameEnd.height
    }
}
