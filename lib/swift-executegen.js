// Copyright © 2018 Arrive Technologies. All rights reserved.
// Node module: loopback-sdk-ios-swift-codegen
// This file is licensed under the MIT License.
// License text available at https://opensource.org/licenses/MIT

const fs = require('fs');
const ejs = require('ejs');

const logger = require('./logger');

/**
 * Generate iOS Client-side Swift representation of the models.
 *
 * @param {Object} app The loopback application created via `app = loopback()`.
 * @returns {Object} A hash map indexed by file names with file contents as the value.
 */
exports.swiftExecuteModels = function generateExecute (app, verbose) {
  const models = describeModels(app);
  const executeTemplate = readTemplate('./model-execute.ejs');

  const ret = {};

  for (let modelName in models) {
    let modelDesc = models[modelName];
    let swiftModelName = modelName;
    let script = renderContent(executeTemplate, modelDesc);
    ret[swiftModelName + '.json'] = script;
  }

  return ret;
};

function describeModels (app) {
  const result = {};

  // Get special RestClass
  let listRestClass = app.handler('rest').adapter.getClasses();
  let userRestApis = [];
  for (let i = 0; i < listRestClass.length; i++) {
    if (listRestClass[i].name === 'User') {
      // TODO: Need some check in default model
      for (let j = 0; j < listRestClass[i].methods.length; j++) {
        userRestApis[userRestApis.length] = listRestClass[i].methods[j].name;
      }
      break;
    }
  }

  // TODO: Check here for remove un-want generator methods

  app.handler('rest').adapter.getClasses().forEach(function (c) {
    let name = c.name;

    if (!c.ctor) {
      // Skip classes that don't have a shared ctor
      // as they are not LoopBack models
      logger.error('Skipping %j as it is not a LoopBack model', name);
      return;
    }

    // Skip the User class as its Obj-C implementation is provided as a part of the SDK framework.
    let isUser = c.name === 'User';

    if (isUser) {
      return;
    }

    result[name] = c;
  });

  return result;
}

function readTemplate (filename) {
  let ret = fs.readFileSync(
    require.resolve(filename), {
      encoding: 'utf-8',
    }
  );
  return ret;
}

function renderContent (template, modelMetaInfo) {
  let script = ejs.render(
    template, {
      meta: modelMetaInfo,
    }
  );
  return script;
}
