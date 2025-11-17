//
//  TBASegmentedControl.swift
//  TBA
//
//  Created by Zachary Orr on 4/27/25.
//  Copyright © 2025 The Blue Alliance. All rights reserved.
//

import UIKit

protocol ScrollableTabBarViewDelegate: AnyObject {
    func segmentedControl(_ segmentedControl: TBASegmentedControl, didSelectIndex index: Int)
}

class TBASegmentedControl: UIView {
    weak var delegate: ScrollableTabBarViewDelegate?

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .navigationBarTintColor
        return scrollView
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let underlineIndicator: UIView = {
        let view = UIView()
        view.backgroundColor = .accent
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var tabButtons: [UIButton] = []
    private var underlineLeadingConstraint: NSLayoutConstraint!
    private var underlineWidthConstraint: NSLayoutConstraint!

    var selectedIndex: Int = 0

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupViews()
    }

    private func setupViews() {
        addSubview(scrollView)
        scrollView.addSubview(stackView)
        scrollView.addSubview(underlineIndicator)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalToSystemSpacingAfter: scrollView.leadingAnchor, multiplier: 1.0),
            stackView.trailingAnchor.constraint(equalToSystemSpacingAfter: scrollView.trailingAnchor, multiplier: 1.0),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            // TODO: This is problematic, because we're not taking our system spacing into account
            stackView.widthAnchor.constraint(greaterThanOrEqualTo: widthAnchor, multiplier: 1.0),
        ])

        underlineLeadingConstraint = underlineIndicator.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 0)
        underlineWidthConstraint = underlineIndicator.widthAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            underlineLeadingConstraint,
            underlineWidthConstraint,
            underlineIndicator.bottomAnchor.constraint(equalTo: bottomAnchor),
            underlineIndicator.heightAnchor.constraint(equalToConstant: 2),
        ])
    }

    // MARK: - Public Methods

    func configure(with titles: [String]) {
        tabButtons.forEach { $0.removeFromSuperview() }
        tabButtons.removeAll()
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for (index, title) in titles.enumerated() {
            let button = UIButton(type: .custom)
            button.tintColor = nil
            button.setTitle(title, for: .normal)
            button.tag = index
            button.addTarget(self, action: #selector(tabButtonTapped(_:)), for: .touchUpInside)
            button.setTitleColor(.white, for: .normal)
            button.setTitleColor(.white, for: .selected)

            let textStyle: UIFont.TextStyle = .subheadline
            let metrics = UIFontMetrics(forTextStyle: textStyle)
            let baseFontWithWeight = UIFont.systemFont(ofSize: 15, weight: .semibold)
            let dynamicallyScaledSemiboldSubheadlineFont = metrics.scaledFont(for: baseFontWithWeight)

            button.titleLabel?.font = dynamicallyScaledSemiboldSubheadlineFont
            button.titleLabel?.adjustsFontForContentSizeCategory = true

            tabButtons.append(button)
            stackView.addArrangedSubview(button)
        }

        // Determine distribution based on content width
        layoutIfNeeded()

        let totalButtonWidth = tabButtons.reduce(0) { $0 + $1.intrinsicContentSize.width }
        let totalSpacing = CGFloat(titles.count - 1) * stackView.spacing
        let requiredWidth = totalButtonWidth + totalSpacing + 2 * 16 // Add padding

        if requiredWidth <= bounds.width {
            // All tabs fit, distribute equally
            stackView.distribution = .fillEqually
        } else {
            // Tabs need to scroll, size based on content with minimum width
            stackView.distribution = .fill // Reset to fill
            for button in tabButtons {
                // Add width constraints based on intrinsic content size + padding, with minimum
                let textWidth = button.intrinsicContentSize.width
                let buttonWidth = max(textWidth + 20, 100) // Text width + padding, minimum 100
                button.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
            }
        }

        // Select the first tab initially
        selectTab(at: 0, animated: false)
    }

    func selectTab(at index: Int, animated: Bool) {
        guard index >= 0, index < tabButtons.count else {
            return
        }

        // Deselect the previously selected button
        if selectedIndex < tabButtons.count {
            tabButtons[selectedIndex].isSelected = false
        }

        // Select the new button
        let selectedButton = tabButtons[index]
        selectedButton.isSelected = true
        selectedIndex = index

        // Animate the underline indicator
        UIView.animate(withDuration: animated ? 0.3 : 0) {
            self.underlineLeadingConstraint.constant = selectedButton.frame.origin.x + self.stackView.frame.origin.x
            self.underlineWidthConstraint.constant = selectedButton.frame.width
            self.layoutIfNeeded()
        }

        // Scroll to center the selected tab if needed
        let selectedButtonFrame = selectedButton.convert(selectedButton.bounds, to: scrollView)
        let centerX = selectedButtonFrame.midX
        let scrollOffset = centerX - scrollView.bounds.width / 2
        let adjustedOffset = max(0, min(scrollOffset, scrollView.contentSize.width - scrollView.bounds.width))
        scrollView.setContentOffset(CGPoint(x: adjustedOffset, y: 0), animated: animated)
    }

    // MARK: - Actions

    @objc private func tabButtonTapped(_ sender: UIButton) {
        let index = sender.tag
        selectTab(at: index, animated: true)
        delegate?.segmentedControl(self, didSelectIndex: index)
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        // Update underline position and width when layout changes (e.g., rotation)
        if selectedIndex < tabButtons.count {
            let selectedButton = tabButtons[selectedIndex]
            // Ensure stackView's frame is updated before calculating button position
            stackView.layoutIfNeeded()
            underlineLeadingConstraint.constant = selectedButton.frame.origin.x + stackView.frame.origin.x
            underlineWidthConstraint.constant = selectedButton.frame.width
        }
    }
}
