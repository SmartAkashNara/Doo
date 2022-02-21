//
//  CardTabbarBaseViewController.swift
//  Doo-IoT
//
//  Created by Kiran Jasvanee on 08/04/20.
//  Copyright © 2020 SmartSense. All rights reserved.
//

import UIKit

// Link to learn - https://www.youtube.com/watch?v=L-f1KSPKm4I&t=524s

class CardTabbarBaseViewController: UITabBarController {
    
    // default ---------------------------------------
    enum CardPosition {
        case bottom
        case top
    }
    var cardPosition: CardPosition = .bottom
    enum CardState {
        case expanded
        case collapsed
    }
    var cardViewController: CardGenericViewController!
    private var visualEffectView: UIVisualEffectView!
    private var cardHeight: CGFloat = 600
    private var cardHandleAreaHeight: CGFloat = 60

    private var cardVisible = false
    private var nextState: CardState {
        return cardVisible ? .collapsed : .expanded
    }
    private var runningAnimations = [UIViewPropertyAnimator]()
    private var animationProgressWhenInterrupted: CGFloat = 0
    // ------------------------------------------------
    
    // customization by karan -------------------------
    var setCardHandleAreaHeight: CGFloat = 60 {
        didSet {
            cardHandleAreaHeight = setCardHandleAreaHeight
            // set new yth position (earilier did on setupCard)
            var cardFrame = cardViewController.view.frame
            if self.cardPosition == .bottom {
                cardFrame.origin.y = self.view.frame.height-cardHandleAreaHeight
            }else{
                cardFrame.origin.y = -cardHeight
            }
            cardViewController.view.frame = cardFrame
        }
    }
    var setCardHeight: CGFloat = 600 {
        didSet {
            cardHeight = setCardHeight
            // set new height position (earilier did on setupCard)
            var cardFrame = cardViewController.view.frame
            cardFrame.size.height = cardHeight
            cardViewController.view.frame = cardFrame
        }
    }
    private var isCurveApplied: Bool = true
    var applyDarkBlurrOnCard: Bool = false
    var applyDarkOnlyOnCard: Bool = false
    private var darkOnlyView: UIView!
    
    // closures
    var updateProgress: ((CGFloat) -> ())? = nil
    // ------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func setupCard(_ cardController: CardGenericViewController) {
        
        // For blurr
        visualEffectView = UIVisualEffectView()
        visualEffectView.frame = self.view.frame
        visualEffectView.isUserInteractionEnabled = false
        self.view.addSubview(visualEffectView)
        
        // For dark black only... by karan
        darkOnlyView = UIView.init(frame: self.view.frame)
        darkOnlyView.backgroundColor = .black
        darkOnlyView.alpha = 0.0
        darkOnlyView.isUserInteractionEnabled = false
        darkOnlyView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(dismissCardView(sender:))))
        self.view.addSubview(darkOnlyView)
        // ----
        
        cardViewController = cardController
        self.addChild(cardViewController)
        self.view.addSubview(cardViewController.view)
        if self.cardPosition == .bottom {
            cardViewController.view.frame = CGRect.init(x: 0, y: self.view.frame.height-cardHandleAreaHeight, width: self.view.bounds.width, height: cardHeight)
        }else{
            cardViewController.view.frame = CGRect.init(x: 0, y: -cardHeight, width: self.view.bounds.width, height: cardHeight)
        }
        cardViewController.view.clipsToBounds = true
        cardViewController.baseTabbarController = self   // by karan - to handle dynamic height. keep reference of base to cardView.
        
        let panGestureRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(handleCardPan(recognizer:)))
        cardViewController.handleArea.addGestureRecognizer(panGestureRecognizer)
    }
    
    // by karan
    @objc
    private func dismissCardView(sender: UITapGestureRecognizer) {
        self.closeCard()
    }
    
    // Card Work
    func openCardWithDynamicHeight(_ dynamicHeight: CGFloat) {
        setCardHeight = dynamicHeight
        self.openCard()
    }
    // ----
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @objc
    private func handleCardTap(recognizer: UITapGestureRecognizer) {

    }
    
    @objc private func handleCardPan(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            // start transition
            startInteractiveTransition(state: nextState, duration: 0.9)
        case .changed:
            // update transition
            let translation = recognizer.translation(in: self.cardViewController.handleArea)
            // print("translation: \(translation.y)")
            var fractionCompleted = translation.y / cardHeight
            // print("fraction completed: \(fractionCompleted)")
            if self.cardPosition == .bottom {
                fractionCompleted = cardVisible ? fractionCompleted : -fractionCompleted
            }else{
                fractionCompleted = cardVisible ? -fractionCompleted : fractionCompleted
            }
            // print("updated fraction completed: \(fractionCompleted)")
            updateInteractiveTransition(fractionCompleted: fractionCompleted)
            // print("-------")
        case .ended:
            // continue transition
            continueInteractiveTransition()
        default:
            break
        }
    }
    
    private func animateTransitionIfNeeded(state: CardState, duration: TimeInterval) {
        if runningAnimations.isEmpty {
            
            // animation - 1
            let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                switch state {
                case .expanded:
                    if self.cardPosition == .bottom {
                        self.cardViewController.view.frame.origin.y = self.view.frame.height - self.cardHeight
                    }else{
                        self.cardViewController.view.frame.origin.y = 0
                    }
                case .collapsed:
                    if self.cardPosition == .bottom {
                        self.cardViewController.view.frame.origin.y = self.view.frame.height - self.cardHandleAreaHeight
                    }else{
                        self.cardViewController.view.frame.origin.y = -self.cardHeight
                    }
                }
            }
            
            frameAnimator.addCompletion { (_) in
                self.cardVisible = !self.cardVisible
                for animation in self.runningAnimations {
                    animation.stopAnimation(true)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.runningAnimations.removeAll()
                }
            }
            
            frameAnimator.startAnimation()
            runningAnimations.append(frameAnimator)
            
            // animation - 2
            if isCurveApplied {
                let cornerRadiusAnimator = UIViewPropertyAnimator.init(duration: duration, curve: .linear) {
                    switch state {
                    case .expanded:
                        self.cardViewController.view.layer.cornerRadius = 12
                    case .collapsed:
                        self.cardViewController.view.layer.cornerRadius = 0
                    }
                }
                cornerRadiusAnimator.startAnimation()
                runningAnimations.append(cornerRadiusAnimator)
            }
            
            if applyDarkBlurrOnCard {
                // animation - 3
                let blurAnimator = UIViewPropertyAnimator.init(duration: duration, dampingRatio: 1) {
                    switch state {
                    case .expanded:
                        self.visualEffectView.effect = UIBlurEffect.init(style: .dark)
                    case .collapsed:
                        self.visualEffectView.effect = nil
                    }
                }
                blurAnimator.startAnimation()
                runningAnimations.append(blurAnimator)
            }
            
            if applyDarkOnlyOnCard {
                // animation - 3
                let darkOnlyAnimator = UIViewPropertyAnimator.init(duration: duration, dampingRatio: 1) {
                    switch state {
                    case .expanded:
                        self.darkOnlyView.alpha = 0.6
                        self.darkOnlyView.isUserInteractionEnabled = true
                    case .collapsed:
                        self.darkOnlyView.alpha = 0.0
                        self.darkOnlyView.isUserInteractionEnabled = false
                    }
                }
                darkOnlyAnimator.startAnimation()
                runningAnimations.append(darkOnlyAnimator)
            }
        }
    }
    
    private func startInteractiveTransition(state: CardState, duration: TimeInterval) {
        if runningAnimations.isEmpty {
            // run animations
            animateTransitionIfNeeded(state: state, duration: duration)
        }
        for animator in runningAnimations {
            animator.pauseAnimation()
            animationProgressWhenInterrupted = animator.fractionComplete
        }
    }
    private func updateInteractiveTransition(fractionCompleted: CGFloat) {
        for animator in runningAnimations {
            animator.fractionComplete = fractionCompleted + animationProgressWhenInterrupted
            self.updateProgress?(animator.fractionComplete)
        }
    }
    private func continueInteractiveTransition() {
        for animator in runningAnimations {
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
    }
    
    func closeCardAndPass<T>(_ info: T) {
        if self.cardVisible {
            self.animateTransitionIfNeeded(state: .collapsed, duration: 0.5)
        }
    }
}

// customization by karan -------------------------
extension CardTabbarBaseViewController {
    func openCard() {
        if !self.cardVisible {
            self.animateTransitionIfNeeded(state: .expanded, duration: 0.5)
        }
    }
    func closeCard() {
        if self.cardVisible {
            self.animateTransitionIfNeeded(state: .collapsed, duration: 0.5)
        }
    }
    func offCurveInCard() {
        isCurveApplied = false
        self.cardViewController.view.layer.cornerRadius = 0
    }
}
// ------------------------------------------------
