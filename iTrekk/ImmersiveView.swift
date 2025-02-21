import SwiftUI
import MapKit
import RealityKit

struct ImmersiveView: View {
    
    @State var index: Int

    var body: some View {
        // Using self.randomNumberGenerator() to ensure it's recognized as a function call.
        let textureName = "Environment " + String(index)
        var _: CLLocationCoordinate2D

        return RealityView() { content in
            // Use the corrected textureName with the random number
            guard let texture = try? TextureResource.load(named: textureName) else {
                fatalError("Texture not loaded!")
            }
            
            let rootEntity = Entity()
            var material = UnlitMaterial() // Material without influence of lighting
            material.color = .init(texture: .init(texture))
            
            rootEntity.components.set(ModelComponent(mesh: .generateSphere(radius: 1E3), materials: [material]))
            
            rootEntity.scale = .init(x: 1, y: 1, z: -1)
            rootEntity.transform.translation += SIMD3<Float>(0.0, 10.0, 0.0)
            let angle = Angle.degrees(90)
            let rotation = simd_quatf(angle: Float(angle.radians), axis: SIMD3<Float>(0, 1, 0))
            rootEntity.transform.rotation = rotation
            
            content.add(rootEntity)
        } update: { content in
            // Here you can update the RealityKit content
        }
    }
}
