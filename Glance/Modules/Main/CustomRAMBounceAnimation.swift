import RAMAnimatedTabBarController
import UIKit

class CustomBounceAnimation: RAMItemAnimation {

    var selectedImage: UIImage?
    var normalImage: UIImage?

    override func playAnimation(_ icon: UIImageView, textLabel: UILabel) {
        playBounceAnimation(icon)
        selectedState(icon, textLabel: textLabel)
        textLabel.textColor = textSelectedColor
    }

    open override func deselectAnimation(_ icon: UIImageView, textLabel: UILabel, defaultTextColor: UIColor, defaultIconColor: UIColor) {

        textLabel.textColor = defaultTextColor
        if let normalImage = normalImage {
            icon.image = normalImage.withRenderingMode(.alwaysOriginal)
        }
    }

    open override func selectedState(_ icon: UIImageView, textLabel: UILabel) {

        textLabel.textColor = textSelectedColor
        if let iconImage = selectedImage {
            icon.image = iconImage.withRenderingMode(.alwaysOriginal)
        }
    }

    func playBounceAnimation(_ icon: UIImageView) {

        let bounceAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        bounceAnimation.values = [1.0, 1.4, 0.9, 1.15, 0.95, 1.02, 1.0]
        bounceAnimation.duration = TimeInterval(duration)
        bounceAnimation.calculationMode = CAAnimationCalculationMode.cubic

        icon.layer.add(bounceAnimation, forKey: nil)

        if let iconImage = icon.image {
            icon.image = iconImage.withRenderingMode(.alwaysOriginal)
        }
    }
}

class CustomAnimatedTabBarItem: RAMAnimatedTabBarItem {

    override func playAnimation() {

        assert(animation != nil, "add animation in UITabBarItem")
        guard animation != nil && iconView != nil else {
            return
        }
        animation.playAnimation(iconView!.icon, textLabel: iconView!.textLabel)
    }

    override func deselectAnimation() {

        guard animation != nil && iconView != nil else {
            return
        }

        animation.deselectAnimation(
            iconView!.icon,
            textLabel: iconView!.textLabel,
            defaultTextColor: textColor,
            defaultIconColor: .clear)
    }

    override func selectedState() {
        guard animation != nil, let iconView = iconView else {
            return
        }

        animation.selectedState(iconView.icon, textLabel: iconView.textLabel)
    }

    override func deselectedState() {
        guard animation != nil && iconView != nil else {
            return
        }

        animation.deselectedState(iconView!.icon, textLabel: iconView!.textLabel)
    }
}
