# 4w-visualizer

![4w-demo](app/assets/images/github_4w_demo.gif)

## Introduction

4w-visualizer is a [Brunch](http://brunch.io) and [Chaplin](http://chaplinjs.org) web app for visualizing 4w's (who's doing what, where, and when).

With 4w-visualizer, you can

- Filter by activity, organization, and location
- Animate visualization over time
- View visualization on desktop, tablet, and mobile devices

## Requirements

4w-visualizer has been tested on the following configuration:

- MacOS X 10.9.5
- Brunch 1.8.5 (required)
- Chaplin 1.0.1 (required)
- [npm](https://www.npmjs.com/) 2.5.0 (required)
- [Bower](http://bower.io) 1.6.3 (required)
- [Coffeescript](http://coffeescript.org/) 1.6.2 (required to run a production server)
- [Node.js](http://nodejs.org) 0.12.5 (required to run a production server)


## Setup

*Install requirements (if you haven't already)*

```bash
npm install -g brunch
npm install -g bower
npm install -g coffee-script
```

## Installation

```bash
brunch new gh:reubano/4w-visualizer
cd 4w-visualizer
npm install
bower install
```

## Usage

*Run development server (continuous rebuild mode)*

    brunch watch --server

*Run production node server*

    coffee server.coffee

*Build html/css/js files (will appear in `public/`)*

    brunch build

*Build html and minified css/js files (will appear in `public/`)*

    brunch build --production

## License

4w-visualizer is distributed under the [MIT License](http://opensource.org/licenses/MIT).
