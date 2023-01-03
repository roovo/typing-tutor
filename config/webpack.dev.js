const path = require('path');

const {merge} = require('webpack-merge');
const common = require('./webpack.common.js');


const dev = {
    mode: 'development',
    output: {
        publicPath: "/"
    },
    devServer: {
        hot: "only",
        client: {
            logging: "info"
        },
        devMiddleware: {
            publicPath: "/",
            stats: "errors-only"
        },
        historyApiFallback: true,
        onBeforeSetupMiddleware: function (devServer) {
            devServer.app.get("/test", function (req, res) {
                res.json({result: "You reached the dev server"});
            });

        }
    },
};

module.exports = env => {
    const withDebug = !env.nodebug;
    return merge(common(withDebug), dev);
}
