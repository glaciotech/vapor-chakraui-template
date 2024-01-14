### Configure
- Search and replace references to `vapor-chakraui-template` with `your-app-name`, name should be found in:
    - Xcode scheme
    - Package.swift
    - docker-compose.yml
- Set the working directory under `scheme->options` if you're running from Xcode, otherwise the views won't work

### Build
- `run swift build`
- Make sure webpack is installed before the next step if not run `npm install webpack webpack-cli --save-dev`
- Make sure you run `npm run build` before running the website or packaging for deployment. This builds all the dependencies for the client into the bundle.js file that's hosted and delivered by Vapor
- Make sure working directory is set

### Issues
- If you get a '{"error":true,"reason":"No template found for home"}' error on first run make sure you set the working directory in '`'scheme->options`
