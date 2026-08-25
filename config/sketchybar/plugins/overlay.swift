import AppKit

let text = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "Time is up"
// Accent is passed in as sketchybar's 0xAARRGGBB so the overlay follows whichever
// color scheme was rolled for this session.
let accentArg = CommandLine.arguments.count > 2 ? CommandLine.arguments[2] : "0xff2cf9ed"
let emojis = ["🎉", "🎊", "🥳", "✨"]

let fadeIn = 0.35, hold = 4.1, fadeOut = 0.55   // 5.0s total

func parseColor(_ s: String) -> NSColor {
    let hex = s.hasPrefix("0x") ? String(s.dropFirst(2)) : s
    guard let v = UInt32(hex, radix: 16), hex.count == 8 else { return .systemTeal }
    return NSColor(srgbRed: CGFloat((v >> 16) & 0xff) / 255,
                   green:   CGFloat((v >> 8) & 0xff) / 255,
                   blue:    CGFloat(v & 0xff) / 255,
                   alpha:   CGFloat((v >> 24) & 0xff) / 255)
}
let accent = parseColor(accentArg)

let app = NSApplication.shared
// .accessory keeps the overlay out of the Dock and stops it stealing focus from
// whatever the user is typing in.
app.setActivationPolicy(.accessory)

var windows: [NSWindow] = []

for screen in NSScreen.screens {
    let win = NSWindow(contentRect: screen.frame, styleMask: .borderless,
                       backing: .buffered, defer: false)
    win.setFrame(screen.frame, display: false)
    win.isOpaque = false
    win.backgroundColor = .clear
    win.hasShadow = false
    win.ignoresMouseEvents = true
    win.level = .screenSaver
    win.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
    win.alphaValue = 0

    let root = NSView(frame: NSRect(origin: .zero, size: screen.frame.size))
    root.wantsLayer = true

    let label = NSTextField(labelWithString: text)
    label.font = NSFont.systemFont(ofSize: 96, weight: .bold)
    label.textColor = .white
    label.alignment = .center
    label.sizeToFit()

    // Each emoji is its own view so they can pop in one after another.
    let emojiFont = NSFont.systemFont(ofSize: 64)
    let emojiGap: CGFloat = 18
    var emojiViews: [NSTextField] = []
    for e in emojis {
        let v = NSTextField(labelWithString: e)
        v.font = emojiFont
        v.alignment = .center
        v.sizeToFit()
        v.wantsLayer = true
        emojiViews.append(v)
    }
    let emojiRowWidth = emojiViews.reduce(0) { $0 + $1.frame.width } + emojiGap * CGFloat(emojis.count - 1)
    let emojiRowHeight = emojiViews.map { $0.frame.height }.max() ?? 0

    let padX: CGFloat = 90, padY: CGFloat = 48, rowGap: CGFloat = 16
    let cardSize = NSSize(width: max(label.frame.width, emojiRowWidth) + padX * 2,
                          height: emojiRowHeight + rowGap + label.frame.height + padY * 2)
    let card = NSVisualEffectView(frame: NSRect(
        x: (screen.frame.width - cardSize.width) / 2,
        y: (screen.frame.height - cardSize.height) / 2,
        width: cardSize.width, height: cardSize.height))
    card.material = .hudWindow
    card.blendingMode = .behindWindow
    card.state = .active
    card.wantsLayer = true
    card.layer?.cornerRadius = 28
    card.layer?.masksToBounds = true
    card.layer?.borderWidth = 4
    card.layer?.borderColor = accent.cgColor

    label.frame = NSRect(x: (cardSize.width - label.frame.width) / 2, y: padY,
                         width: label.frame.width, height: label.frame.height)
    card.addSubview(label)

    var x = (cardSize.width - emojiRowWidth) / 2
    let emojiY = padY + label.frame.height + rowGap
    for v in emojiViews {
        v.frame = NSRect(x: x, y: emojiY, width: v.frame.width, height: v.frame.height)
        x += v.frame.width + emojiGap
        v.layer?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        v.layer?.position = CGPoint(x: v.frame.midX, y: v.frame.midY)
        v.layer?.transform = CATransform3DMakeScale(0.01, 0.01, 1)
        card.addSubview(v)
    }

    root.addSubview(card)
    win.contentView = root

    // Scale from the card's centre, so the grow-in reads as a pop rather than a slide.
    card.layer?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    card.layer?.position = CGPoint(x: card.frame.midX, y: card.frame.midY)
    card.layer?.transform = CATransform3DMakeScale(0.86, 0.86, 1)

    win.orderFrontRegardless()
    windows.append(win)

    NSAnimationContext.runAnimationGroup { ctx in
        ctx.duration = fadeIn
        ctx.timingFunction = CAMediaTimingFunction(name: .easeOut)
        win.animator().alphaValue = 1
        card.layer?.transform = CATransform3DIdentity
    }

    // Staggered fanfare: each emoji springs out after the card has settled.
    for (i, v) in emojiViews.enumerated() {
        let delay = fadeIn + 0.08 * Double(i)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            let pop = CASpringAnimation(keyPath: "transform.scale")
            pop.fromValue = 0.01
            pop.toValue = 1.0
            pop.damping = 9
            pop.stiffness = 180
            pop.mass = 0.7
            pop.duration = pop.settlingDuration
            v.layer?.transform = CATransform3DIdentity
            v.layer?.add(pop, forKey: "pop")
        }
    }
}

DispatchQueue.main.asyncAfter(deadline: .now() + fadeIn + hold) {
    NSAnimationContext.runAnimationGroup({ ctx in
        ctx.duration = fadeOut
        ctx.timingFunction = CAMediaTimingFunction(name: .easeIn)
        for w in windows { w.animator().alphaValue = 0 }
    }, completionHandler: { app.terminate(nil) })
}

app.run()
