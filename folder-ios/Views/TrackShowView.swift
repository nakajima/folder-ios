//
//  TrackShowView.swift
//  folder-ios
//
//  Created by Pat Nakajima on 10/3/23.
//

import SwiftUI
import pat_swift

struct ChipsStack: Layout {
		private let spacing: CGFloat

		init(spacing: CGFloat = 8) {
				self.spacing = spacing
		}

	func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
			let sizes = subviews.map { $0.sizeThatFits(proposal) }
			let maxViewHeight = sizes.map { $0.height }.max() ?? 0
			var currentRowWidth: CGFloat = 0
			var totalHeight: CGFloat = maxViewHeight
			var totalWidth: CGFloat = 0

			for size in sizes {
					if currentRowWidth + spacing + size.width > proposal.width ?? 0 {
							totalHeight += spacing + maxViewHeight
							currentRowWidth = size.width
					} else {
							currentRowWidth += spacing + size.width
					}
					totalWidth = max(totalWidth, currentRowWidth)
			}
			return CGSize(width: totalWidth, height: totalHeight)
	}

	func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
			let sizes = subviews.map { $0.sizeThatFits(proposal) }
			let maxViewHeight = sizes.map { $0.height }.max() ?? 0
			var point = CGPoint(x: bounds.minX, y: bounds.minY)
			for index in subviews.indices {
					if point.x + sizes[index].width > bounds.maxX {
							point.x = bounds.minX
							point.y += maxViewHeight + spacing
					}
					subviews[index].place(at: point, proposal: ProposedViewSize(sizes[index]))
					point.x += sizes[index].width + spacing
			}
	}
}

struct TrackShowView: View {
	@Namespace var namespace

	@State private var isShowingCover = false

	var track: Track

	var body: some View {
		GeometryReader { geo in
			ZStack {
				List {
					Section {
						HStack(spacing: 12) {
							NeonView(size: 48, seed: track.id)
								.cornerRadius(Constants.cornerRadius)
								.shadow(radius: 2)
								.overlay {
									if !isShowingCover {
										Color.clear
											.contentShape(Rectangle())
											.matchedGeometryEffect(id: "cover", in: namespace)
									}
								}
								.onTapGesture {
									withAnimation(.spring(duration: 0.2)) {
										isShowingCover.toggle()
									}
								}

							Text(track.name)
								.font(.title3)
								.bold()
								.lineSpacing(-1)
								.multilineTextAlignment(.leading)
							Spacer()
						}
						.frame(maxWidth: .infinity)
						.padding()
						.background(.ultraThinMaterial)
						.cornerRadius(Constants.cornerRadius)
						.listRowSeparator(.hidden)
					}

					VStack(spacing: 12) {
						HStack(spacing: 8) {
							Image(systemName: "play.fill")
								.shadow(radius: 2)
							Text("Version 1")
								.bold()
							Text("Current")
								.font(.caption2)
								.padding(.horizontal, 4)
								.padding(.vertical, 2)
								.background(.ultraThinMaterial)
								.cornerRadius(Constants.cornerRadius)
							Spacer()
							Text("0 comments")
								.foregroundStyle(.secondary)
						}

						Divider()

						HStack(spacing: 8) {
							Image(systemName: "play.fill")
							Text("Version 2")
							Spacer()
							Text("0 comments")
						}
						.foregroundStyle(.secondary)

						Divider()

						HStack(spacing: 8) {
							Image(systemName: "play.fill")
							Text("Version 3")
							Spacer()
							Text("0 comments")
						}
						.foregroundStyle(.secondary)
					}
					.font(.subheadline)
					.frame(maxWidth: .infinity)
					.padding(12)
					.background(.ultraThinMaterial)
					.cornerRadius(Constants.cornerRadius)
					.listRowSeparator(.hidden)

					ChipsStack {
						Text("Folders:")
							.font(.caption)
							.padding(.vertical, 4)

						Text("Pop punk")
							.padding(.horizontal, 8)
							.padding(.vertical, 4)
							.font(.caption)
							.cornerRadius(Constants.cornerRadius)
							.background(.ultraThinMaterial)
							.bold()
						Text("Acoustic")
							.padding(.horizontal, 8)
							.padding(.vertical, 4)
							.font(.caption)
							.cornerRadius(Constants.cornerRadius)
							.background(.ultraThinMaterial)
							.bold()
					}
					.cornerRadius(Constants.cornerRadius)
					.listRowSeparator(.hidden)
					.padding(.top, 12)
				}
				.listRowSpacing(-12)
				.listStyle(.plain)

				if isShowingCover {
					VStack(spacing: 8) {
						NeonView(size: geo.size.width-24, seed: track.id)
							.cornerRadius(Constants.cornerRadius)
						Text("Hey this cover art is random.")
							.font(.caption)
					}
					.padding(12)
					.transition(.move(edge: .top).combined(with: .opacity))
					.background(.ultraThinMaterial)
					.cornerRadius(Constants.cornerRadius)
					.dragDismissable {
						withAnimation(.spring(duration: 0.2)) {
							isShowingCover = false
						}
					}
				}
			}
		}
	}
}

#Preview {
	NavigationStack {
		TrackShowView(track: Track.list[1])
			.navigationBarTitleDisplayMode(.inline)
	}
}
