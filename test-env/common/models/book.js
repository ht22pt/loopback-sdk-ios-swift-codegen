// Copyright IBM Corp. 2015. All Rights Reserved.
// Node module: loopback-sdk-ios-codegen
// This file is licensed under the MIT License.
// License text available at https://opensource.org/licenses/MIT

module.exports = function (Book) {

  Book.remoteMethod('testNumberMethod',
    {
      description: 'Update LoginUser keywords of bussiness profile',
      accepts: [
        { arg: 'id', type: 'string', required: true },
        { arg: 'keywords', type: 'number', required: true },
      ],
      http: { path: '/:id/testNumberMethod', verb: 'post' },
      returns: { arg: 'body', type: 'number', root: true },
    });

  Book.remoteMethod('testStringMethod',
    {
      description: 'Update LoginUser keywords of bussiness profile',
      accepts: [
        { arg: 'id', type: 'string', required: true },
        { arg: 'keywords', type: 'string', required: true },
      ],
      http: { path: '/:id/String', verb: 'post' },
      returns: { arg: 'body', type: 'string', root: true },
    });

  Book.remoteMethod('testBoolMethod',
    {
      description: 'Update LoginUser keywords of bussiness profile',
      accepts: [
        { arg: 'id', type: 'string', required: true },
        { arg: 'keywords', type: 'boolean', required: true },
      ],
      http: { path: '/:id/testBoolMethod', verb: 'get' },
      returns: { arg: 'body', type: 'boolean', root: true },
    });

  Book.remoteMethod('testArrayMethod',
    {
      description: 'Update LoginUser keywords of bussiness profile',
      accepts: [
        { arg: 'id', type: 'string', required: true },
        { arg: 'keywords', type: 'array', required: true },
      ],
      http: { path: '/:id/testArrayMethod', verb: 'put' },
      returns: { arg: 'body', type: 'array', root: true },
    });

  Book.remoteMethod('testObjectMethod',
    {
      description: 'Update LoginUser keywords of bussiness profile',
      accepts: [
        { arg: 'id', type: 'string', required: true },
        { arg: 'keywords', type: 'object', required: true },
      ],
      http: { path: '/:id/testObjectMethod', verb: 'post' },
      returns: { arg: 'body', type: 'object', root: true },
    });
};
