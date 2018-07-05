// Copyright © 2018 Arrive Technologies. All rights reserved.
// Node module: loopback-sdk-ios-swift-codegen
// This file is licensed under the MIT License.
// License text available at https://opensource.org/licenses/MIT

const fs = require('fs');
const ejs = require('ejs');
const moment = require('moment');
const pascalCase = require('pascal-case');

const {
  methodNamesToSkip,
  methodNamesUserToKeep,
  objcMethodNamesToSkip,
  methodNameReplacementTable,
  propTypeConversionTable,
  swiftPropTypeConversionTable,
  argTypeConversionTable,
  swiftArgTypeConversionTable,
  returnTypeConversionTable,
  swiftReturnTypeConversionTable,
} = require('./data-type-conversion');

const baseModels = ['Application', 'User', 'Notification', 'Installation', 'Push'];
const modelsName = [];

const executePropeties = ['id'];
const executeModels = [];

const SCOPE_METHOD_REGEX = /^prototype.__([^_]+)__(.+)$/;

/**
 * Generate iOS Client-side Swift representation of the models.
 *
 * @param {Object} app The loopback application created via `app = loopback()`.
 * @returns {Object} A hash map indexed by file names with file contents as the value.
 */
exports.swiftModels = function generateServices (app, modelPrefix, modelPostfix, verbose) {
  const models = describeModels(app);
  /* Store list models name */
  for (let modelName in models) {
    if (models.hasOwnProperty(modelName)) {
      modelsName[modelsName.length] = models[modelName].name;

      /* Update list include data from other model */
      models[modelName].relationMode = [];
      models[modelName].moreRepo = [];

      for (let relation in models[modelName].relations) {
        if (models[modelName].relations.hasOwnProperty(relation)) {
          let relationModel = models[modelName].relations[relation].model;

          if (!((typeof relationModel) === 'undefined')) {
            if (relationModel !== models[modelName].name && models[modelName].relationMode.indexOf(relationModel) === -1) {
              models[modelName].relationMode[models[modelName].moreInclude.length] = modelPrefix + pascalCase(relationModel);
            }
          }

          relationModel = models[modelName].relations[relation].through;

          if (!((typeof relationModel) === 'undefined')) {
            if (relationModel !== models[modelName].name && models[modelName].moreInclude.indexOf(relationModel) === -1) {
              models[modelName].moreInclude[models[modelName].moreInclude.length] = modelPrefix + pascalCase(relationModel);
            }
          }
        }
      }
    }
  }

  addSwiftNames(models, modelPrefix, modelPostfix, verbose);

  const swiftStructTemplate = readTemplate('./swift-model.ejs');
  const swiftRepoTemplate = readTemplate('./swift-repo.ejs');

  const ret = {};

  for (let modelName in models) {
    let modelDesc = models[modelName];
    modelDesc.prefix = modelPrefix;
    modelDesc.postfix = modelPostfix;
    modelDesc.appName = 'Aify';
    modelDesc.date = moment().format('DD/MM/YYYY');
    modelDesc.year = moment().format('YYYY');
    let swiftModelName = models[modelName].objcModelName;

    let script = renderContent(swiftStructTemplate, modelDesc);
    ret[swiftModelName + '.swift'] = script;

    script = renderContent(swiftRepoTemplate, modelDesc);
    ret[swiftModelName + 'Repository.swift'] = script;
  }

  return ret;
};

function describeModels (app) {
  const result = {};
  /*
  for (let model in app.models) {
    model.get;
  }
  */

  // Get special RestClass
  let listRestClass = app.handler('rest').adapter.getClasses();
  let userRestApis = [];
  for (let i = 0; i < listRestClass.length; i++) {
    if (listRestClass[i].name === 'User') {
      for (let j = 0; j < listRestClass[i].methods.length; j++) {
        userRestApis[userRestApis.length] = listRestClass[i].methods[j].name;
      }
      break;
    }
  }

  app.handler('rest').adapter.getClasses().forEach(function (c) {
    let name = c.name;
    let modelDefinition = app.models[name].definition;

    if (!c.ctor) {
      // Skip classes that don't have a shared ctor
      // as they are not LoopBack models
      console.error('Skipping %j as it is not a LoopBack model', name);
      return;
    }

    // Skip the User class as its Obj-C implementation is provided as a part of the SDK framework.
    let isUser = c.name === 'User';

    // let isUser = c.sharedClass.ctor.prototype instanceof app.loopback.User ||
    // c.sharedClass.ctor.prototype === app.loopback.User.prototype;
    if (isUser) {
      return;
    }

    c.pluralName = c.sharedClass.ctor.pluralModelName;
    c.props = modelDefinition.properties;
    c.baseModel = modelDefinition.settings.base;
    if (c.baseModel != null && typeof (c.baseModel) === 'function') {
      c.baseModel = '';
    }
    if (modelDefinition._ids != null) {
      c.isGenerated = modelDefinition._ids[0].property.generated;
    } else {
      c.isGenerated = false;
    }
    c.relations = modelDefinition.settings.relations;
    c.acls = modelDefinition.settings.acls;
    c.validations = modelDefinition.settings.validations;

    let isBaseUser = c.sharedClass.ctor.prototype instanceof app.loopback.User ||
      c.sharedClass.ctor.prototype === app.loopback.User.prototype;

    if (isBaseUser) {
      for (let i = 0; i < c.methods.length; i++) {
        if (userRestApis.indexOf(c.methods[i].name) !== -1 && methodNamesUserToKeep.indexOf(c.methods[i].name) !== -1) {
          // Remove
          c.methods.splice(i, 1);
          i--;
        }
      }
    }

    c.methods.forEach(function fixArgsOfPrototypeMethods (method) {
      let ctor = method.restClass.ctor;
      if (!ctor || method.sharedMethod.isStatic) return;
      method.accepts = ctor.accepts.concat(method.accepts);
    });

    result[name] = c;
  });

  buildScopes(result);

  return result;
}

function buildScopes (models) {
  for (let modelName in models) {
    buildScopesOfModel(models, modelName);
  }
}

function buildScopesOfModel (models, modelName) {
  let modelClass = models[modelName];

  modelClass.scopes = {};
  modelClass.methods.forEach(function (method) {
    buildScopeMethod(models, modelName, method);
  });

  return modelClass;
}

// reverse-engineer scope method
// defined by loopback-datasource-juggler/utility/scope.js
function buildScopeMethod (models, modelName, method) {
  let modelClass = models[modelName];
  let match = method.name.match(SCOPE_METHOD_REGEX);
  if (!match) return;

  let op = match[1];
  let scopeName = match[2];
  let modelPrototype = modelClass.sharedClass.ctor.prototype;
  let targetClass = modelPrototype[scopeName]._targetClass;

  // Check rename method in special case
  if (match[0].indexOf('prototype.') !== -1) {
    method.name = op + '__' + scopeName;
  }

  if (modelClass.scopes[scopeName] === undefined) {
    if (!targetClass) {
      console.error(
        'Warning: scope %s.%s is missing _targetClass property.' +
        '\nThe iOS code for this scope won\'t be generated.' +
        '\nPlease upgrade to the latest version of' +
        '\nloopback-datasource-juggler to fix the problem.',
        modelName, scopeName);
      modelClass.scopes[scopeName] = null;
      return;
    }

    if (!findModelByName(models, targetClass)) {
      console.error(
        'Warning: scope %s.%s targets class %j, which is not exposed ' +
        '\nvia remoting. The iOS code for this scope won\'t be generated.',
        modelName, scopeName, targetClass);
      modelClass.scopes[scopeName] = null;
      return;
    }

    modelClass.scopes[scopeName] = {
      methods: {},
      targetClass: targetClass,
    };
  } else if (modelClass.scopes[scopeName] === null) {
    // Skip the scope, the warning was already reported
    return;
  }

  let apiName = scopeName;
  if (op === 'get') {
    // no-op, create the scope accessor
  } else if (op === 'delete') {
    apiName += '.destroyAll';
  } else {
    apiName += '.' + op;
  }

  let scopeMethod = Object.create(method);
  /* Remove reverseName, it's always undefined and somethings error */
  scopeMethod.name = scopeName;
  // scopeMethod.name = reverseName;
  // override possibly inherited values
  scopeMethod.deprecated = false;
  scopeMethod.internal = false;
  modelClass.scopes[scopeName].methods[apiName] = scopeMethod;
  if (scopeMethod.name.match(/create/)) {
    let scopeCreateMany = Object.create(scopeMethod);
    scopeCreateMany.name = scopeCreateMany.name.replace(
      /create/,
      'createMany'
    );
    scopeCreateMany.isReturningArray = function () {
      return true;
    };
    apiName = apiName.replace(/create/, 'createMany');
    modelClass.scopes[scopeName].methods[apiName] = scopeCreateMany;
  }
}

function findModelByName (models, name) {
  for (let n in models) {
    if (n.toLowerCase() === name.toLowerCase()) {
      return models[n];
    }
  }
}

function addSwiftNames (models, modelPrefix, modelPostfix, verbose) {
  for (let modelName in models) {
    if (verbose) {
      console.error('\nProcessing model:' + modelName + '...');
    }
    let meta = models[modelName];
    meta.objcModelName = modelPrefix + pascalCase(modelName);
    meta.objcRepoName = meta.objcModelName + 'Repository';
    if (meta.baseModel === 'Model' || meta.baseModel === 'PersistedModel' ||
      baseModels.indexOf(meta.baseModel) !== -1) {
      meta.objcBaseModel = 'LB' + meta.baseModel;
    } else {
      throw new Error('Unknown base model: ' + meta.baseModel + ' for model: ' + modelName + '');
    }
    meta.objcProps = [];
    for (let propName in meta.props) {
      if (executePropeties.indexOf(propName) !== -1) {
        // `_id` is already defined in LBPersistedModel
        continue;
      }
      let prop = meta.props[propName];
      if (verbose) {
        console.error(' Property:' + propName + '', prop);
      }
      let objcProp = convertToSwiftPropType(prop.type);
      if (typeof objcProp === 'undefined') {
        throw new Error('Unsupported property type: ' + prop.type.name + ' in model: ' + modelName + '');
      }
      meta.objcProps.push({
        name: propName,
        type: objcProp,
      });
    }

    meta.objcMethods = [];
    meta.methods.forEach(function (method) {
      if (verbose) {
        console.error(`Method: ${method.name}`, method);
      }
      addSwiftMethodInfo(meta, method, modelName, true);
      if (hasOptionalArguments(method)) {
        addSwiftMethodInfo(meta, method, modelName, false);
      }
    });
  }
}

function addSwiftMethodInfo (meta, method, modelName, skipOptionalArguments) {
  if (methodNamesToSkip.indexOf(method.name) >= 0) {
    return;
  }

  // Skip some methods from model User
  let methodPrototype = '';
  let methodName = method.name;
  methodName = methodName.replace('prototype.', '');
  let paramAssignments;
  let bodyParamAssignments;
  method.accepts.forEach(function (param) {
    const paramRequired = param.required || (param.http && param.http.source === 'body');
    if (!paramRequired && skipOptionalArguments) {
      return;
    }

    let objcModelType = meta.objcModelName + ' *';
    if (typeof (param.model) === 'string') {
      objcModelType = param.model + ' *';
    }

    let argType = convertToSwiftArgType(param.type, param.arg, objcModelType);
    if (typeof argType === 'undefined') {
      throw new Error('Unsupported argument type: ' + param.type + ' in model: ' + modelName + '');
    }
    let argName = (param.arg === 'id') ? 'id_' : param.arg;
    let argRightValue = argName;
    if (argType === objcModelType) {
      argRightValue = '[' + param.arg + ' toDictionary]';
    } else if (argType === 'NSDictionary *') {
      argRightValue = '(' + param.arg + ' ? ' + param.arg + ' : @{})';
    }
    if (methodName === method.name) {
      methodName += 'With' + param.arg[0].toUpperCase() + param.arg.slice(1);
    } else {
      methodPrototype += ' ' + param.arg;
    }
    if (param.http && param.http.source === 'body') {
      if (bodyParamAssignments) {
        throw new Error('Multiple body arguments specified in method: ' + method.name + ' of model: ' + modelName + '');
      }
      bodyParamAssignments = argRightValue;
    } else {
      if (!paramAssignments) {
        paramAssignments = '@' + param.arg + ': ' + argRightValue;
      } else {
        paramAssignments += ', @' + param.arg + ': ' + argRightValue;
      }
    }

    methodPrototype += ':(' + argType + ')' + argName;
  });

  const returnArg = method.returns[0] && method.returns[0].arg;
  const returnType = method.returns[0] && method.returns[0].type;
  const objcReturnType = convertToSwiftReturnType(returnType, modelName, meta.objcModelName);
  if (typeof objcReturnType === 'undefined') {
    throw new Error(`Unsupported return type: ${returnType} in method: ${method.name} of model: ${modelName}`);
  }
  const successBlockType = convertToSwiftSuccessBlockType(objcReturnType);

  if (methodName === method.name) {
    methodName += 'WithSuccess';
    methodPrototype += ':(' + successBlockType + ')success ';
  } else {
    methodPrototype += '\n        success:(' + successBlockType + ')success';
  }
  methodPrototype += '\n        failure:(SLFailureBlock)failure';

  if (objcMethodNamesToSkip.indexOf(methodName) >= 0) {
    return;
  }
  if (methodNameReplacementTable[methodName]) {
    methodName = methodNameReplacementTable[methodName];
  }
  methodPrototype = '(void)' + methodName + methodPrototype;
  let newTypeReturn = '';
  if (Array.isArray(returnType)) {
    newTypeReturn = returnType[0];
  }

  meta.objcMethods.push({
    rawName: method.name,
    prototype: methodPrototype,
    returnArg: returnArg,
    objcReturnType: objcReturnType,
    originObjcReturnType: newTypeReturn,
    paramAssignments: paramAssignments,
    bodyParamAssignments: bodyParamAssignments,
  });
  method.objcGenerated = true;
}

function hasOptionalArguments (method) {
  for (let idx in method.accepts) {
    let param = method.accepts[idx];
    let paramRequired = param.required || (param.http && param.http.source === 'body');
    if (!paramRequired) {
      return true;
    }
  }
  return false;
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

// === Support convert data

function convertToSwiftPropType (type) {
  if (Array.isArray(type)) {
    return propTypeConversionTable['<array>'];
  }
  return propTypeConversionTable[type.name];
}

function convertToSwiftArgType (type, name, objcModelType) {
  let objcType = argTypeConversionTable[type + ' ' + name];
  objcType = objcType || argTypeConversionTable[type];
  if (objcType) {
    objcType = objcType.replace('<objcModelType>', objcModelType);
  }
  return objcType;
}

function convertToSwiftReturnType (type, modelName, objcModelName) {
  if (type === modelName) {
    return objcModelName;
  }

  /* In case not found any type,
   * it maybe is object type from other model, must return type name
   */
  if (modelsName.indexOf(type) !== -1) {
    return pascalCase(type);
  }

  if (typeof type === 'undefined') {
    type = '<void>';
  }
  if (Array.isArray(type)) {
    type = '<array>';
  }

  // Workaround for run ok
  if (typeof type === 'object') {
    type = 'number';
  }
  return returnTypeConversionTable[type];
}

function convertToSwiftSuccessBlockType (objcType) {
  let returnArgType;
  if (objcType === 'void') {
    returnArgType = '';
  } else if (objcType === 'BOOL') { // primitive type
    returnArgType = objcType;
  } else {
    returnArgType = objcType + ' *';
  }
  return 'void (^)(' + returnArgType + ')';
}