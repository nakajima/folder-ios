//
//  PlayerProvider.swift
//  folder-ios
//
//  Created by Pat Nakajima on 10/4/23.
//

import SwiftUI
import AVFAudio

struct Player {

}

class PlayerSession: ObservableObject {
	@Published var player: Player?

	var audioPlayer: AVAudioPlayer?
}

struct PlayButton: View {
	var body: some View {
		Button(action: {}) {
			Image(systemName: "play.circle")
				.resizable()
				.scaledToFit()
				.frame(width: 24, height: 24)
				.foregroundColor(.primary)
		}
	}
}

struct PlayerProvider<Content: View>: View {
	var content: () -> Content

	@GestureState var dragOffset: CGFloat = 0
	@State private var isExpanded = false

	@State private var text = ""

	var body: some View {
		content()
			.scrollDismissesKeyboard(.interactively)
			.safeAreaInset(edge: .bottom) {
				VStack(alignment: .leading, spacing: 0) {
					HStack {
						Text("this is the track that is playing")
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

						PlayButton()
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

					Text("Version 3")
						.foregroundStyle(.secondary)


					HStack {
						Text("0:00")
							.monospacedDigit()
						ZStack(alignment: .leading) {
							RoundedRectangle(cornerRadius: Constants.cornerRadius)
								.frame(height: 2)
							RoundedRectangle(cornerRadius: Constants.cornerRadius)
								.fill(.primary)
								.frame(width: 199)
								.frame(height: 2)
						}
						Text("2:43")
					}
					.foregroundColor(.secondary)
					.font(.caption2)
					.padding(.top, 8)


					if isExpanded {
						VStack(spacing: 12) {
							HStack(spacing: 24) {
								Spacer()
								Image(systemName: "backward")
									.resizable()
									.scaledToFit()
									.frame(width: 24, height: 24)
								Image(systemName: "play.circle.fill")
									.resizable()
									.scaledToFit()
									.frame(width: 32, height: 32)
								Image(systemName: "forward")
									.resizable()
									.scaledToFit()
									.frame(width: 24, height: 24)
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
				.padding(.top, 12)
				.padding(.bottom, dragPadding)
				.background(.ultraThinMaterial)
				.gesture(DragGesture().updating($dragOffset) { event, state, _ in
					withAnimation {
						state = -event.translation.height
					}
				})
				.animation(.spring, value: dragOffset)
				.onChange(of: dragOffset) {
					withAnimation(.spring(duration: 0.2)) {
						if dragOffset != 0 {
							self.isExpanded = dragOffset > 48
						}
					}
				}
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
