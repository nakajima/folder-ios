//
//  PlayerView.swift
//  folder-ios
//
//  Created by Pat Nakajima on 10/5/23.
//

import Models
import SwiftUI

struct PlayerView: View {
	@GestureState var dragOffset: CGFloat = 0
	@State private var isExpanded = false
	@State private var text = ""

	@State private var isScrubbing = false
	@State private var scrubbingOffset: CGFloat?

	//	var nowPlaying: NowPlaying
	@ObservedObject var playerSession: PlayerSession

	var body: some View {
		if let nowPlaying = playerSession.nowPlaying {
			VStack(alignment: .leading, spacing: 0) {
				HStack {
					Text(nowPlaying.track.name)
						.bold()
					Spacer()

					Button(action: {
						withAnimation(.spring(duration: 0.2)) {
							isExpanded.toggle()
						}
					}) {
						Image(systemName: "ellipsis.circle")
					}
					.tint(.primary)
					.buttonStyle(.bordered)
					.controlSize(.small)
					.clipShape(Circle())

					PlayButton(track: nowPlaying.track, version: nowPlaying.version)
						.foregroundStyle(.primary)
						.id(nowPlaying.id)
				}

				if isExpanded {
					HStack {
						TextField("Add a comment…", text: $text)
							.textFieldStyle(.roundedBorder)
						Button(action: {}) {
							Text("Post")
						}
						.buttonStyle(.bordered)
						.controlSize(.small)
						.tint(.primary)
					}
					.padding(.vertical)
					.transition(.scale(0, anchor: .bottom).combined(with: .opacity))
				}

				Text("Version \(nowPlaying.version.number)")
					.foregroundStyle(.secondary)

				HStack {
					Text(nowPlaying.currentTime.formatDuration)
						.monospacedDigit()
					GeometryReader { geo in
						ZStack(alignment: .leading) {
							RoundedRectangle(cornerRadius: Constants.cornerRadius * 12)
								.frame(height: isScrubbing ? 12 : 2)
								.cornerRadius(12)

							if let duration = nowPlaying.version.duration {
								RoundedRectangle(cornerRadius: Constants.cornerRadius * 12)
									.fill(.primary)
									.frame(width: scrubbingOffset ?? (nowPlaying.currentTime / TimeInterval(duration)) * geo.size.width)
									.animation(.snappy(duration: 0.1), value: nowPlaying.currentTime)
									.frame(height: isScrubbing ? 12 : 2)
							}
						}
						.highPriorityGesture(DragGesture(minimumDistance: 0).onChanged { event in
							withAnimation {
								isScrubbing = true

								self.scrubbingOffset = max(0, event.location.x)
							}
						}.onEnded { event in
							withAnimation {
								isScrubbing = false

								self.playerSession.scrub(to: event.location.x / geo.size.width)
								self.scrubbingOffset = nil
							}
						})
					}
					.frame(height: isScrubbing ? 12 : 2)
					.cornerRadius(64)

					Text("\(TimeInterval(nowPlaying.version.duration ?? 0).formatDuration)")
				}
				.foregroundColor(.secondary)
				.font(.caption2)
				.padding(.vertical, 8)

				if isExpanded {
					VStack(spacing: 12) {
						HStack(spacing: 24) {
							Spacer()

							Button(action: {
								playerSession.previous()
							}) {
								Image(systemName: "backward.fill")
									.resizable()
									.scaledToFit()
									.frame(width: 24, height: 24)
							}
							.tint(.primary)

							PlayButton(
								track: nowPlaying.track,
								version: nowPlaying.version,
								playIcon: "play.circle.fill",
								pauseIcon: "pause.circle.fill",
								size: 48
							)
							.foregroundStyle(.primary)
							.id(nowPlaying.id)

							Button(action: {
								playerSession.next()
							}) {
								Image(systemName: "forward.fill")
									.resizable()
									.scaledToFit()
									.frame(width: 24, height: 24)
							}
							.tint(.primary)

							Spacer()
						}
					}
					.transition(.scale(0, anchor: .bottom).combined(with: .opacity))
					.padding(.top, 12)
					.fontWeight(.light)
				}
			}
			.font(.subheadline)
			.frame(maxWidth: .infinity)
			.padding(.horizontal)
			.padding(.vertical, 12)
			.padding(.bottom, dragPadding)
			.background(
				Rectangle()
					.fill(.ultraThinMaterial)
					.shadow(radius: 1)
					.ignoresSafeArea()
			)
			.gesture(DragGesture().updating($dragOffset) { event, state, _ in
				withAnimation {
					state = -event.translation.height
				}
			})
			.animation(.spring(duration: 0.2), value: dragOffset)
			.onChange(of: dragOffset) {
				withAnimation(.spring(duration: 0.2)) {
					if dragOffset != 0 {
						self.isExpanded = dragOffset > 48
					}
				}
			}
			.transition(.move(edge: .bottom).combined(with: .opacity))
		}
	}

	var dragPadding: CGFloat {
		if isExpanded {
			0
		} else {
			dragOffset
		}
	}
}

#Preview {
	ContentView()
}
