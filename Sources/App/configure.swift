import NIOSSL
import Leaf
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
     app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
//    let viewsDir = DirectoryConfiguration.detect().viewsDirectory
//    app.leaf.renderer.cache.isEnabled = false
//    app.leaf.configuration.rootDirectory = "/"
    app.views.use(.leaf)
    
    // register routes
    try routes(app)
}
