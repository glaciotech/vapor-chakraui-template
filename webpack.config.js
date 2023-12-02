const path = require('path');

module.exports = {
    entry: './Public/app.js',  // Your JS entry point
    output: {
        filename: 'bundle.js',
        path: path.resolve(__dirname, 'Public') // Output to Vapor's Public folder
    },
//    externals: {
//       './Public/app.js': 'App' // assuming 'App' is the global variable you want to assign your app.js to.
//     },
    resolve: {
       modules: [path.resolve(__dirname, '../node_modules')]
    },
    // Add loaders, plugins, etc. as per your requirements
    module: {
        rules: [
            {
                test: /\.(js|jsx)$/,
                exclude: /node_modules/,
                use: {
                    loader: 'babel-loader'
                }
            }
        ]
    },

    // Optionally, resolve .jsx extensions by default
    resolve: {
        extensions: ['.js', '.jsx']
    },
    
    devtool: 'source-map',

};
