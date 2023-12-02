
### Build
- `run swift build`
- Make sure webpack is installed before the next step if not run `npm install webpack webpack-cli --save-dev`
- Make sure you run `npm run build` before running the website or packaging for deployment. This builds all the dependencies for the client into the bundle.js file that's hosted and delivered by Vapor

### Issues
- If you get a '{"error":true,"reason":"No template found for home"}' error on first run make sure you set the working directory in `scheme->options`
