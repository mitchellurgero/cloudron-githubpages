#!/usr/bin/env node

/* jslint node:true */
/* global it:false */
/* global xit:false */
/* global describe:false */
/* global before:false */
/* global after:false */

'use strict';

var execSync = require('child_process').execSync,
    expect = require('expect.js'),
    path = require('path'),
    request = require('request'),
    rimraf = require('rimraf');

const REPO_DIR = path.resolve(__dirname, 'page');
const LOCATION = 'tests';
const EXEC_OPTIONS = { cwd: path.resolve(__dirname, '..'), stdio: 'inherit' };

describe('Application life cycle test', function () {
    this.timeout(0);

    var app;

    function getAppInfo() {
        var inspect = JSON.parse(execSync('cloudron inspect'));
        app = inspect.apps.filter(function (a) { return a.location === LOCATION; })[0];
        expect(app).to.be.an('object');
    }

    function isPageReachable(done) {
        request(`https://${app.fqdn}/`, function (error, response, body) {
            expect(error).to.eql(null);
            expect(response.statusCode).to.eql(200);
            expect(body.indexOf('You\'re up and running!')).to.not.eql(-1);
            done();
        });
    }

    before(function (done) {
        if (!process.env.USERNAME) return done(new Error('USERNAME env var not set'));
        if (!process.env.PASSWORD) return done(new Error('PASSWORD env var not set'));

        rimraf.sync(REPO_DIR);

        execSync(`git clone https://github.com/barryclark/jekyll-now.git ${REPO_DIR}`);

        done();
    });

    after(function (done) {
        rimraf.sync(REPO_DIR);
        done();
    });

    xit('build app', function () {
        execSync('cloudron build', EXEC_OPTIONS);
    });

    it('install app', function () {
        execSync(`cloudron install --new --wait --location ${LOCATION}`, EXEC_OPTIONS);
    });

    it('can get app information', getAppInfo);

    it('can push page to app', function () {
        execSync(`git push https://${encodeURIComponent(process.env.USERNAME)}:${encodeURIComponent(process.env.PASSWORD)}@${app.fqdn}/_git/page master --force`, { cwd: REPO_DIR, stdio: 'inherit' });
    });

    it('page is reachable', isPageReachable);

    it('uninstall app', function () {
        execSync(`cloudron uninstall --app ${app.id}`, EXEC_OPTIONS);
    });

    // Update tests
    it('install previous app', function () {
        execSync(`cloudron install --new --appstore-id github.pages.cloudronapp --wait --location ${LOCATION}`, EXEC_OPTIONS);
    });

    it('can get app information', getAppInfo);

    it('can push page to app', function () {
        execSync(`git push https://${encodeURIComponent(process.env.USERNAME)}:${encodeURIComponent(process.env.PASSWORD)}@${app.fqdn}/_git/page master --force`, { cwd: REPO_DIR, stdio: 'inherit' });
    });

    it('page is reachable', isPageReachable);

    it('can update', function () {
        execSync('cloudron install --wait --app ' + app.id, EXEC_OPTIONS);
    });

    it('page is reachable', isPageReachable);

    it('uninstall app', function () {
        execSync(`cloudron uninstall --app ${app.id}`, EXEC_OPTIONS);
    });
});
