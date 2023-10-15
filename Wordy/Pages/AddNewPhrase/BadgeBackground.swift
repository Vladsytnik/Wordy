import SwiftUI


struct BadgeBackground: View {
    
    let color: Color
    var off: Int = 30
    
    var body: some View {
        GeometryReader { geo in
            
            let height = 10
            let width = 20
            let xOffset: Int = 0 + off
            
//            let xStart: Int = (Int(geo.size.width) / 2) - (width / 2) + xOffset
            let xStart: Int = Int(geo.size.width * 0.1)
            let yStart = 2
            
//            let xEnd: Int = (Int(geo.size.width) / 2) + (width / 2) + xOffset
            let xEnd: Int = xStart + width
            let yEnd = 0
            
            let xHalf = Int((xEnd - xStart) / 2)
            let xHalfHalf = xHalf / 2
            let heightHalf = Int(-(height / 2))
            
            Path { path in
                path.move(to: CGPoint(x: xStart, y: yStart))
                
                path.addQuadCurve(
                    to: .init(x: xStart + 10, y: yStart + heightHalf),
                    control: .init(x: xStart + xHalfHalf, y: yStart))
                
                path.addQuadCurve(
                    to: .init(x: xStart + (xEnd - xStart), y: heightHalf),
                    control: .init(x: xStart + 15, y: -height))
                
                path.addQuadCurve(
                    to: .init(x: xEnd + 10, y:yEnd),
                    control: .init(x: xEnd + xHalfHalf, y: yEnd))
                
                path.addLine(to: CGPoint(x: xStart, y: yStart))
//                path.addLine(to: CGPoint(x: 0, y: 0))
            }
            .foregroundColor(color)
//            .stroke(Color.orange, lineWidth: 1)
//            .foregroundColor(.blue)
        }
    }
}


#Preview {
    BadgeBackground(color: .pink, off: 30)
        .frame(width: 300, height: 100)
        .background { Color.pink }
}
