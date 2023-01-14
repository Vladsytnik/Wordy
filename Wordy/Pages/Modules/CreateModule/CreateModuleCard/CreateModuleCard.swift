//
//  CreateModuleCard.swift
//  Wordy
//
//  Created by Vlad Sytnik on 23.12.2022.
//

import SwiftUI

struct CreateModuleCard: View {
    
	let backgroundColor = Color(asset: Asset.Colors.moduleCardBG)
	let width: CGFloat
	
	@Binding var needAnimate: Bool
	@Binding var showEmojiView: Bool
	@Binding var emoji: String
	@Binding var moduleName: String
	
	let cardName = "Games"
	let words = [
		"Dude",
		"Get on well",
		"Map",
		"Word"
	]
	let action: () -> Void
	
	private var height: CGFloat {
		width / 0.9268
	}
	
	var body: some View {
		ZStack {
			RoundedRectangle(cornerRadius: 35.0)
				.foregroundColor(backgroundColor)
				.frame(width: width, height: height)
				.shadow(color: .black.opacity(0.1), radius: 8, x: 10, y: 10)
			VStack {
				Spacer()
				Button {
					withAnimation(.spring()) {
						showEmojiView = true
					}
				} label: {
					ZStack(alignment: .topTrailing) {
						Text(emoji)
							.font(.system(size: width / 3.16666))
						Image(asset: Asset.Images.plusIcon)
							.resizable()
							.frame(width: 30, height: 30)
							.padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 8))
							.opacity(emoji == "📄" ? 1 : 0)
					}
				}
				Spacer()
				InputRoundedTextArea(
					moduleName: $moduleName,
					cardWidth: width,
					cardName: cardName,
					words: words
				) { action() }
			}
			.frame(width: width, height: height)
			.offset(y: -7)
		}
		.offset(y: needAnimate ? 0 : 200)
	}
}

struct CreateModuleCard_Previews: PreviewProvider {
    static var previews: some View {
		ZStack {
			Color(asset: Asset.Colors.moduleCardBG).ignoresSafeArea()
			CreateModuleCard(
				width: 250,
				needAnimate: .constant(false),
				showEmojiView: .constant(false),
				emoji: .constant("📄"),
				moduleName: .constant("")
			) {}
		}
    }
}

struct EmojiView : View {
	
	@Binding var show : Bool
	@Binding var txt : String
	@Environment(\.dismiss) var dismiss
	
	let emojiRanges = [
		(0x1F601, 0x1F64F),
		(0x2702, 0x27B0),
		(0x1F680, 0x1F6C0),
		(0x1F170, 0x1F251)
	]
	
	var body : some View{
		ZStack(alignment: .topLeading) {
			ScrollView(.vertical, showsIndicators: false) {
//				VStack(spacing: 15){
//					ForEach(["🧸", "🎀"], id: \.self) { i in
//						HStack(spacing: 25){
//							ForEach(i, id: \.self){ j in
//								Button(action: {
//									self.txt = String(UnicodeScalar(j)!)
//									show.toggle()
//								}) {
//									if (UnicodeScalar(j)?.properties.isEmoji)! {
//										Text(String(UnicodeScalar(j)!)).font(.system(size: 55))
//									}
//								}
//							}
//						}
//					}
//				}
				
				LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 20, content: {
					ForEach(["🧸", "🎀", "🎏", "📄", "🎊", "❤️", "❤️‍🔥", "💜", "🔐", "🔅", "❗️", "Ⓜ️", "👾", "🧑🏻‍💻", "🌍", "😵‍💫", "🔮"], id: \.self) { i in
						Button(action: {
							self.txt = i
							withAnimation(.spring()) {
								show.toggle()
							}
						}) {
							Text(i).font(.system(size: 55))
						}
					}
				})
				.padding()
			}.frame(width: UIScreen.main.bounds.width - 64, height: UIScreen.main.bounds.height / 3)
//				.padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom)
				.background(Color(asset: Asset.Colors.moduleCardDarkGray))
				.cornerRadius(25)
//			Button(action: {
//				self.show.toggle()
//			}) {
//				Image(systemName: "xmark").foregroundColor(.white)
//			}.padding()
		}
	}
	
	func getEmojiList() -> [[Int]] {
		var emojis : [[Int]] = []
		for k in emojiRanges {
			for i in stride(from: k.0, to: k.1, by: 4) {
				var temp : [Int] = []
				for j in i...(i + 3) {
					temp.append(j)
				}
				emojis.append(temp)
			}
		}
		return emojis
	}
}
