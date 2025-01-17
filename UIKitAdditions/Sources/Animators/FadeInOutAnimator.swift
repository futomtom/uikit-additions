import UIKit

public class FadeInOutAnimator: NSObject, Animator {
    public let isOverlay: Bool
    public let duration: TimeInterval
    
    public var isPresenting: Bool = true
    
    public init(duration: TimeInterval = 0.33, isOverlay: Bool = false) {
        self.duration = duration
        self.isOverlay = isOverlay
    }
    
    public static func navigationController(duration: TimeInterval = 0.33, navigationController: UINavigationController, animationControllerForOperation operation: UINavigationController.Operation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = FadeInOutAnimator(duration: duration)
        animator.isPresenting = operation == .push
        return animator
    }

    public func present(_ transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let fromVC = transitionContext.viewController(forKey: .from)
        let toVC = transitionContext.viewController(forKey: .to)
        let duration = transitionDuration(using: transitionContext)
            
        fromVC?.beginAppearanceTransition(false, animated: true)
        
        toVC!.view.alpha = 0
        containerView.addSubview(toVC!.view)
        toVC!.view.frame = containerView.bounds

        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: {
            if !self.isOverlay {
                fromVC!.view.alpha = 0
            }
            toVC!.view.alpha = 1
            
        }) { _ in
            fromVC?.endAppearanceTransition()
            transitionContext.completeTransition(true)
            
        }
    }
    
    public func dismiss(_ transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let fromVC = transitionContext.viewController(forKey: .from)
        let toVC = transitionContext.viewController(forKey: .to)
        let duration = transitionDuration(using: transitionContext)
            
        toVC?.beginAppearanceTransition(true, animated: true)
        
        if !self.isOverlay {
            toVC!.view.alpha = 0
            containerView.addSubview(toVC!.view)
        }
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: {
            fromVC!.view.alpha = 0
            if !self.isOverlay {
                toVC!.view.alpha = 1
            }
            
        }) { _ in
            toVC?.endAppearanceTransition()
            transitionContext.completeTransition(true)
        }
    }
}

extension FadeInOutAnimator {
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionContext.flatMap { $0.isAnimated ? self.duration : 0 } ?? self.duration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if self.isPresenting {
            present(transitionContext)
        } else {
            dismiss(transitionContext)
        }
    }
}

extension FadeInOutAnimator {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.isPresenting = true
        return self
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.isPresenting = false
        return self
    }
}
