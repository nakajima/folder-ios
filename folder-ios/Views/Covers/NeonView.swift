//
//  NeonView.swift
//  drawly
//
//  Created by Pat Nakajima on 10/4/23.
//

import SwiftUI

extension Color {
	static func randomPastel(seed: Int? = nil) -> Color {
		var generator = RandomNumberGeneratorWithSeed(seed: seed ?? Int.random(in: 0 ... 256))

		let r: CGFloat = (CGFloat.random(in: 0 ... 255, using: &generator) / 256.0) / 2.0 + 0.7
		let g: CGFloat = (CGFloat.random(in: 0 ... 255, using: &generator) / 256.0) / 2.0 + 0.5
		let b: CGFloat = (CGFloat.random(in: 0 ... 255, using: &generator) / 256.0) / 2.0 + 0.7

		return Color(UIColor(red: r, green: g, blue: b, alpha: 1.0))
	}

	static func randomBright(seed: Int? = nil) -> Color {
		var generator = RandomNumberGeneratorWithSeed(seed: seed ?? Int.random(in: 0 ... 256))

		let hue = CGFloat.random(in: 0 ... 255, using: &generator) / 255

		let saturation: CGFloat = (CGFloat.random(in: 0 ... 255, using: &generator) / 255) + 0.5
		let brightness: CGFloat = (CGFloat.random(in: 0 ... 255, using: &generator) / 255) + 0.8

		return Color(UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1))
	}
}

extension CGPoint {
	static func random(in range: ClosedRange<CGFloat>) -> CGPoint {
		.init(x: CGFloat.random(in: range), y: CGFloat.random(in: range))
	}
}

struct RandomNumberGeneratorWithSeed: RandomNumberGenerator {
	init(seed: Int) { srand48(seed) }
	func next() -> UInt64 { return UInt64(drand48() * Double(UInt64.max)) }
}

struct LineView: View {
	var seed: Int
	var size: CGFloat
	var path: CGPath
	var colors: [Color]
	var angle: Angle

	init(seed: Int, size: CGFloat, path: CGPath) {
		self.seed = seed
		self.size = size
		self.path = path
		self.colors = (0 ... 5).map { i in Color.randomBright(seed: seed + i) }
		self.angle = .degrees(Double(seed % 360))
	}

	var body: some View {
		GeometryReader { geo in
			ZStack {
				Path(path)
					.stroke(lineWidth: geo.size.width * 0.02)
					.fill(
						.conicGradient(
							.init(
								.init(colors: colors)
							),
							center: .bottom,
							angle: angle
						)
					)
					.blur(radius: 16, opaque: false)
					.contrast(1.1)
					.opacity(0.5)

				Path(path)
					.stroke(lineWidth: geo.size.width * 0.008)
					.fill(
						.conicGradient(
							.init(
								.init(colors: colors)
							),
							center: .bottom,
							angle: angle
						)
					)
					.shadow(radius: 2)
			}
		}
	}

	func randomCenter() -> UnitPoint {
		[
			//			.bottom, .top,
			.bottomLeading, .bottomTrailing,
			.topLeading, .topTrailing,
			.leading, .trailing,
		].randomElement()!
	}
}

struct NeonView: View {
	var size: CGFloat
	var seed: Int

	var body: some View {
		ZStack(alignment: .center) {
			ForEach(0 ..< 1, id: \.self) { i in
				LineView(seed: seed, size: size, path: makePath(size: size, seed: seed + i))
			}
		}
		.background(
			Rectangle()
				.fill(Color.randomPastel(seed: seed + 10))
				.shadow(radius: 1)
		)
		.frame(width: size, height: size)
		.clipped()
	}

	func makePath(size: CGFloat, seed: Int) -> CGPath {
		var generator = RandomNumberGeneratorWithSeed(seed: seed)
		let path = UIBezierPath()

		let numberOfSegments = Int.random(in: 24 ... 32, using: &generator)
		var x: CGFloat = -(size / CGFloat(numberOfSegments))

		path.move(to: .init(x: x, y: CGFloat.random(in: 0 ... size, using: &generator)))

		for i in 0 ... numberOfSegments {
			x += (size / CGFloat(numberOfSegments))
			let nextPointOffset = CGFloat.random(in: 0 ... (size / 2), using: &generator)
			let nextPoint = i.isMultiple(of: 2) ? nextPointOffset : -nextPointOffset

			path.addLine(to: .init(x: x, y: (size / 2) + nextPoint))
		}

		return path.copy(roundingCornersToRadius: 10).cgPath
	}
}

#Preview {
	GeometryReader { geo in
		NeonView(size: geo.size.width, seed: 1)
	}
}
