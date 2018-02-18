#!/usr/bin/env node

'use strict';

var express = require('express'),
    bodyParser = require('body-parser'),
    fs = require('fs'),
    zlib = require('zlib'),
    path = require('path'),
    spawn = require('child_process').spawn,
    backend = require('git-http-backend'),
    ldapjs = require('ldapjs'),
    basicAuth = require('basic-auth');

function exit(error) {
    if (error) console.error(error);
    process.exit(error ? 1 : 0);
}

if (!process.env.LDAP_URL || !process.env.LDAP_USERS_BASE_DN) {
    exit('No LDAP_URL or LDAP_USERS_BASE_DN configured.');
}

var port = 3000;
var websitePath = '/run/static';
var repoPath = '/app/data/repo.git';

var app = express();

app.set('trust proxy', 1);
app.use(bodyParser.urlencoded({ extended: true }));

app.use('/.git', function (req, res, next) {
    var userInfo = basicAuth(req);
    if (!userInfo) {
        res.header({'WWW-Authenticate': 'Basic realm="GitHub"'});
        return res.sendStatus(401);
    }

    var ldapClient = ldapjs.createClient({ url: process.env.LDAP_URL });
    var ldapDn = 'cn=' + userInfo.name + ',' + process.env.LDAP_USERS_BASE_DN;

    ldapClient.bind(ldapDn, userInfo.pass, function (error) {
        if (error) return res.send(403);

        next();
    });
}, function (req, res) {
    var reqStream = req.headers['content-encoding'] == 'gzip' ? req.pipe(zlib.createGunzip()) : req;

    reqStream.pipe(backend(req.url, function (err, service) {
        if (err) return res.end(err + '\n');

        res.setHeader('content-type', service.type);
        console.log('git:', service.action, service.fields);

        var ps = spawn(service.cmd, service.args.concat(repoPath));
        ps.stdout.pipe(service.createStream()).pipe(ps.stdin);

    })).pipe(res);
});

app.get('/_healthcheck', function (req, res) {
    res.status(200).end();
});

app.use(express.static(websitePath));

app.listen(port, function () {
    console.log('Listening on port %s', port);
    console.log('Using git repo at %s', repoPath);
    console.log('Serving up directory %s', websitePath);
});
