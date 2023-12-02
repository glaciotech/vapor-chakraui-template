import Vapor

func routes(_ app: Application) throws {
   
    app.get { req in
        return try await req.view.render("home")
    }
}
